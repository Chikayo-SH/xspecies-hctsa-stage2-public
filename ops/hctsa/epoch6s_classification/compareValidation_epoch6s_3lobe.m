% compare classification accuracy between human and macaque
% using the same classifier trained with macaque data in
% NMclassification_selectCh_epoch6s_3lobe.m

%% Settings
add_toolbox_COS;

repo_root = '<PROJECT_ROOT>/repos/xspecies_blind_classify';
addpath(genpath(repo_root));

viz_root = '<PROJECT_ROOT>/Toolboxes/xspecies_extra/visualization_unzipped/visualization';
addpath(viz_root);

disp('which squareplot:');
disp(which('squareplot'));

addDirPrefs_COS;
preprocessSuffix = '_subtractMean_removeLineNoise';
htcsaType = 'TS_DataMat';

refCodeStrings = {'DN_rms', ...
    'MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1'};

species_train = 'macaque';
species_validate = 'human';

subject_train_detect = 'George';
subject_validate_detect = '376';

subject_train_hctsa = 'George_20120803_l';
subject_validate_hctsa = '376_2020_anesthesia_l';

condNames = {'awake','unconscious'};

% Use explicit paths instead of dirPref.rootDir
load_dir = '<PROJECT_ROOT>/COSproject_A/results_subtractMean_removeLineNoise_epoch6s_3lobe';

channel_dir_train = '<PROJECT_ROOT>/COSproject_A/preprocessed/macaque/George';
channel_dir_validate = '<PROJECT_ROOT>/COSproject/preprocessed/human/376';

load(fullfile(channel_dir_train, 'detectChannels_George_3lobe.mat'), 'tgtChannels', 'channelsByLobe', 'lobeNames');
tgtChannels_train = tgtChannels;
channelsByLobe_train = channelsByLobe;
lobeNames_train = lobeNames;

load(fullfile(channel_dir_validate, 'detectChannels_376_3lobe.mat'), 'tgtChannels', 'channelsByLobe', 'lobeNames');
tgtChannels_validate = tgtChannels;
channelsByLobe_validate = channelsByLobe;
lobeNames_validate = lobeNames;

clear tmp;

errorID = [];
refOperation_idx = [];

for JID = 1:numel(tgtChannels_train)
    disp(JID);

    mean_accuracy = [];
    validFeatures = [];
    sig_thresh_accuracy_fdr = [];
    p_fdr_accuracy_th = [];

    ch_train = tgtChannels_train(JID);

    for vv = 1:2
        switch vv
            case 1
                species_validate_this = species_train;
                subject_validate_this = subject_train_hctsa;
                ch_validate = tgtChannels_train(JID);

            case 2
                species_validate_this = species_validate;
                subject_validate_this = subject_validate_hctsa;
                ch_validate = tgtChannels_validate(JID);
        end

        out_file = fullfile(load_dir, sprintf('%s_train_%s_%s_ch%03d_validate_%s_%s_ch%03d_accuracy.mat', ...
            htcsaType, species_train, subject_train_hctsa, ch_train, ...
            species_validate_this, subject_validate_this, ch_validate));

        fprintf('[JID=%d] ch_train=%03d\n', JID, ch_train);
        disp(out_file);

        data = load(out_file, ...
            'classifier_cv', ...
            'p_fdr_consistency_th', 'p_consistency', ...
            'p_fdr_accuracy_th', 'p_accuracy', ...
            'consisetencies', 'consistencies_random', ...
            'nsig_consistency', 'nsig_accuracy', ...
            'sig_thresh_accuracy_fdr');

        mean_accuracy(:,vv) = mean(data.classifier_cv.accuracy_validate, 2);
        validFeatures(:,vv) = data.classifier_cv.validFeatures;
        p_fdr_accuracy_th(vv) = data.p_fdr_accuracy_th;
        sig_thresh_accuracy_fdr(vv) = data.sig_thresh_accuracy_fdr;
        sigFeatures(:,JID,vv) = data.nsig_accuracy;

        ch_string{vv} = [species_validate_this '-ch' num2str(ch_validate)];

        [~, best_accuracy_idx(vv)] = max(mean_accuracy(:,vv));
        bestOperation_c{vv} = replace(data.classifier_cv.operations.CodeString(best_accuracy_idx(vv)), '_','-');

        if isempty(refOperation_idx)
            for ss = 1:numel(refCodeStrings)
                refOperation_idx(ss) = find(strcmp(data.classifier_cv.operations.CodeString, refCodeStrings{ss}), 1);
            end
        end
    end

    bestOperation{JID} = bestOperation_c{2}; %#ok<NASGU>

    allValid = sum(validFeatures,2) == 2;
    nSig_accuracy(JID,1) = sum(sigFeatures(allValid,JID,1));
    nSig_accuracy(JID,2) = sum(sigFeatures(allValid,JID,2));
    nSig_accuracy(JID,3) = sum(sigFeatures(allValid,JID,1) .* sigFeatures(allValid,JID,2));

    mean_accuracy_all(JID,1,:) = mean_accuracy(:,1);
    mean_accuracy_all(JID,2,:) = mean_accuracy(:,2);
    validFeatures_all(JID,:,:) = validFeatures;

    %% scatter plot accuracy per pair
    figure('position',[0 0 1000 500]);

    subplot(121);
    plot(mean_accuracy(allValid,1), mean_accuracy(allValid,2), '.', 'Color', [.5 .5 .5]); hold on;
    nSig_accuracy_both = logical(sigFeatures(:,JID,1) .* sigFeatures(:,JID,2));
    plot(mean_accuracy(nSig_accuracy_both,1), mean_accuracy(nSig_accuracy_both,2), 'k.');

    if ~isempty(refOperation_idx) && all(~isnan(refOperation_idx))
        plot(mean_accuracy(refOperation_idx(2),1), mean_accuracy(refOperation_idx(2),2), 'ro');
        plot(mean_accuracy(refOperation_idx(1),1), mean_accuracy(refOperation_idx(1),2), 'go');
    end

    xlabel(ch_string{1});
    ylabel(ch_string{2});
    squareplot;
    vline([sig_thresh_accuracy_fdr(1)], gca,'-','b');
    vline(.5, gca,'-','k');
    hline([sig_thresh_accuracy_fdr(2)], gca,'-','b');
    hline(.5, gca,'-','k');
    set(gca,'tickdir','out');
    axis padded;

    subplot(122);
    RowName = {'sig(Human)', 'nsig(Human)'};
    ColumnName = {'-','nsig(Macque)','sig(Macaque)'};

    Age = [ ...
        sum(~sigFeatures(allValid,JID,1) .* sigFeatures(allValid,JID,2)), ...
        sum(~sigFeatures(allValid,JID,1) .* ~sigFeatures(allValid,JID,2)) ...
        ];

    Height = [ ...
        sum(sigFeatures(allValid,JID,1) .* sigFeatures(allValid,JID,2)), ...
        sum(sigFeatures(allValid,JID,1) .* ~sigFeatures(allValid,JID,2)) ...
        ];

    T = table(RowName', Age', Height', 'VariableNames', ColumnName, 'RowNames', RowName);

    tableCell = [T.Properties.VariableNames; table2cell(T)];
    tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)), 'UniformOutput', false);
    tableChar = splitapply(@strjoin, pad(tableCell), [1;2;3]);
    set(gca,'position',[0.5,0.1,0.3,0.3], 'Visible','off');
    text(.2, .95, tableChar, 'VerticalAlignment','Top', 'HorizontalAlignment','Left', 'FontName','Arial');

    %savePaperFigure(gcf, fullfile(load_dir, ['bestAccuracyHists_train_' ch_string{1} '_validate_' ch_string{2}]));
    pair_fig_base = fullfile(load_dir, ['bestAccuracyHists_train_' ch_string{1} '_validate_' ch_string{2}]);
    saveas(gcf, [pair_fig_base '.fig']);
    saveas(gcf, [pair_fig_base '.png']);
    close;
