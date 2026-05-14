%% Description
% PATCH: wrapper copy from xspecies_blind_classify (HEAD=25df10d)
% Change: allow driver override of species/subject/preprocessSuffix via exist(...)



%{

Exclude any feature which has at least 1 NaN value across time series
Exclude any feature which has a constant value across time series

Exclusion is done per channel

% run this after main_hctsa_2
% this script was created from main_hctsa_3_perChannel and
main_hctsa_matrix
%}

%% Settings
% addDirPrefs_COS; % disabled: rootDir override handled by bootstrap

dirPref = getpref('cosProject','dirPref');
assert(isfield(dirPref,'rootDir') && ~isempty(dirPref.rootDir), 'dirPref.rootDir missing');
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
preprocessSuffix_c = char(preprocessSuffix);
runTag_c = char(runTag);

load_dir = fullfile(rootDir_c, "preprocessed", species_c, subject_c);

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


%% load channels to process
load(fullfile(load_dir, ['detectChannels_' subject_c '.mat']), 'tgtChannels');

%% Re-add special values to TS_DataMat
% Note HCTSA replaces special values with 0
%   https://hctsa-users.gitbook.io/hctsa-manual/setup/hctsa_structure#quality-labels

for ch = tgtChannels
    tic;
    %ch_string = ['ch' num2str(ch)];
    %file_string = [load_dir file_prefix '_' ch_string file_suffix];
     file_string = fullfile(save_dir,  sprintf('%s_%s_ch%03d_hctsa', species, subject, ch));

    hctsa = matfile(file_string, 'Writable', true);
    TS_DataMat = hctsa.TS_DataMat;
    TS_Quality = hctsa.TS_Quality;

    % "Fatal" errors - treat as NaN
    TS_DataMat(TS_Quality == 1) = NaN;
    % Special value NaN
    TS_DataMat(TS_Quality == 2) = NaN;
    % Special value Inf
    TS_DataMat(TS_Quality == 3) = Inf;
    % Special value -Inf
    TS_DataMat(TS_Quality == 4) = -Inf;
    % Special value complex
    TS_DataMat(TS_Quality == 5) = NaN;
    % Special value empty
    TS_DataMat(TS_Quality == 6) = NaN;


    % % Check for other cases
    % if any(TS_Quality(:) > 4)
    %     tmp = unique(TS_Quality(:));
    %     disp([file_string ' TS_Quality ' num2str(tmp)]);
    % end

    hctsa.TS_DataMat = TS_DataMat;
    hctsa.TS_Quality = TS_Quality;


    %%  below from main_hctsa_matrix.m
    hctsa.valid_features = getValidFeatures(hctsa.TS_DataMat);

    TS_Normalised = BF_NormalizeMatrix(hctsa.TS_DataMat, 'mixedSigmoid');
    hctsa.TS_Normalised = TS_Normalised;

    toc
end
