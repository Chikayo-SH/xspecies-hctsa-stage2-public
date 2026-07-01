%% General setup

species = 'human';
nsid = 10; %human
tgtlobe = 'frontal'; % Just need this for getAllChannels for getting session labels

% Channel IDs, session IDs for each session
tgtChannelsInLobe_local = cell(nsid, 1);
suffix_local = cell(nsid, 1);
channel_counts = zeros(nsid,1);
for sid = 1:nsid
	[tgtChannelsInLobe_local{sid}, suffix_local{sid}] = ...
		getAllChannels(species, sid, tgtlobe);
	channel_counts(sid) = numel(tgtChannelsInLobe_local{sid});
end

%% Get valid features

%source_file = 'COSproject/Stage 1/results_subtractMean_removeLineNoise/TS_Normalised_train_macaque_George_ch055_validate_human_376_ch134_accuracy.mat';
source_file = '..\..\..\COSproject\Stage 1\results_subtractMean_removeLineNoise\TS_Normalised_train_macaque_George_ch055_validate_human_376_ch134_accuracy.mat';

tic;
tmp = load(source_file);
toc

feature_order = tmp.order_f;

%% Load t values

compare_labels = {'A-S', 'S-U'};
%source_dir = 'chikayo\for_angus_tscore_mats_all10_v6_retrieve_loader_20260624\';
source_dir = '..\for_angus_tscore_mats_all10_v6_retrieve_loader_20260624\';

tscores = cell(nsid, 2);
channel_ids = cell(nsid, 1);

for sid = 1 : nsid
	source_file = ['tscore_norm_' suffix_local{sid} '_v6.mat'];
	
	tic;
	tscore_data = load(fullfile(source_dir, source_file));
	toc
	drawnow
	
	channel_ids{sid} = tscore_data.channel_ids;
	
	% Store t-score matrices (channels x features)
	tscores{sid, 1} = tscore_data.t_AS_mat;
	tscores{sid, 2} = tscore_data.t_SU_mat;
end

%% Get MNI coords

channelID_alls = cell(nsid, 1);
YYs = cell(nsid, 1);
ZZs = cell(nsid, 1);
LOBEs = cell(nsid, 1);
hemispheres = cell(nsid, 1);

for sid = 1 : nsid
	
	[channelID_all, XX, YY, ZZ, LOBE, sideImage, subject_date, hemisphere] = getChannelLocationOnCtx(species, sid);
	
	channelID_alls{sid} = channelID_all;
	YYs{sid} = YY;
	ZZs{sid} = ZZ;
	LOBEs{sid} = LOBE;
	hemispheres{sid} = hemisphere;
	
	% YYs were flipped if hemisphere was left ('l')
	% So flip them back - negative indicates more posterior
	if strcmp(hemisphere, 'l')
		YYs{sid} = -YYs{sid};
	end
	
end

%% Filter out unused/unlabelled channels
% Because some channels which have tscore data are not provided with
% coords(?)

for sid = 1 : nsid
	use_channels = ismember(channel_ids{sid}, channelID_alls{sid});
	
	for compare = 1 : size(tscores, 2)
		tscores{sid, compare} = tscores{sid, compare}(use_channels, :);
	end
	channel_ids{sid} = channel_ids{sid}(use_channels);
	
end

%% Replace any infs with nan

for sid = 1 : nsid
	
	for compare = 1 : size(tscores, 2)
		tscores{sid, compare}(isinf(tscores{sid, compare})) = nan;
	end
	
end

