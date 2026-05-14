try
    SUBJECT = getenv("SUBJECT");
    CH = str2double(getenv("CH"));
    runTag = getenv("RUN_TAG");
    isDry = getenv("DRYRUN");

    species = "macaque";
    subject = string(SUBJECT);
    preprocessSuffix = "_subtractMean_removeLineNoise";

    if strlength(subject) == 0
        error("ENV SUBJECT is empty");
    end
    if isnan(CH)
        error("ENV CH is not a number");
    end
    if strlength(runTag) == 0
        error("ENV RUN_TAG is empty");
    end

    rootDir = "<PROJECT_ROOT>/COSproject";
    load_dir = fullfile(rootDir, "preprocessed_epoch6s", char(species), char(subject));
    save_dir = fullfile(rootDir, ['hctsa' char(preprocessSuffix) '_' char(runTag)], char(species), char(subject));
    if ~exist(save_dir, "dir")
        mkdir(save_dir);
    end

    tgtChannels = CH;

    animal = regexp(char(subject), '^[^_]+', 'match', 'once');
    if isempty(animal)
        error("Could not parse animal name from SUBJECT: %s", char(subject));
    end

    expected_in = fullfile(load_dir, sprintf("macaque_%s_ch%03d%s.mat", animal, CH, char(preprocessSuffix)));
    if ~isfile(expected_in)
        error("Expected input not found: %s", expected_in);
    end

    if strcmp(isDry, "1")
        fprintf("DRYRUN OK: %s\n", expected_in);
        return;
    end

    force_findpeaks_matlab();

    preprocessSuffix = "_subtractMean_removeLineNoise";
    species = "macaque";
    subject = string(SUBJECT);
    runTag = string(runTag);
    tgtChannels = CH;

    setpref("cosProject", "dirPref", struct("rootDir", rootDir));

    cd("<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238");
    main_hctsa_1_init_epoch6s_patched;

    cd("<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238");
    main_hctsa_2_compute_epoch6s_patched_nopool;

    hctsa_mat = fullfile(save_dir, sprintf("macaque_%s_ch%03d_hctsa.mat", animal, CH));
    if ~isfile(hctsa_mat)
        error("Expected hctsa output not found: %s", hctsa_mat);
    end

    addpath("<LOCAL_STAGE2_REPO>/ops/job_audit/2026-02-03/run/audit_2026-02-16_1722_stage2");
    postprocess_single_hctsa_by_path(hctsa_mat);

    fprintf("DONE driver_stage2_macaque_onech_epoch6s: %s\n", hctsa_mat);

catch ME
    fprintf(2, "ERROR in driver_stage2_macaque_onech_epoch6s\n");
    fprintf(2, "%s\n", getReport(ME, "extended", "hyperlinks", "off"));
    rethrow(ME);
end
