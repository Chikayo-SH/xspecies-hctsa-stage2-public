save_dir = get_xspecies_env_dir("XSPECIES_STAGE2_ANALYSIS_DIR", fullfile("data", "Stage2analysis"));
load(fullfile(save_dir, 'data','data_figure5.mat'),'data_barcode',...
    'sig_accuracy_combo_sbj_all','nSig_accuracy_combo_sbj_all', ...
    'Operations','nSig_accuracy_combo_withinLobe', ...
    'validFeatures_allsbjch','accuracy_combo',...
     'channelCombo_all','ll','condNames',...
    'refCodeStrings','refOperation_idx');

accuracy_combo_sbj_m = mean(accuracy_combo,4); %mean across samples
out_file = fullfile(save_dir, 'figure');

%% channnel location (Fig 5A)
ilobe = 3; itrainCh = 3;isample = 1;
tgtlobe = 'frontal';
for ss = 1:2
    switch ss
        case 1
            species_validate = 'macaque';
            nsid = 3;

        case 2
            species_validate = 'human';
            nsid = 10;
    end
    fig_channel =  figure('position',[0 0 2400 300]);
    t = tiledlayout(1, nsid, 'TileSpacing', 'compact', 'Padding', 'compact');

    tgtChannelsInLobe_tmp = cell(nsid,1);
    suffix_tmp = cell(nsid,1);
    for sid = 1:nsid
        [tgtChannelsInLobe_tmp{sid}, suffix_tmp{sid}] = ...
            getAllChannels(species_validate, sid, tgtlobe);
    end

    for sid = 1:nsid
        

        nexttile;
        [channelId, MNIX, MNIY, MNIZ, LOBE, sideImage, subject_date] = ...
            getChannelLocationOnCtx(species_validate, sid);

        thisAx = gca;%theseAx(sid);
        thisAx = topoplot(thisAx, [], MNIY, MNIZ, LOBE, sideImage, [],'side',0); hold on
        channelCombo = channelCombo_all{ilobe, ss, itrainCh};
        thisCh = tgtChannelsInLobe_tmp{sid}(channelCombo(isample, sid));
        thisChIdx = find(ismember(channelId, thisCh));
        thisAx = topoplot(thisAx, [], MNIY(thisChIdx), ...
            MNIZ(thisChIdx), LOBE(thisChIdx), [], [],'side',1);
        switch species_validate
            case 'macaque'
                xlim(thisAx,[0 1000]); ylim(gca, [0 1200]);
            case 'human'
                xlim(thisAx,[-75 75]); ylim(gca, [-60 60]);
        end
        axis xy equal off;
        title(thisAx, subject_date);
    end

    savePaperFigure( ...
        fig_channel, ...
        fullfile(out_file, [species_validate '_channelLocation']));
    close(fig_channel);
end

%% hctsa feature value and accuracy barcodes 
for ss = 1:2

    switch ss
        case 1
            species_validate = 'macaque';
            nsid = 3;

        case 2
            species_validate = 'human';
            nsid = 10;
    end
    fig_barcode = showHCTSAbarcodes( ...
        data_barcode{ss}.data, ...
        data_barcode{ss}.TimeSeries, ...
        ll.order_f, ...
        data_barcode{ss}.order_e(1,:), ...
        Operations.CodeString, ...
        refCodeStrings, ...
        condNames);
    savePaperFigure( ...
        fig_barcode, ...
        fullfile(out_file, [species_validate '_HCTSA_barcode']));
    close(fig_barcode);

    fig_accuracy = showAccuracybarcodes( ...
        data_barcode{ss}.accuracy', ...
        ll.order_f, ...
        Operations.CodeString, ...
        refCodeStrings);

    savePaperFigure( ...
        fig_accuracy, ...
        [out_file '_' species_validate '_Accuracy_barcode']);
end

%% Figure 5D
ax=subplot(131);
nsigFeatures = find(squeeze(sig_accuracy_combo_sbj_all(:,JID,3)==0).*validFeatures_allsbjch);
sigFeatures = find(squeeze(sig_accuracy_combo_sbj_all(:,JID,3)==1).*validFeatures_allsbjch);

