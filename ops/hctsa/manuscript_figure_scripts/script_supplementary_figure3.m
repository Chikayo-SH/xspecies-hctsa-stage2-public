save_dir = get_xspecies_env_dir("XSPECIES_STAGE2_ANALYSIS_DIR", fullfile("data", "Stage2analysis"));
load(fullfile(save_dir,'data','data_supplementary_figure3'), 'condNames',...
    'data_all_n','TimeSeries_all','Operations','tgtOperation_idx','ll');

%     'order_f');
%allEpochs = 1:size(data_all,1);
species = 'human';
nsid = 10; %human
nEpochs = 300; % use this number of epochs per session

%% barcode
order_e = cell(1,numel(condNames));
for icond = 1:numel(condNames)
    theseEpochs = find(getCondTrials(TimeSeries_all, condNames(icond))==1);
    order_e{icond} = 1:numel(theseEpochs);
end

[fig, hctsa_vals_limited] = showHCTSAbarcodes( ...
    data_all_n, ...
    TimeSeries_all, ...
    ll.order_f, ...
    order_e, ...
    Operations.CodeString, ...
    [], ...
    condNames);
set(fig, 'Position',[0 0 1100 600]);
out_file = fullfile(save_dir, 'figure');

savePaperFigure( ...
    fig, [species '_HCTSA_barcode_asu']);

%% barcode (difference)

diff_combs = [1 2; 1 3; 2 3];

fig_diff = figure('position',[0 0 1100 600]);
cmap = flipud(RedWhiteBlue);
colormap(cmap);

for d = 1 : size(diff_combs, 1)
	
    diff_mat =...
		hctsa_vals_limited{diff_combs(d, 1)} -...
		hctsa_vals_limited{diff_combs(d, 2)};
	subplot(numel(condNames), 1, d);
	
	imagesc(diff_mat);
	set(gca, 'YTick', (1:nEpochs:nEpochs*nsid));
	set(gca, 'YTick', []);
	
    if d==3
    	mcolorbar;
    end

	hold on;
	
	for sid = 1 : nsid
		line(xlim,...
			[((sid-1)*nEpochs)+1 ((sid-1)*nEpochs)+1],...
			'Color', 'k');
	end
	
	title([condNames{diff_combs(d, 1)} ' - ' condNames{diff_combs(d, 2)}]);	
end
savePaperFigure( ...
    fig_diff, [species '_HCTSA_barcode_asu_diff']);


%% hierarchical clustering
rho = corr(data_all_n(:,tgtOperation_idx),'Type','Spearman');

Z = linkage(1-abs(rho));
dendrogram(Z)
%create cell of labels
% labels = cellstr(num2str((1:numel(tgtOperation_idx))', 'label %d'))
labels = replace(Operations.CodeString(tgtOperation_idx), '_','-');
%plot dendogram with custom labels
h=dendrogram(Z, 0, 'Labels', labels, 'orientation', 'left');
set(gca,'tickdir','out');
set(gcf,'position',[0 0 1000 470]);
savePaperFigure(gcf, [species '_dendrogram_asu']);