%{
%% Check YY sign

figure;
for sid = 1 : nsid
	subplot(2, 5, sid);
	
	scatter(YYs{sid}, ZZs{sid});
	
	xlabel('Y'); ylabel('Z');
	
	xlim([-100 100]);
	ylim([-100 100]);
	
	title(suffix_local{sid}, 'interpreter', 'none');
	
	axis square
end

%% Plot scatter for one session

sid = 7;

ch_selection =...
	strcmp(LOBEs{sid}, 'frontal') |...
	strcmp(LOBEs{sid}, 'temporal') |...
	strcmp(LOBEs{sid}, 'parietal');

% x axis is t-scores (A-S)
% y axis is t-score (S-U)
% Color of points corresponds to YY coord

% Create coord matrix to correspond with tscore matrices
color_coord = YYs{sid}(ch_selection);
color_coord = repmat(color_coord, [1 size(tscores{1}, 2)]);

% Color limits for MNI coords
min_coord = min(color_coord(:));
max_coord = max(color_coord(:));
coord_lim = max([abs(min_coord) max_coord]);

xvals = tscores{sid, 1}(ch_selection, feature_order);
yvals = tscores{sid, 2}(ch_selection, feature_order);
zvals = color_coord(:, feature_order);

% Diverging colormap for MNI coords
cmap_coord = flipud(cbrewer('div', 'BrBG', 100));
cmap_coord(cmap_coord < 0) = 0; % for some reason cbrewer is giving negative values...?
cmap_coord(cmap_coord > 1) = 1;
cmap_coord = parula(100);

[fig, scatter_ax, hist1_ax, hist2_ax, hist1_link, hist2_link] = AS_SU_scatter_hist(xvals, yvals, zvals, coord_lim, compare_labels, cmap_coord);

%% Reposition/resize histograms

AS_SU_scatter_hist_repos(scatter_ax, hist1_ax, hist2_ax);

%}

%% Average within lobes

lobe_set = {'frontal', 'temporal', 'parietal'};

tscores_perLobe = cell(size(tscores));

for sid = 1 : nsid
	for compare = 1 : size(tscores, 2)
		
		tscores_perLobe{sid, compare} = nan(numel(lobe_set), size(tscores{sid, compare}, 2));
		
		for lobe_c = 1 : numel(lobe_set)
			
			ch_selection = strcmp(LOBEs{sid}, lobe_set{lobe_c});
			
			tscores_perLobe{sid, compare}(lobe_c, :) = median(tscores{sid, compare}(ch_selection, :), 'omitnan');
			
		end
		
	end
end

%% Combine t-score matrices, channel orders, coords across participants

% Combine tscore mats
tscores_perLobe_combined = cell(size(tscores, 2), 1);
tscores_perLobe_combined{1} = cat(1, tscores_perLobe{:, 1});
tscores_perLobe_combined{2} = cat(1, tscores_perLobe{:, 2});

%{
%% Plot for each session, per lobe

figure('Color', 'w');
sp_rows = 3;
sp_cols = 4;

% Create coord matrix to correspond with tscore matrices
color_coord = (1 : numel(lobe_set))';
color_coord = repmat(color_coord, [1 size(tscores{1}, 2)]);

% Categorical colormap for lobe
cmap_coord = flipud(cbrewer('qual', 'Dark2', 3));
cmap_coord(cmap_coord < 0) = 0; % for some reason cbrewer is giving negative values...?
cmap_coord(cmap_coord > 1) = 1;

for sid = 1 : nsid
	
	xvals = tscores_perLobe{sid, 1}(:, feature_order);
	yvals = tscores_perLobe{sid, 2}(:, feature_order);
	zvals = color_coord(:, feature_order);
	
	ax = subplot(sp_rows, sp_cols, sid);
	[ax, cbar] = AS_SU_scatter(ax, xvals, yvals, zvals, [], compare_labels, cmap_coord);
	
	alpha(0.2);
	
	title(cbar, '');
	
	% Place frontal on top (because frontal has positive MNI coords)
	set(cbar, 'Direction', 'reverse');
	
	a = 1;
	b = numel(lobe_set);
	n = numel(lobe_set);
	ticks = categorical_colorbar_ticks(a, b, n);
	set(cbar, 'YTick', ticks, 'YTickLabel', lobe_set);
	
	title(suffix_local{sid}(1:8), 'interpreter', 'none');
end

%% Plot scatter for all sessions

ax = subplot(sp_rows, sp_cols, nsid+1);

% Create coord matrix to correspond with tscore matrices
color_coord = (1 : numel(lobe_set))';
color_coord = repmat(color_coord, [nsid size(tscores{1}, 2)]);

xvals = tscores_perLobe_combined{1}(:, feature_order);
yvals = tscores_perLobe_combined{2}(:, feature_order);
zvals = color_coord(:, feature_order);

% Categorical colormap for lobe
cmap_coord = flipud(cbrewer('qual', 'Dark2', 3));
cmap_coord(cmap_coord < 0) = 0; % for some reason cbrewer is giving negative values...?
cmap_coord(cmap_coord > 1) = 1;

[ax, cbar] = AS_SU_scatter(ax, xvals, yvals, zvals, [], compare_labels, cmap_coord);
title('all');

alpha(0.1);

% Place frontal on top (because frontal has positive MNI coords)
set(cbar, 'Direction', 'reverse');

% Categorical colorbar ticks
a = 1;
b = numel(lobe_set);
n = numel(lobe_set);
ticks = categorical_colorbar_ticks(a, b, n);
set(cbar, 'YTick', ticks, 'YTickLabel', lobe_set);
title(cbar, '');

%}