end

%% save results
save(fullfile(load_dir, 'compareValidation.mat'), 'validFeatures_all', 'mean_accuracy_all', 'sigFeatures', 'nSig_accuracy');

%% summary figure (Panel B style)
figure('position',[0 0 600 800]);

subplot(211);
if ~isempty(refOperation_idx) && all(~isnan(refOperation_idx))
    plot(find(sigFeatures(refOperation_idx(1),:,1)), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,1)),1,refOperation_idx(1)), 'gs', 'MarkerSize',7, 'LineWidth',2); hold on;
    plot(find(sigFeatures(refOperation_idx(1),:,2)), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,2)),2,refOperation_idx(1)), 'go', 'MarkerSize',7, 'LineWidth',2);
    plot(find(sigFeatures(refOperation_idx(2),:,1)), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,1)),1,refOperation_idx(2)), 'rs', 'MarkerSize',7, 'LineWidth',2);
    plot(find(sigFeatures(refOperation_idx(2),:,2)), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,2)),2,refOperation_idx(2)), 'ro', 'MarkerSize',7, 'LineWidth',2);

    plot(find(sigFeatures(refOperation_idx(1),:,1)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,1)==0),1,refOperation_idx(1)), 'gs', 'MarkerSize',7, 'LineWidth',.5);
    plot(find(sigFeatures(refOperation_idx(1),:,2)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,2)==0),2,refOperation_idx(1)), 'go', 'MarkerSize',7, 'LineWidth',.5);
    plot(find(sigFeatures(refOperation_idx(2),:,1)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,1)==0),1,refOperation_idx(2)), 'rs', 'MarkerSize',7, 'LineWidth',.5);
    plot(find(sigFeatures(refOperation_idx(2),:,2)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,2)==0),2,refOperation_idx(2)), 'ro', 'MarkerSize',7, 'LineWidth',.5);
end

axis padded square;
ylim([0.35 0.9]);
vline([3.5 6.5]); hline(.5);
set(gca,'tickdir','out','xtick',[2 5 8],'XTickLabel',{'Parietal','Temporal','Frontal'},'box','off');
xlim([0.5 9.5]);
ylabel('accuracy');
legend('macaque','human','location','southeast');

subplot(212);
plot(nSig_accuracy(:,1), 'ks', 'MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy(:,2), 'ko', 'MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy(:,3), 'kx', 'MarkerSize',7, 'LineWidth',2); hold on;
axis padded square;
ylim([0 5500]);
vline([3.5 6.5]);
set(gca,'tickdir','out','xtick',[2 5 8],'XTickLabel',{'Parietal','Temporal','Frontal'},'box','off');
xlim([0.5 9.5]);
ylabel('#sig. features');
legend('macaque','human','both','location','southeast');

%savePaperFigure(gcf, fullfile(load_dir, 'nsig_accuracy'));
pair_fig_base = fullfile(load_dir, ['bestAccuracyHists_train_' ch_string{1} '_validate_' ch_string{2}]);
saveas(gcf, [pair_fig_base '.fig']);
saveas(gcf, [pair_fig_base '.png']);

%% stats
mean(nSig_accuracy(:,3))
std(nSig_accuracy(:,3))

%% valid features for method
validFeatures_all_2D = reshape(permute(validFeatures_all, [2 1 3]), 7755, []);
for ich = 1:size(validFeatures_all_2D,2)
    nValidFeatures(ich) = sum(validFeatures_all_2D(:,ich));
end
mean(nValidFeatures)
std(nValidFeatures)