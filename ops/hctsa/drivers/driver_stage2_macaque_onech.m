% driver_stage2_macaque_onech.m (Stage2 wrapper, based on human)
try
    disp("=== DRIVER SELF DUMP ===");
    disp(fileread(mfilename("fullpath")));
catch
end

SUBJECT = getenv("SUBJECT");      % e.g., "Chibi_20120730"
CH = str2double(getenv("CH"));
runTag = getenv("RUN_TAG");
isDry = getenv("DRYRUN");         % if "1", exit after input check

species = "macaque";
subject = string(SUBJECT);
preprocessSuffix = "_subtractMean_removeLineNoise";

if strlength(subject) == 0, error("ENV SUBJECT is empty"); end
if isnan(CH), error("ENV CH is not a number"); end
if strlength(runTag) == 0, error("ENV RUN_TAG is empty"); end

disp("=== DRIVER PARAMS ===");
disp("species=" + species);
disp("subject=" + subject);
disp("ch=" + string(CH));
disp("preprocessSuffix=" + preprocessSuffix);
disp("runTag=" + runTag);

WRAP  = "<PROJECT_ROOT>/04_pipelines/xspecies_wrapper";
WRAP2 = "<PROJECT_ROOT>/04_pipelines/xspecies_wrapper_stage2";

STAGE2_BASE = "<PROJECT_ROOT>/01_raw/from_daisuke_stage2_preprocessed/COSproject/Stage_2/preprocessed/macaque";
load_dir = fullfile(STAGE2_BASE, char(subject));
tgtChannels = CH;

expected_in = fullfile(load_dir, sprintf("macaque_%s_ch%03d%s.mat", char(subject), CH, preprocessSuffix));
if ~isfile(expected_in)
    error("Expected input not found: %s (did you create symlinks?)", expected_in);
end
disp("expected_in=" + string(expected_in));

if strcmp(isDry, "1")
    disp("=== DRIVER DRYRUN EXIT ===");
    return;
end

force_findpeaks_matlab();
disp("=== WHICH -ALL (findpeaks) ===");
disp(evalc("which -all findpeaks"));

try
    disp("=== COMPUTE SOURCE DUMP ===");
    disp(fileread(fullfile(WRAP2, "main_hctsa_2_compute_local_patched_nopool.m")));
catch
end

cd(WRAP);  main_hctsa_1_init_patched;
cd(WRAP2); main_hctsa_2_compute_local_patched_nopool;

disp("=== DRIVER DONE ===");