%% tiledlayout

%% Plot for each session, per lobe

figure('Color', 'w');
sp_rows = 3;
sp_cols = 4;

tl = tiledlayout(sp_rows, sp_cols, 'TileSpacing', 'tight');

% Create coord matrix to correspond with tscore matrices
color_coord = (1 : numel(lobe_set))';
color_coord = repmat(color_coord, [1 size(tscores{1}, 2)]);

% Categorical colormap for lobe
cmap_coord = flipud(cbrewer('qual', 'Dark2', 3));
cmap_coord(cmap_coord < 0) = 0; % for some reason cbrewer is giving negative values...?
cmap_coord(cmap_coord > 1) = 1;

for sid = 1 : nsid
	
	xvals = tscores_perLobe{sid, 1}(:, feature_order);
	yvals = tscores_perLobe{sid, 2}(:, feature_order);
	zvals = color_coord(:, feature_order);
	
	%ax = subplot(sp_rows, sp_cols, sid);
	ax = nexttile(sid);
	[ax, cbar] = AS_SU_scatter(ax, xvals, yvals, zvals, [], compare_labels, cmap_coord);
	
	alpha(0.2);
	
	axis tight
	ax_lims = [xlim ylim];
	%ax_lims = [prctile(xvals, 5) prctile(xvals, 95) prctile(yvals, 5) prctile(yvals, 95)];
	xlim([min(ax_lims) max(ax_lims)]);
	ylim([min(ax_lims) max(ax_lims)]);
	
	title(cbar, '');
	
	% Place frontal on top (because frontal has positive MNI coords)
	set(cbar, 'Direction', 'reverse');
	
	a = 1;
	b = numel(lobe_set);
	n = numel(lobe_set);
	ticks = categorical_colorbar_ticks(a, b, n);
	set(cbar, 'YTick', ticks, 'YTickLabel', lobe_set);
	
	colorbar off
	
	title(suffix_local{sid}(1:8), 'interpreter', 'none');
end

%% Plot scatter for all sessions

%ax = subplot(sp_rows, sp_cols, nsid+1);
ax = nexttile(nsid+1);

% Create coord matrix to correspond with tscore matrices
color_coord = (1 : numel(lobe_set))';
color_coord = repmat(color_coord, [nsid size(tscores{1}, 2)]);

xvals = tscores_perLobe_combined{1}(:, feature_order);
yvals = tscores_perLobe_combined{2}(:, feature_order);
zvals = color_coord(:, feature_order);

% Categorical colormap for lobe
cmap_coord = flipud(cbrewer('qual', 'Dark2', 3));
cmap_coord(cmap_coord < 0) = 0; % for some reason cbrewer is giving negative values...?
cmap_coord(cmap_coord > 1) = 1;

[ax, cbar] = AS_SU_scatter(ax, xvals, yvals, zvals, [], compare_labels, cmap_coord);
title('all');

