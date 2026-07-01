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

%% threshold t-values and count % of participants satisfied

% Threshold values

t_thresh = 3;

AS_t_within =...
	tscores_perLobe_combined{1} > -t_thresh &...
	tscores_perLobe_combined{1} < t_thresh;

SU_t_outside =...
	tscores_perLobe_combined{2} < -t_thresh |...
	tscores_perLobe_combined{2} > t_thresh;

t_satisfied = AS_t_within & SU_t_outside;

% Count participants
satisfied_count = nan(numel(lobe_set), size(t_satisfied, 2));
for lobe_c = 1 : numel(lobe_set)
	lobe_rows = (lobe_c : numel(lobe_set) : nsid*numel(lobe_set));
	
	satisfied_count(lobe_c, :) = sum(t_satisfied(lobe_rows, :));
end

%%

figure('color', 'w');

tl = tiledlayout('vertical', 'TileSpacing', 'compact');

% Show count/percentage of participants where t-thresh is satisfied
ref_ax = nexttile();

imagesc(satisfied_count(:, feature_order));
set(gca, 'YTick', (1:numel(lobe_set)), 'YTickLabel', lobe_set);
%xlabel('feature');

cbar = colorbar;
title(cbar, 'N');

colormap inferno

% Group features with same count of participants together
nexttile();

satisfied_count_sorted = nan(size(satisfied_count(:, feature_order)));
for lobe_c = 1 : numel(lobe_set)
	
	[~, order] = sort(satisfied_count(lobe_c, feature_order));
	
	satisfied_count_sorted(lobe_c, :) = satisfied_count(lobe_c, feature_order(order));

	plot(satisfied_count(lobe_c, feature_order(order))',...
		'LineWidth', 2);
	xlabel('feature');
	
	hold on
	
end

ylabel('N');
xlim(xlim(ref_ax));
legend(lobe_set, 'Location', 'northwest');

%%

print_fig = 0;
if print_fig == 1
	figure_name = 'figures/fig8';
	
	set(gcf, 'PaperOrientation', 'Landscape');
	
	savefig(figure_name);
	
	%print(figure_name, '-dsvg', '-painters'); % SVG
	print(figure_name, '-dpdf', '-vector', '-bestfit'); % PDF
	%print(figure_name, '-dpng'); % PNG
end


%%
%{

[h, p, ksstat] = kstest2(satisfied_count_sorted(1, :), satisfied_count_sorted(2, :))
disp('============================');
[h, p, ksstat] = kstest2(satisfied_count_sorted(1, :), satisfied_count_sorted(3, :))
disp('============================');
[h, p, ksstat] = kstest2(satisfied_count_sorted(2, :), satisfied_count_sorted(3, :))


%%

satisfied_mean = mean(satisfied_count(:, feature_order), 1);

[~, order] = sort(satisfied_mean);


figure('color', 'w');

plot(satisfied_count(:, feature_order(order))');
set(gca, 'YTick', (1:numel(lobe_set)), 'YTickLabel', lobe_set);
xlabel('feature');

cbar = colorbar;
title(cbar, 'N');

colormap inferno

%%

foo = sum(satisfied_count(:, feature_order(order)), 2);

figure;
plot(foo);

%% Find best features

best_satisfied = satisfied_count(:, feature_order) == max(satisfied_count(:));

feature_order(find(best_satisfied(1, :)))

%% Find best features

best_satisfied = satisfied_count == max(satisfied_count(:));

find(best_satisfied(3, :))

%% Get hctsa feature details for reference


%}