plot(accuracy_combo_sbj_m(nsigFeatures,JID,1), accuracy_combo_sbj_m(nsigFeatures,JID,2),'.','color',[.5 .5 .5]); hold on;
plot(accuracy_combo_sbj_m(sigFeatures,JID,1), accuracy_combo_sbj_m(sigFeatures,JID,2),'k.'); hold on;
plot(accuracy_combo_sbj_m(refOperation_idx(2),JID,1), accuracy_combo_sbj_m(refOperation_idx(2),JID,2),'ro')
plot(accuracy_combo_sbj_m(refOperation_idx(1),JID,1), accuracy_combo_sbj_m(refOperation_idx(1),JID,2),'go')

ylabel('Classification Accuracy (Human)');
xlabel('Classification Accuracy (Macaque)');

axis tight;
squareplot;
axis padded

[bestAccuracy, bestOperation_idx] = max(accuracy_combo_sbj_m(:,JID,:),[], 1);
bestOperation_name = table2cell(Operations(squeeze(bestOperation_idx),2));
disp(['The best performing feature for macaque: ' bestOperation_name{1} ', accuracy:' num2str(bestAccuracy(1))]);
disp(['The best performing feature for macaque: ' bestOperation_name{2} ', accuracy:' num2str(bestAccuracy(2))]);

%% Figure 5E
subplot(132);
plot(squeeze(accuracy_combo_sbj_m(refOperation_idx(2),:,1)),'rs','MarkerSize',7, 'LineWidth',2);hold on; %monkey
plot(squeeze(accuracy_combo_sbj_m(refOperation_idx(2),:,2)),'ro','MarkerSize',7, 'LineWidth',2);%human
plot(squeeze(accuracy_combo_sbj_m(refOperation_idx(1),:,1)),'gs','MarkerSize',7, 'LineWidth',2);hold on; %monkey
plot(squeeze(accuracy_combo_sbj_m(refOperation_idx(1),:,2)),'go','MarkerSize',7, 'LineWidth',2);%human
axis  padded square;
ylim([0.3 0.8]);
vline([6.5 9.5]); hline(.5);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},...
    'ytick',0.3:0.1:0.8,'box','off');
xlim([3.5 12.5]);
ylabel('Accuracy');
legend('macaque','human','location','northwest');

disp(['feature Y performed ' num2str(prctile(squeeze(accuracy_combo_sbj_m(refOperation_idx(2),10:12,1)),[0 100])) 'in frontal lobe in macaque'])
disp(['feature Y performed ' num2str(prctile(squeeze(accuracy_combo_sbj_m(refOperation_idx(2),10:12,2)),[0 100])) 'in frontal lobe in human'])


%% Figure 5F
subplot(133);
plot(nSig_accuracy_combo_sbj_all(:,1),'ks','MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy_combo_sbj_all(:,2),'ko','MarkerSize',7, 'LineWidth',2); hold on;
plot(nSig_accuracy_combo_sbj_all(:,3),'kx','MarkerSize',7, 'LineWidth',2); hold on;

disp(['#sig features in parietal: ' num2str(min(nSig_accuracy_combo_sbj_all(4:6,3))) '-' num2str(max(nSig_accuracy_combo_sbj_all(4:6,3))),...
    ', temporal: ' num2str(min(nSig_accuracy_combo_sbj_all(7:9,3))) '-' num2str(max(nSig_accuracy_combo_sbj_all(7:9,3))), ...
    ', frontal: ' num2str(min(nSig_accuracy_combo_sbj_all(10:12,3))) '-' num2str(max(nSig_accuracy_combo_sbj_all(10:12,3)))])

disp(['#sig features common within each lobe. parietal:' num2str(nSig_accuracy_combo_withinLobe(1,3)),...
    ', temporal:' num2str(nSig_accuracy_combo_withinLobe(2,3)), ...
    ', frontal:' num2str(nSig_accuracy_combo_withinLobe(3,3))]);
axis padded square;
ylim([0 5500])
vline([6.5 9.5]);
set(gca,'tickdir','out','xtick',[2 5 8 11],'XTickLabel',{'Occipital','Parietal','Temporal','Frontal'},...
    'ytick',0:1000:5000,'box','off');
xlim([3.5 12.5]);
ylabel('#significant features');
legend('macaque','human','both','location','northwest');

savePaperFigure(f, fullfile(save_dir,'figure','accuracy_allsbj_rand'));
