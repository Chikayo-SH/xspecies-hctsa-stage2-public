%from NMclassification_selectCh.m
save_dir = get_xspecies_env_dir("XSPECIES_STAGE1_REANALYSIS_DIR", fullfile("data", "Stage1reanalysis"));


%% figure 2A
load(fullfile(save_dir, 'data_figure2A'),'data_all',...
    'subjectEpochs','TimeSeries_all','CodeString', ...
    'order_e','order_f','refCodeStrings');

fig = showHCTSAbarcodes(data_all(subjectEpochs{1},:),...
    TimeSeries_all(subjectEpochs{1},:), order_f, order_e(1,:), ...
    CodeString, refCodeStrings);
savePaperFigure(fig,fullfile(save_dir,'HCTSA_barcode_t'));
close(fig);

fig2 = showHCTSAbarcodes(data_all(subjectEpochs{2},:),...
    TimeSeries_all(subjectEpochs{2},:),  order_f, order_e(2,:), ...
    CodeString, refCodeStrings);
savePaperFigure(fig2, fullfile(save_dir,'HCTSA_barcode_v'));
close(fig2)

%% figure 2B
load(fullfile(save_dir,'data_figure2B'),'accuracy_tmp',...
    'order_f','CodeString','refCodeStrings');
fig = showAccuracybarcodes(accuracy_tmp, order_f, CodeString, refCodeStrings);
savePaperFigure(fig,fullfile(save_dir,'accuracy_barcode'));

%% figure 2C,D
load(fullfile(save_dir, 'data_figure2CD'),'data_all',...
    'subjectEpochs','TimeSeries_all','CodeString',...
    'refCodeStrings','order_f','subjectNames','condNames',...
    'species_train','species_validate');

%% proabability histograms for selected features
ff_rc = pdensity_awakeUnconscious(data_all, TimeSeries_all, CodeString, ...
    refCodeStrings{1}, subjectNames, condNames, 'log',20);
savePaperFigure(ff_rc,fullfile(save_dir, replace(refCodeStrings{1},{'_','.'},'-')));
close(ff_rc);

ff_rc = pdensity_awakeUnconscious(data_all, TimeSeries_all, CodeString, ...
    refCodeStrings{2}, subjectNames, condNames,[],20);
savePaperFigure(ff_rc,fullfile(save_dir, replace(refCodeStrings{2},{'_','.'},'-')));
close(ff_rc);
disp(refCodeStrings{2});
disp(['classification accuracy of ' species_validate ', trained on ' species_validate ':' num2str(100*mean(classifier_cv.accuracy_train(refOperation_idx(2),:),2))]);
disp(['classification accuracy of ' species_validate ', trained on ' species_train ':' num2str(100*mean(classifier_cv.accuracy_validate(refOperation_idx(2),:),2))]);
