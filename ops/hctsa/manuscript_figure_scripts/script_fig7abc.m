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

%% Average within lobes

lobe_set = {'frontal', 'temporal', 'parietal'};

tscores_perLobe = cell(size(tscores));

for sid = 1 : nsid
	for compare = 1 : size(tscores, 2)
		
		tscores_perLobe{sid, compare} = nan(numel(lobe_set), size(tscores{sid, compare}, 2));
		
		for lobe_c = 1 : numel(lobe_set)
			
			ch_selection = strcmp(LOBEs{sid}, lobe_set{lobe_c});
			
			tscores_perLobe{sid, compare}(lobe_c, :) = mean(tscores{sid, compare}(ch_selection, :), 'omitnan');
			
		end
		
	end
end

%% Combine t-score matrices, channel orders, coords across participants

% Combine tscore mats
tscores_perLobe_combined = cell(size(tscores, 2), 1);
tscores_perLobe_combined{1} = cat(1, tscores_perLobe{:, 1});
tscores_perLobe_combined{2} = cat(1, tscores_perLobe{:, 2});

%%

figure('Color', 'w');
tl = tiledlayout(3, 2, 'TileSpacing', 'compact');

plot_mats = tscores_perLobe_combined;
plot_mats{1} = plot_mats{1}(:, feature_order);
plot_mats{2} = plot_mats{2}(:, feature_order);

% Color limits for tscores
min_t = min(cellfun(@(x) min(x, [], 'all', 'omitnan'), plot_mats));
max_t = max(cellfun(@(x) max(x, [], 'all', 'omitnan'), plot_mats));
t_lim = max([abs(min_t) max_t]);

% Diverging colormap for data
cmap = flipud(cbrewer('div', 'RdBu', 100));
cmap(cmap < 0) = 0; % for some reason cbrewer is giving negative values...?

sp_counter = 1;
for lobe_c = 1 : numel(lobe_set)
	for compare = 1 : numel(compare_labels)
		%subplot(numel(tscores_perLobe_combined), ncol, ncol*(compare-1) + [1 ncol]);
		nexttile;%subplot(6, 1, sp_counter);
		
		% Note - perLobe mat is ordered by lobe within participant
		%	P1 L1, L2, L3, then P2 L1, L2, L3, etc
		imagesc(plot_mats{compare}(lobe_c : numel(lobe_set) : nsid*numel(lobe_set), :), [-t_lim t_lim]);
		title([lobe_set{lobe_c} ' ' compare_labels{compare}]);
		xlabel('feature');
		%ylabel('session');
		
		set(gca, 'YTick', (1:sid), 'YTickLabel', cellfun(@(x) x(1:8), suffix_local, 'UniformOutput', false), ...
			'TickLabelInterpreter', 'none')	;
		
		cbar = colorbar;
		title(cbar, 't');
		
		colormap(gca, cmap);
		
		sp_counter = sp_counter + 1;
	end
end

%% Print

print_fig = 0;
if print_fig == 1
	figure_name = 'figures/fig7abc';
	
	set(gcf, 'PaperOrientation', 'Landscape');
	
	savefig(figure_name);
	
	%print(figure_name, '-dsvg', '-painters'); % SVG
	print(figure_name, '-dpdf', '-vector', '-bestfit'); % PDF
	%print(figure_name, '-dpng'); % PNG
end