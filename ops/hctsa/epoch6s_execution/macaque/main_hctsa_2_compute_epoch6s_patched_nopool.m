% === STAGE2 WRAPPER: dump compute source for reproducibility ===
try; disp("=== COMPUTE SELF DUMP ==="); disp(fileread(mfilename("fullpath"))); catch; end

%compute hctsa_2 on "(species)_(subject)_(channel)_hctsa" using local resources
%
% run this after main_hctsa_1_init.m

% PATCH: wrapper copy from xspecies_blind_classify (HEAD=25df10d)
% Change: allow driver override of species/subject/preprocessSuffix via exist(...)


%% Settings
% addDirPrefs_COS; % disabled: rootDir override handled by bootstrapdirPref = getpref('cosProject','dirPref');
%species = 'macaque';%'human';
%subject = 'George';%'376';
%preprocessSuffix = '_subtractMean_removeLineNoise';

if ~exist("preprocessSuffix","var") || isempty(preprocessSuffix)
  preprocessSuffix = "_subtractMean_removeLineNoise";
end
if ~exist("species","var") || isempty(species)
  species = "macaque";
end
if ~exist("subject","var") || isempty(subject)
  subject = "George";
end


% runTag (optional)
if ~exist("runTag","var") || isempty(runTag)
  runTag = "";
end

rootDir_c = char(dirPref.rootDir);
species_c = char(species);
subject_c = char(subject);
animal_c = regexp(subject_c, '^[^_]+', 'match', 'once');
if isempty(animal_c)
    error("Could not parse animal name from subject_c: %s", subject_c);
end
preprocessSuffix_c = char(preprocessSuffix);
runTag_c = char(runTag);

load_dir = fullfile(rootDir_c, "preprocessed_epoch6s", species_c, subject_c);

if isempty(runTag_c)
  save_base_c = ['hctsa' preprocessSuffix_c];
else
  save_base_c = ['hctsa' preprocessSuffix_c '_' runTag_c];
end
save_dir = fullfile(rootDir_c, save_base_c, species_c, subject_c);
save_dir = char(save_dir);


% normalize paths for exist()
load_dir = char(load_dir);
save_dir = char(save_dir);


%data_server = '<INTERNAL_DATA_SHARE>/COSproject';
%hctsa_dir = fullfile(data_server,'hctsa_space_subtractMean_removeLineNoise/');
%hctsa_mat = 'HCTSA_validate1_ch65.mat';

%% load channels to process
if ~exist("tgtChannels","var") || isempty(tgtChannels)
    load(fullfile(load_dir, ['detectChannels_' subject_c '.mat']), "tgtChannels");
end
%load('selectedCh_20230909','selectedCh');


% STAGE2_NOPARPOOL %% prepare parallel computation
% STAGE2_NOPARPOOL nCores = feature('numcores');
% STAGE2_NOPARPOOL p = gcp('nocreate');
% STAGE2_NOPARPOOL if isempty(p)
% STAGE2_NOPARPOOL     parpool(nCores);
% STAGE2_NOPARPOOL end
add_toolbox; %this is critical to run TS_Compute successfully
force_findpeaks_matlab();

%human: 3h per channel (200ms x 400 trials)
for ich = 1:numel(tgtChannels)
    disp([num2str(ich), '/' num2str(numel(tgtChannels))]);
    thisCh = tgtChannels(ich);

     savedata_prefix = sprintf('%s_%s_ch%03d', species_c, animal_c, thisCh);
    hctsaName = fullfile(save_dir, [savedata_prefix '_hctsa.mat']);

    tic;
    TS_Compute(true, [], [], [], hctsaName);
    t = toc
end
