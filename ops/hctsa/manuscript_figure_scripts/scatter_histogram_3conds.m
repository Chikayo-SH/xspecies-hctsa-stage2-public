function f = scatter_histogram_3conds(data_all, TimeSeries_all,  validFeatures_all, suffix_all, refOperation_idx, yScale, param)

condNames = {'awake','sedated','unconscious'};

markerSize = 4;
faceValue = 0.5;
nsid = numel(suffix_all);
suffix_c = [];
for sid = 1:nsid
    suffix_c{sid} = suffix_all{sid}(1:end-11);
end
suffix_c = suffix_c(:);
suffix_c(cellfun(@isempty,suffix_c))=[];
for ii = 1:length(suffix_c)
    subjectEpochs{ii} = find(getCondTrials(TimeSeries_all, suffix_c(ii)) == 1);
    xrange(ii,:) = prctile(subjectEpochs{ii}, [0 100]);
end

for icond = 1:3
    stateEpochs{icond} = find(getCondTrials(TimeSeries_all, condNames(icond)) == 1);
end

f = figure;
ax(1)=subplot(1,4, 1:3);
scatter(stateEpochs{1}, data_all(stateEpochs{1},refOperation_idx),markerSize,'magenta','filled');
% plot(stateEpochs{1}, data_all(stateEpochs{1},refOperation_idx),'r.');
hold on
scatter(stateEpochs{2}, data_all(stateEpochs{2},refOperation_idx),markerSize,'yellow','filled');
scatter(stateEpochs{3}, data_all(stateEpochs{3},refOperation_idx),markerSize,'cyan','filled');
% plot(stateEpochs{2}, data_all(stateEpochs{2},refOperation_idx),'g.');
% plot(stateEpochs{3}, data_all(stateEpochs{3},refOperation_idx),'b.');
alpha(ax(1), faceValue);
%ylabel( replace(refCodeStrings{ss},{'_','.'},'-'));
set(ax(1),'yscale',yScale);
axis tight;

%% significant across-subject level
[sig_local, ~, p_across] = ...
    get_sig_features_sedation( ...
    data_all, ...
    TimeSeries_all, ...
    condNames, ...
    validFeatures_all, ...
    param);

%% significance within-subject level
ctmp = nan(nsid,6);
for sid = 1:nsid
    selectedEpochs = [];
    for icond = 1:numel(condNames)
        selectedEpochs = cat(1, selectedEpochs, intersect( ...
            find(getCondTrials( ...
            TimeSeries_all, ...
            {suffix_all{sid}})==1), ...
            find(getCondTrials( ...
            TimeSeries_all, ...
            condNames(icond))==1)));
    end

    [~,~, p_within] = get_sig_features_sedation(data_all(selectedEpochs,:), ...
    TimeSeries_all(selectedEpochs,:), condNames, validFeatures_all, param);

    ctmp(sid,1) = mean(intersect(find(getCondTrials(TimeSeries_all, condNames(2)) == 1), find(getCondTrials(TimeSeries_all, suffix_all(sid)) == 1)));
    ctmp(sid,2) = mean(intersect(find(getCondTrials(TimeSeries_all, condNames(3)) == 1), find(getCondTrials(TimeSeries_all, suffix_all(sid)) == 1)));
    ctmp(sid,6) = p_within(refOperation_idx);
end
addSignStar(ax(1), ctmp, param.q, 0);

ax(2)= subplot(1,4,4);
lcolors(1,:) = [1 0 1]; %awake
lcolors(2,:) = [1 1 0]; %sedated
lcolors(3,:) = [0 1 1]; %unconscious
ylimit = get(ax(1),'ylim');

if strcmp(yScale,'linear')
    h=histogram(data_all(stateEpochs{1},refOperation_idx),'Orientation', 'horizontal', 'facecolor', lcolors(1,:),'BinLimits',ylimit, 'FaceAlpha',faceValue); hold on
    h=histogram(data_all(stateEpochs{2},refOperation_idx),'Orientation', 'horizontal', 'facecolor', lcolors(2,:),'BinLimits',ylimit, 'FaceAlpha',faceValue, 'BinEdges',h.BinEdges);
    h=histogram(data_all(stateEpochs{3},refOperation_idx),'Orientation', 'horizontal', 'facecolor', lcolors(3,:),'BinLimits',ylimit, 'FaceAlpha',faceValue, 'BinEdges',h.BinEdges);
    linkaxes(ax,'y');
elseif strcmp(yScale,'log')
    ylimit_log = [log10(ylimit(1)) log10(ylimit(2))];
    h=histogram(log10(data_all(stateEpochs{1},refOperation_idx)),'Orientation', 'horizontal', 'facecolor', lcolors(1,:),'BinLimits',ylimit_log, 'FaceAlpha',faceValue); hold on
    h=histogram(log10(data_all(stateEpochs{2},refOperation_idx)),'Orientation', 'horizontal', 'facecolor', lcolors(2,:),'BinLimits',ylimit_log, 'FaceAlpha',faceValue, 'BinEdges',h.BinEdges);
    h=histogram(log10(data_all(stateEpochs{3},refOperation_idx)),'Orientation', 'horizontal', 'facecolor', lcolors(3,:),'BinLimits',ylimit_log, 'FaceAlpha',faceValue, 'BinEdges',h.BinEdges);

    set(ax(2),'YLim', ylimit_log);
end
xlabel('#epochs');
% fig_rc = pdensity_awakeUnconscious(data_all, TimeSeries_all, CodString, ...
%     refCodeString, subjectNames, condNames);%, xscale, nedges);


%% unresponsive v sedation
% if median(data_all(stateEpochs{1},refOperation_idx) < data_all(stateEpochs{3},refOperation_idx))
%     direction = 'left';
% elseif median(data_all(stateEpochs{1},refOperation_idx) > data_all(stateEpochs{3},refOperation_idx))
%     direction = 'right';
% end
% if strcmp(direction,'left')
%     title(sprintf('unresp > sedation \n p=%.1e', p_sedation_fdr(refOperation_idx)));
% elseif strcmp(direction,'right')
%     title(sprintf('unresp < sedation \n p=%.1e', p_sedation_fdr(refOperation_idx)));
% end
title(sprintf('p=%.1e', p_across(refOperation_idx)))

for ii = 1:2:length(suffix_c)
    vbox(xrange(ii,1),xrange(ii,2),ax(1),[.5 .5 .5 .5]);
end
set(ax(1),'tickdir','out','xtick',mean(xrange,2),'xticklabel', replace(suffix_c,{'_','.'},'-'));
%legend(ax(1), condNames)
set(ax(2),'tickdir','out','yticklabel',[]);
legend(ax(2), condNames);%,'location','northoutside');
