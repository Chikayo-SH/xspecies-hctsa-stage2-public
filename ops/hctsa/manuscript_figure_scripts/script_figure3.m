%from compareValidation.m
save_dir = get_xspecies_env_dir("XSPECIES_STAGE1_REANALYSIS_DIR", fullfile("data", "Stage1reanalysis"));
load( fullfile(save_dir, 'data_figure3.mat'),'mean_nEpochs_var','sd_nEpochs_var',"nFeatures_nonconverge_var",...
    'mean_nEpochs_mean','sd_nEpochs_mean',"nFeatures_nonconverge_mean",'JID','accuracy','sigFeatures','nEpochs_t','refOperation_idx','refCodeStrings');


lcolors = [1 0 0];
figure('position',[0 0 800 900]);
for itv = 1:2
    for ss = 1:numel(refCodeStrings)
        accuracy_c = squeeze(accuracy(:,itv,refOperation_idx(ss),:));
        maccuracy = squeeze(mean(accuracy_c, 2));
        sdaccuracy = squeeze(std(accuracy_c, [], 2));

        ax(itv,1) = subplot(3,2, itv);
        plot(2*nEpochs_t, squeeze(maccuracy),'-o','color',lcolors(ss,:));hold on;
        set(ax(itv,1),'XScale','log','xtick',2*nEpochs_t)
        axis padded


        %t test for mean
        pf_ori = zeros(numel(nEpochs_t)-1,1);
        groups = cell(1,numel(nEpochs_t)-1);
        for ix = 1:numel(nEpochs_t)-1
            %[~,pf_ori(ix)] = vartest2(accuracy_c(ix,:), accuracy_c(end,:)); %F-test for variance
            %pf_ori(ix) = ranksum(accuracy_c(ix,:), accuracy_c(end,:)); %mann-whitney U test for equality of population medians. weak
            [~, pf_ori(ix)] = ttest2(accuracy_c(ix,:), accuracy_c(end,:),'Vartype','unequal');
            groups{ix} = [2*nEpochs_t(ix) 2*nEpochs_t(end)];
        end
        pf_corrected = pf_ori*(numel(nEpochs_t)-1);
        noshow = pf_corrected>0.05;
        groups(noshow) = [];
        pf_corrected(noshow) = [];

        hstar = sigstar(groups, pf_corrected);
        set(hstar,'color',lcolors(ss,:));

        ax(itv,2) = subplot(3,2, itv+2);
        plot(2*nEpochs_t, squeeze(sdaccuracy),'-o','color',lcolors(ss,:));hold on;
        set(ax(itv,2),'XScale','log','xtick',2*nEpochs_t)
        axis padded

        % f test for variance
        pf_ori = zeros(numel(nEpochs_t)-1,1);
        groups = cell(1,numel(nEpochs_t)-1);
        for ix = 1:numel(nEpochs_t)-1
            [~,pf_ori(ix)] = vartest2(accuracy_c(ix,:), accuracy_c(end,:)); %F-test for variance
            %pf_ori(ix) = ranksum(accuracy_c(ix,:), accuracy_c(end,:)); %mann-whitney U test for equality of population medians. weak
            groups{ix} = [2*nEpochs_t(ix) 2*nEpochs_t(end)];
        end
        pf_corrected = pf_ori*(numel(nEpochs_t)-1);
        noshow = pf_corrected>0.05;
        groups(noshow) = [];
        pf_corrected(noshow) = [];
        hstar = sigstar(groups, pf_corrected);
        set(hstar,'color',lcolors(ss,:));


        ax(itv,3)=subplot(3,2,itv+4);
        errorbar(2*nEpochs_t, squeeze(maccuracy), squeeze(sdaccuracy),'color',lcolors(ss,:));hold on;
        set(ax(itv,3),'XScale','log','xtick',2*nEpochs_t)
        axis padded
        if ss == 2 && itv == 1
            %legend(replace(refCodeStrings,'_','-'), 'location','northoutside');
            ylabel('classification accuracy');
        end
    end
end
linkaxes(ax(:,1));
linkaxes(ax(:,2));
linkaxes(ax(:,3));
set(ax,'tickdir','out', 'box','off');

savePaperFigure(gcf,[out_file '_nEpochs']);


%% for explanation of figure 3
fprintf('We assessed the minimal number of training epochs across %d hctsa features.\n', numel(sigFeatures))
fprintf('The mean classification accuracy saturated at %.0f epochs in macaque and %.0f  epochs in human (%d and %d features did not reach saturation).\n', ...
    2*mean_nEpochs_mean(1), 2*mean_nEpochs_mean(2), nFeatures_nonconverge_mean(1), nFeatures_nonconverge_mean(2))
fprintf('Similarly, the standard deviation converged at %.0f epochs in macaque and %.0f  epochs in human (%d and %d features did not converge).\n', ...
    2*mean_nEpochs_var(1), 2*mean_nEpochs_var(2), nFeatures_nonconverge_var(1), nFeatures_nonconverge_var(2))
fprintf('These findings suggest that a classifier with significant perfomance in both species would require %.0f epochs of 200ms, amounting %.0f seconds worth of data for training.\n',...
    2*mean_nEpochs_var(2), 2*mean_nEpochs_var(2)*0.2);




%% mean and sd of accuracy
figure('position',[0 0 800 900]);
for itv = 1:2
    accuracy_c = squeeze(accuracy(:,itv,sigFeatures,:));
    maccuracy = squeeze(mean(accuracy_c, 3));
    sdaccuracy = squeeze(std(accuracy_c, [], 3));

    if itv==1
        [~, order] = sort(maccuracy(end,:),2,'descend');
    end

    ax(itv,1) = subplot(3,2, itv);
    imagesc(log10(2*nEpochs_t), 1:numel(sigFeatures), maccuracy(:,order)');
    set(ax(itv,1),'Xtick',log10(2*nEpochs_t),'xtickLabel',2*nEpochs_t,'tickdir','out')
    vline(log10(2*mean_nEpochs_mean(itv)))
    clim([.5 .9]);
    if itv == 2
        ax(2,1)=mcolorbar(ax(2,1));
    end

    ax(itv,2) = subplot(3,2, itv+2);
    imagesc(log10(2*nEpochs_t),  1:numel(sigFeatures), sdaccuracy(:,order)');
    set(ax(itv,2),'Xtick',log10(2*nEpochs_t),'xtickLabel',2*nEpochs_t,'tickdir','out')
    vline(log10(2*mean_nEpochs_var(itv)))
    clim([0 0.25]);
    if itv == 2
        ax(2,2)=mcolorbar(ax(2,2));
    end
end
linkcaxes(ax(:,1));
linkcaxes(ax(:,2));
savePaperFigure(gcf,[out_file '_nEpochs_mean_sd']);