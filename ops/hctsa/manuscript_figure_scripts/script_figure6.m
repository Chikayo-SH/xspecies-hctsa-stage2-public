save_dir = get_xspecies_env_dir("XSPECIES_STAGE2_ANALYSIS_DIR", fullfile("data", "Stage2analysis"));
load(fullfile(save_dir,'data','data_figure6.mat'), 'sig_sedation_combo',...
    "correctRate_su_m",'correctRate_au_m',...
    'validFeatures_allsbjch','sig_accuracy_combo_sbj_all',...
    'tgtOperation_idx','tgtCodeStrings','Operations');

refCodeStrings = tgtCodeStrings([11 5 6]);
refOperation_idx = tgtOperation_idx([11 5 6]);

JID=12;tgtlobe = 'frontal';
sigFeatures_au = find(squeeze(sig_accuracy_combo_sbj_all(:,JID,3)==1).*validFeatures_allsbjch);
nsigFeatures = intersect(find(sig_sedation_combo(:,JID)==0), sigFeatures_au);
sigFeatures = intersect(find(sig_sedation_combo(:,JID)==1), sigFeatures_au);

%% Figure 6A-C
for ss = 1:numel(refCodeStrings) %[5 6 11]
    f = scatter_histogram_3conds( ...
        data_all, ...
        TimeSeries_all, ...
        validFeatures_all, ...
        suffix_local, ...
        refOperation_idx(ss), ...
        yScales(ss), param);

    savePaperFigure( ...
        f, ...
        fullfile(save_dir, 'figure', ...
        [tgtlobe,'_',num2str(itrainCh),'_scatter_hist_3conds_',replace(refCodeStrings{ss},{'_','.'},'-') '_tmp']));
    close(f);
end


%% Figure 6D-F
f = figure('position',[0 0 1200 600]);
ax(1)=subplot(131);
plot(correctRate_au_m(nsigFeatures,JID), correctRate_su_m(nsigFeatures,JID),'.','color',[.5 .5 .5]); hold on;
plot(correctRate_au_m(sigFeatures,JID), correctRate_su_m(sigFeatures,JID),'k.')
plot(correctRate_au_m(refOperation_idx(1),JID), correctRate_su_m(refOperation_idx(1),JID),'ro')
plot(correctRate_au_m(refOperation_idx(2),JID), correctRate_su_m(refOperation_idx(2),JID),'bo')
plot(correctRate_au_m(refOperation_idx(3),JID), correctRate_su_m(refOperation_idx(3),JID),'go')

xlabel('Accuracy awake - unresponsive');
ylabel('Accuracy sedated - unresponsive');
title(tgtlobe);
squareplot;
axis padded;

ax(2)=subplot(132);
plot(squeeze(correctRate_su_m(refOperation_idx(1),:)),'ro','MarkerSize',7, 'LineWidth',2);hold on;%human
plot(squeeze(correctRate_su_m(refOperation_idx(2),:)),'bo','MarkerSize',7, 'LineWidth',2);%human
plot(squeeze(correctRate_su_m(refOperation_idx(3),:)),'go','MarkerSize',7, 'LineWidth',2);%human
axis  padded square;
ylim([0.4 0.7]); 
vline([6.5 9.5]); hline(.5);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},...
    'box','off');
xlim([3.5 13.5]);
ylabel('Accuracy');

correctRate_su_m(refOperation_idx,:)

ax(3)=subplot(133);
sig_3conds_combo = (sig_sedation_combo.*squeeze(sig_accuracy_combo_sbj_all(:,:,3)));
nSig_3conds_combo = sum(sig_3conds_combo,1);
plot(nSig_3conds_combo,'ko','MarkerSize',7, 'LineWidth',2); hold on;
axis padded square;
ylim([0 2000])
vline([6.5 9.5 12.5]);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},...
    'box','off');
xlim([3.5 13.5]);
ylabel('#significant features');

disp(['#sig features in parietal: ' num2str(min(nSig_3conds_combo(4:6))) '-' num2str(max(nSig_3conds_combo(4:6))),...
    ', temporal: ' num2str(min(nSig_3conds_combo(7:9))) '-' num2str(max(nSig_3conds_combo(7:9))), ...
    ', frontal: ' num2str(min(nSig_3conds_combo(10:12))) '-' num2str(max(nSig_3conds_combo(10:12)))])
% savePaperFigure(f, fullfile(save_dir,'figure','3conds_accuracy_allsbj'));

