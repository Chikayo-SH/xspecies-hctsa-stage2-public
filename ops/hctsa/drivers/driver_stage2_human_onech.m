% driver_stage2_human_onech.m (Stage2 wrapper, fixed)
try
    disp("=== DRIVER SELF DUMP ===");
    disp(fileread(mfilename("fullpath")));
catch
end

SUBJECT = getenv("SUBJECT");
CH = str2double(getenv("CH"));
runTag = getenv("RUN_TAG");

species = "human";
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

STAGE2_BASE = "<PROJECT_ROOT>/01_raw/from_daisuke_stage2_preprocessed/COSproject/Stage_2/preprocessed/human";
load_dir = fullfile(STAGE2_BASE, char(subject));
tgtChannels = CH;

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
