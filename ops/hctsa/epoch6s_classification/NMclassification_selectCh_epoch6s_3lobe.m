%
% Minimal wrapper for 6-sec / 3-lobe / 9-channel analysis
% Purpose:
%   - run nearest-median classifier for each matched channel pair
%   - save per-pair results that compareValidation_epoch6s_3lobe.m can read
%
% Notes:
%   - Panel B is the current priority, so optional Stage-1-style barcode / histogram
%     figures are intentionally omitted for robustness.
%   - detectChannels uses Stage-1 channel definitions reduced to 3 lobes.
%   - HCTSA inputs use 6-sec canonicalized paths.

%% Optional array support
% For manual execution on login node / VS Code:
% disable SLURM array splitting
narrays = 1;
pen = 1;


%% Settings
add_toolbox_COS;

repo_root = '<PROJECT_ROOT>/repos/xspecies_blind_classify';
addpath(genpath(repo_root));
disp('which NMclassifier_cv:');
disp(which('NMclassifier_cv'));

param = getParam;
dirPref = getpref('cosProject','dirPref');

htcsaType = 'TS_DataMat';
preprocessSuffix = '_subtractMean_removeLineNoise';
svm = false; %#ok<NASGU>

% Species
species_train = 'macaque';
species_validate = 'human';

% Subject names for detectChannels
subject_train_detect = 'George';
subject_validate_detect = '376';

% Subject names used in 6-sec HCTSA TimeSeries.Name / output naming
subject_train_hctsa = 'George_20120803_l';
subject_validate_hctsa = '376_2020_anesthesia_l';

% Conditions
refCodeStrings = {'DN_rms', ...
    'MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1'}; %#ok<NASGU>
condNames = {'awake','unconscious'};

% detectChannels paths
load_dir_train = fullfile(dirPref.rootDir, 'preprocessed', species_train, subject_train_detect);
load_dir_validate = fullfile(dirPref.rootDir, 'preprocessed', species_validate, subject_validate_detect);

detect_file_train = 'detectChannels_George_3lobe.mat';
detect_file_validate = 'detectChannels_376_3lobe.mat';

% 6-sec HCTSA dirs
hctsa_dir_train = '<PROJECT_ROOT>/COSproject/hctsa_epoch6s_macaque_canonical/George_20120803_l';
hctsa_dir_validate = '<PROJECT_ROOT>/COSproject/hctsa_subtractMean_removeLineNoise_epoch6s_human_54608906/human/376_2020_anesthesia_l';

% Output dir
save_dir = fullfile(char(dirPref.rootDir), ['results' preprocessSuffix '_epoch6s_3lobe']);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

%% Load 3-lobe channel definitions
tmp = load(fullfile(load_dir_train, detect_file_train), 'tgtChannels');
tgtChannels_train = tmp.tgtChannels;

tmp = load(fullfile(load_dir_validate, detect_file_validate), 'tgtChannels');
tgtChannels_validate = tmp.tgtChannels;

clear tmp;

% Optional smoke test: set to 1 for one pair, [] for all
run_only_jid = [];

if isempty(run_only_jid)
    tgtIdx = 1:numel(tgtChannels_train);
else
    tgtIdx = run_only_jid;
end

jid_list = pen:narrays:numel(tgtIdx);
errorID = [];

disp('tgtChannels_train=');
disp(tgtChannels_train);
disp('tgtChannels_validate=');
disp(tgtChannels_validate);
disp('jid_list=');
disp(jid_list);

for ii = 1:numel(jid_list)

    JID = tgtIdx(jid_list(ii));
    disp([num2str(ii) '/' num2str(numel(jid_list)) ' (JID=' num2str(JID) ')']);

    try
        ch_train = tgtChannels_train(JID);

        % Load train data once
        file_string_train = fullfile(hctsa_dir_train, sprintf('macaque_George_ch%03d_hctsa', ch_train));
        train_mat = char(string(file_string_train) + ".mat");
        trainData = load(train_mat, 'Operations', 'TS_DataMat', 'TimeSeries', 'TS_Normalised');

        % Two validations:
        %   vv=1 -> macaque self-validation
        %   vv=2 -> human cross-species validation
        for vv = 1:2

            switch vv
                case 1
                    species_validate_this = species_train;
                    subject_validate_this = subject_train_hctsa;
                    ch_validate = tgtChannels_train(JID);
                    file_string_validate = fullfile(hctsa_dir_train, sprintf('macaque_George_ch%03d_hctsa', ch_validate));

                case 2
                    species_validate_this = species_validate;
                    subject_validate_this = subject_validate_hctsa;
                    ch_validate = tgtChannels_validate(JID);
                    file_string_validate = fullfile(hctsa_dir_validate, sprintf('human_376_2020_anesthesia_l_ch%03d_hctsa', ch_validate));
            end

            validate_mat = char(string(file_string_validate) + ".mat");
            validateData = load(validate_mat, 'Operations', 'TS_DataMat', 'TimeSeries', 'TS_Normalised');

            % Subject labels used by helper functions if needed later
            subjectNames_this = { ...
                ['subject:' subject_train_hctsa], ...
                ['subject:' subject_validate_this] ...
                }; %#ok<NASGU>

            % Main classifier
            [classifier_cv, ~] = NMclassifier_cv(trainData, validateData, param.ncv, [], htcsaType);

            % Accuracy significance
            accuracy = mean(classifier_cv.accuracy_validate, 2)';
            accuracy_rand = mean(classifier_cv.accuracy_validate_rand, 2)';

            [nsig_accuracy, p_accuracy, p_fdr_accuracy_th, ~, sig_thresh_accuracy_fdr] = ...
                get_sig_features(accuracy, accuracy_rand, classifier_cv.validFeatures, param.alpha, param.q);

            % Consistency
            [consisetencies, consistencies_random] = ...
                getConsistency(trainData.TS_DataMat, trainData.TimeSeries, condNames);

            consistency = mean(consisetencies, 3);
            consistency_rand = mean(consistencies_random, 3);

            [nsig_consistency, p_consistency, p_fdr_consistency_th, ~, sig_thresh_consistency_fdr] = ...
                get_sig_features(consistency, consistency_rand, classifier_cv.validFeatures, param.alpha, param.q);

            % Save pair result
            out_file = fullfile(save_dir, sprintf('%s_train_%s_%s_ch%03d_validate_%s_%s_ch%03d_accuracy.mat', ...
                htcsaType, species_train, subject_train_hctsa, ch_train, ...
                species_validate_this, subject_validate_this, ch_validate));

            save(out_file, ...
                'classifier_cv', ...
                'p_fdr_consistency_th', 'p_consistency', ...
                'p_fdr_accuracy_th', 'p_accuracy', ...
                'consisetencies', 'consistencies_random', ...
                'nsig_consistency', 'nsig_accuracy', ...
                'sig_thresh_consistency_fdr', 'sig_thresh_accuracy_fdr');

            fprintf('[saved] %s\n', out_file);

            clear validateData classifier_cv ...
                accuracy accuracy_rand ...
                nsig_accuracy p_accuracy p_fdr_accuracy_th sig_thresh_accuracy_fdr ...
                consisetencies consistencies_random ...
                consistency consistency_rand ...
                nsig_consistency p_consistency p_fdr_consistency_th sig_thresh_consistency_fdr;
        end

        clear trainData;

    catch err
        errorID = [errorID; JID];
        disp(getReport(err, 'extended'));
        rethrow(err);
    end
end

disp('error ID:');
disp(errorID);