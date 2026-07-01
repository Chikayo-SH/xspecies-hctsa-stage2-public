function fig = showAccuracybarcodes(accuracy,order_f, CodeString, refCodeStrings)
%created from NMclassification_selectCh.m
%accuracy: (number of features) x (train or validate) 
nBars = size(accuracy,2);

linecolors = [0 1 0; 1 0 0];

refOperation_idx=[];
refOperation_idx_f=[];
for ss = 1:numel(refCodeStrings)
    refOperation_idx(ss) =  find(strcmp(CodeString, refCodeStrings{ss}));
    [~,refOperation_idx_f(ss)] = intersect(order_f, refOperation_idx(ss));
end

fig = figure('position',[0 0 500*nBars 50]);

for aa = 1:nBars
    ax(aa)=subplot(1,nBars, aa);
    imagesc(accuracy(order_f,aa)');
end
colormap(1-gray);
linkcaxes(ax(:), [0.5 1]); set(ax(:), 'tickdir','out','ytick',[]);

for ss = 1:numel(refOperation_idx_f)
    for aa = 1:nBars
        refvarrow(ax(aa),refOperation_idx_f(ss),linecolors(ss,:))
    end
end
drawnow();
mcolorbar;