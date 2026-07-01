load_dir = get_xspecies_env_dir("XSPECIES_STAGE1_REANALYSIS_DIR", fullfile("data", "Stage1reanalysis"));
load(fullfile(load_dir,'data_figure4'),'validFeatures_all',...
    "mean_accuracy_all",'sigFeatures','nSig_accuracy',...
    'refCodeStrings','refOperation_idx');

%% accuracy
figure('position',[0 0 600 800])
subplot(211);
plot(find(sigFeatures(refOperation_idx(1),:,1)), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,1)),1,refOperation_idx(1)),'gs','MarkerSize',7, 'LineWidth',2)%monkey
hold on;
plot(find(sigFeatures(refOperation_idx(1),:,2)), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,2)),2,refOperation_idx(1)),'go','MarkerSize',7, 'LineWidth',2)%human
plot(find(sigFeatures(refOperation_idx(2),:,1)), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,1)),1,refOperation_idx(2)),'rs','MarkerSize',7, 'LineWidth',2)%monkey
plot(find(sigFeatures(refOperation_idx(2),:,2)), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,2)),2,refOperation_idx(2)),'ro','MarkerSize',7, 'LineWidth',2)%human

plot(find(sigFeatures(refOperation_idx(1),:,1)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,1)==0),1,refOperation_idx(1)),'gs','MarkerSize',7, 'LineWidth',.5)%monkey
plot(find(sigFeatures(refOperation_idx(1),:,2)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(1),:,2)==0),2,refOperation_idx(1)),'go','MarkerSize',7, 'LineWidth',.5)%human
plot(find(sigFeatures(refOperation_idx(2),:,1)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,1)==0),1,refOperation_idx(2)),'rs','MarkerSize',7, 'LineWidth',.5)%monkey
plot(find(sigFeatures(refOperation_idx(2),:,2)==0), mean_accuracy_all(find(sigFeatures(refOperation_idx(2),:,2)==0),2,refOperation_idx(2)),'ro','MarkerSize',7, 'LineWidth',.5)%human
axis  padded square;
ylim([0.35 0.9]); 
vline([6.5 9.5]); hline(.5);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},'box','off');
xlim([3.5 12.5]);
ylabel('accuracy');
legend('macaque','human','location','southeast');

subplot(212);
plot(nSig_accuracy(:,1),'ks','MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy(:,2),'ko','MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy(:,3),'kx','MarkerSize',7, 'LineWidth',2); hold on;
axis padded square;
ylim([0 5500])
vline([6.5 9.5]);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},'box','off');
xlim([3.5 12.5]);
ylabel('#sig. features');
legend('macaque','human','both','location','southeast');

savePaperFigure(gcf,fullfile(load_dir,'nsig_accuracy'))

%% stats
disp([num2str(mean(nSig_accuracy(4:12,3))) '+-' num2str(std(nSig_accuracy(4:12,3))) ' features that performed significantly above chance level in both macaque and human recordings'])

%% for fig2 explanation
mean_accuracy_all(12,:,refOperation_idx(1)) %RMS
mean_accuracy_all(12,:,refOperation_idx(2)) %MF

%% valid features for method
validFeatures_all_2D = reshape(permute(validFeatures_all(4:end,:,:), [2 1 3]), 7755,[]);
for ich = 1:size(validFeatures_all_2D,2)
    nValidFeatures(ich) = sum(validFeatures_all_2D(:,ich));
end
disp([num2str(7755-nanmean(nValidFeatures)) '+-' num2str(nanstd(nValidFeatures)) ' features were excluded from further analysis'])