alpha(0.1);

axis tight
ax_lims = [xlim ylim];
xlim([min(ax_lims) max(ax_lims)]);
ylim([min(ax_lims) max(ax_lims)]);

% Place frontal on top (because frontal has positive MNI coords)
set(cbar, 'Direction', 'reverse');

% Categorical colorbar ticks
a = 1;
b = numel(lobe_set);
n = numel(lobe_set);
ticks = categorical_colorbar_ticks(a, b, n);
set(cbar, 'YTick', ticks, 'YTickLabel', lobe_set);
title(cbar, '');

colorbar off

%% Universal colorbar

ax = nexttile(nsid+2);

colormap(cmap_coord);
set(ax, 'Visible', 'off');

cbar = colorbar('Location', 'west');
title(cbar, '');

% Place frontal on top (because frontal has positive MNI coords)
set(cbar, 'Direction', 'reverse');

set(cbar, 'YAxisLocation', 'right');

% Categorical colorbar ticks
a = 0;
b = 1; %numel(lobe_set);
n = numel(lobe_set);
ticks = categorical_colorbar_ticks(a, b, n);
set(cbar, 'YTick', ticks, 'YTickLabel', lobe_set);
title(cbar, '');

%% Print

print_fig = 0;
if print_fig == 1
	figure_name = 'figures/fig7a_xyequal_eg';
	
	set(gcf, 'PaperOrientation', 'Landscape');
	
	%savefig(figure_name);
	
	%print(figure_name, '-dsvg', '-painters'); % SVG
	%print(figure_name, '-dpdf', '-vector', '-bestfit'); % PDF
	%print(figure_name, '-dpng'); % PNG
end

%% Take image of each plot, as full vector image file takes forever to produce and load

print_fig = 0;
if print_fig == 1
	
	figure_name = 'figures/fig7d';
	
	fig = gcf;
	drawnow; 
	
	allAxes = findobj(fig, 'Type', 'axes');
	
	for i = 1:length(allAxes)
    	ax = allAxes(i);
    	hScatter = findobj(ax, 'Type', 'scatter');
    	
    	if ~isempty(hScatter)
        	% 1. Cache the exact original layout and direction states
        	hasGridX = strcmp(ax.XGrid, 'on');
        	hasGridY = strcmp(ax.YGrid, 'on');
        	currentXLim = ax.XLim;
        	currentYLim = ax.YLim;
        	currentXDir = ax.XDir;
        	currentYDir = ax.YDir;
        	
        	% 2. Hide vector grids/lines so they aren't captured in the snapshot
        	grid(ax, 'off');
        	ax.Visible = 'off'; 
        	drawnow;
        	
        	% 3. Capture the clean screenshot array
        	frame = getframe(ax);
        	img = frame.cdata;
        	
        	% 4. Wipe out the heavy 500,000 scatter points 
        	delete(hScatter);
        	
        	% 5. Fix the Top-Left vs Bottom-Left flip by flipping the screenshot rows!
        	% This ensures the top pixels stay at the top of the Cartesian plane.
        	img = flipud(img); 
        	
        	% 6. Drop the data back using 'image' with absolute bounding coordinates
        	hold(ax, 'on');
        	hi = image(ax, 'XData', currentXLim, 'YData', currentYLim, 'CData', img);
        	
        	% 7. Force MATLAB back into standard vector plot behaviors
        	ax.Visible = 'on';
        	ax.XLim = currentXLim;
        	ax.YLim = currentYLim;
        	ax.XDir = currentXDir; 
        	ax.YDir = currentYDir; % Re-locks standard bottom-to-top Cartesian behavior
        	
        	if hasGridX, ax.XGrid = 'on'; end
        	if hasGridY, ax.YGrid = 'on'; end
        	
        	% 8. Push image behind your vector grid lines
        	uistack(hi, 'bottom');
    	end
	end
	
	% Export your perfectly aligned subplots instantly!
	exportgraphics(fig, [figure_name '.pdf'], 'ContentType', 'vector');

end
