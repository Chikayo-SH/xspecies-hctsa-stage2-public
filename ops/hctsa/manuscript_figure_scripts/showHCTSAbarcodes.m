function [fig, data] = showHCTSAbarcodes(TS_Normalised, TimeSeries, order_f, order_e, CodeString, ...
    refCodeStrings, condNames)%, nEpochsEach, ylabels)
%fig = showHCTSAbarcodes(TS_Normalised, TimeSeries, validFeatures, CodeString, refCodeString, bestCodeString)

%cf. https://github.com/Prototype003/fly_blind_classify/blob/main/main_hctsa_matrix.m


if nargin < 7 || isempty(condNames)
    condNames = {'awake','unconscious'};
end

ts = TimeSeries(:,2);
subjectName = cell(numel(ts),1);
for ii = 1:numel(ts)
    dum =  textscan(ts.Name{ii},'subject:%s','delimiter',',');
    subjectName{ii} = dum{1}{1};
end
ylabels = unique(subjectName, 'stable');
nlabels = numel(ylabels);



nConds = numel(condNames);
[nEpochs,nFeatures] = size(TS_Normalised);

nEpochsEach = zeros(nlabels, nConds);
for ii = 1:nlabels
    for icond = 1:nConds
        nEpochsEach(ii, icond) = sum(getCondTrials(TimeSeries, ylabels(ii))==1.*getCondTrials(TimeSeries, condNames(icond))==1);
    end
end

refOperation_idx = [];
for ss = 1:numel(refCodeStrings)
    refOperation_idx(ss) =  find(strcmp(CodeString, refCodeStrings{ss}));
end

%order feature
%[order_c] = clusterFeatures(TS_Normalised(:,validFeatures));
%order_f = validFeatures(order_c);

if isempty(order_f)
    order_f = 1:nFeatures;
end

refOperation_idx_f=[];
for ss = 1:numel(refCodeStrings)
    [~,refOperation_idx_f(ss)] = intersect(order_f, refOperation_idx(ss));
end

condTrials = getCondTrials(TimeSeries, condNames);
for icond = 1:nConds
    data{icond} = TS_Normalised(condTrials==icond, order_f);
end

%order epoch
if isempty(order_e)
    for icond = 1:nConds
        order_e{icond} = clusterFeatures(data{icond}');
    end
end

fig = figure('position',[0 0 500 nConds*200]);
for icond = 1:nConds
    ax(icond)=subplot(nConds, 1, icond);
    imagesc(data{icond}(order_e{icond},:));
    title(condNames{icond});
end
set(ax,'tickdir','out');

for icond = 1:nConds
    hborders = cumsum(nEpochsEach(1:end-1,icond));
    hline(hborders, ax(icond),'-','w');
    % set(ax(icond),'ytick', hborders, 'yticklabel',[]);
end

% if nargin >= 9
    for icond = 1:nConds
        % hline(hborders,ax(1),'-','w');
        set(ax(icond),'ytick', -0.5*nEpochsEach(:,icond)  + cumsum(nEpochsEach(:,icond)), ...
            'TickLength', [0 0], 'yticklabel', replace(ylabels,'_','-'));
    end
% end

fig2=figure;
%linecolors = colormap(fig2,cool(numel(refCodeStrings)));
linecolors = [0 1 0; 1 0 0];

close(fig2);
for ss = 1:numel(refOperation_idx_f)
    %reflines(gcf, refOperation_idx_f(ss),[],linecolors(ss,:))
    for icond = 1: nConds
        refvarrow(ax(icond),refOperation_idx_f(ss),linecolors(ss,:))
    end
end

colormap(inferno);
linkcaxes(ax(:), [0 1]);

for icond = 1: nConds
    mcolorbar(ax(icond));
end