%% Description

% PATCH: wrapper copy from xspecies_blind_classify (HEAD=25df10d)
% Change: allow driver override of species/subject/preprocessSuffix via exist(...)


%{

Extract time series features and append to "(species)_(subject)_(channel)"
Apply initialization and save as "(species)_(subject)_(channel)_hctsa"

Run this after preprocess_kirill.m

%}

%% Settings
% addDirPrefs_COS; % disabled: rootDir override handled by bootstrap%preprocessSuffix = '_subtractMean_removeLineNoise';
dirPref = getpref('cosProject','dirPref');
%species = 'macaque';%'human';
%subject = 'George';%'376';

if ~exist("species","var") || isempty(species)
    species = "macaque";
end
if ~exist("subject","var") || isempty(subject)
    subject = "George";
end


% runTag (optional)
if ~exist("runTag","var") || isempty(runTag)
    rt = getenv("RUN_TAG");
    if isempty(rt)
        runTag = "";
    else
        runTag = string(rt);
    end
end



rootDir_c = char(dirPref.rootDir);
species_c = char(species);
subject_c = char(subject);
animal_c = regexp(subject_c, '^[^_]+', 'match', 'once');
if isempty(animal_c)
    error("Could not parse animal name from subject_c: %s", subject_c);
end
preprocessSuffix_c = char(preprocessSuffix);
runTag_c = char(runTag);

load_dir = fullfile(rootDir_c, "preprocessed_epoch6s", species_c, subject_c);

if isempty(runTag_c)
  save_base_c = ['hctsa' preprocessSuffix_c];
else
  save_base_c = ['hctsa' preprocessSuffix_c '_' runTag_c];
end
save_dir = fullfile(rootDir_c, save_base_c, species_c, subject_c);
save_dir = char(save_dir);

% normalize paths for exist()
load_dir = char(load_dir);
save_dir = char(save_dir);

if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end


%% load channels to process
%load(fullfile(load_dir, ['detectChannels_' subject_c '.mat']), 'tgtChannels');

if ~exist("tgtChannels","var") || isempty(tgtChannels)
    load(fullfile(load_dir, ['detectChannels_' subject_c '.mat']), "tgtChannels");
end


for ich = 1:numel(tgtChannels)
    disp([num2str(ich), '/' num2str(numel(tgtChannels))]);

    thisCh = tgtChannels(ich);

    savedata_prefix = sprintf('%s_%s_ch%03d', species_c, subject_c, thisCh);
    loadName = fullfile(load_dir, [savedata_prefix preprocessSuffix_c '.mat']);
    hctsaName = fullfile(save_dir, [savedata_prefix '_hctsa.mat']);
    hctsaName = char(hctsaName);

    fprintf("DEBUG loadName=%s\n", loadName);
    loaded = load(loadName);
    data = loaded.data;

    %% Setup for HCTSA - training set
    % Reformat into series x time matrix

    % Training dataset
    data_set = data.data_proc; % time x trials x conditions
    % Get labels for each time-series
    %   dimensions - (channels x trials x flies x conditions)
    dims = size(data_set);
    ids = cell(dims(2:end)); % details of each time-series
    for tr = 1 : dims(2)
        for c = 1 : dims(3)
            meta = resolve_hctsa_label_meta(species_c, subject_c, data, c);

            if tr == 1 && meta.fix_applied
                fprintf('[label-fix] species=%s subject=%s channel=%d c=%d state=%s rule=%s\n', ...
                    species_c, subject_c, thisCh, c, char(meta.state), char(meta.fix_rule));
            end

            ids{tr, c} = ['subject:' subject_c ',channel:' num2str(thisCh) ',epoch:' num2str(tr) ',state:' char(meta.state) ...
                ',anesthetic:' data.anesthetic ',dose:' char(meta.dose) ',lobe:' char(data.lobe) ',sex:' data.sex ',age:' num2str(data.age) ];
        end
    end

    % Reformat to (series x time)
    data_set = permute(data_set, [2 3 1]); % trials x conditions x time
    data_set = reshape(data_set, [prod(dims(2:end)) dims(1)]); % Collapse all dimensions other than time
    ids = reshape(ids, [prod(dims(2:end)) 1]); % Collapse labels also
    % Create hctsa matrix
    timeSeriesData = data_set;
    labels = ids; % keywords are already unique
    keywords = ids;

	% --- write TS data to a run-specific file (avoid touching preprocessed .mat) ---
	if isempty(runTag_c)
	    tsFile = [savedata_prefix preprocessSuffix_c '_ts.mat'];
	else
	    tsFile = [savedata_prefix preprocessSuffix_c '_ts_' runTag_c '.mat'];
	end
	tsName = fullfile(save_dir, tsFile);
	tsName = char(tsName);
	tsName = tsName(:)';  % enforce row char vector

	save(tsName, 'timeSeriesData', 'labels', 'keywords');  % no -append


	tic;
	TS_Init(tsName, 'hctsa', [false, false, false], hctsaName);
	%TS_Init(tsName, "hctsa", [false, false, false], hctsaName);
	hctsaName = char(hctsaName);
	toc
	disp('training set done');
end


function meta = resolve_hctsa_label_meta(species_c, subject_c, data, c)
    n_slots = size(data.data_proc, 3);
    n_state = numel(data.state);

    meta = struct();
    meta.state = "";
    meta.dose = "";
    meta.fix_applied = false;
    meta.fix_rule = "";

    if n_state == n_slots
        meta.state = local_get_cell_or_array_string(data, 'state', c);
        meta.dose  = local_get_cell_or_array_string(data, 'dose', c);
        meta.fix_rule = "original_metadata";
        return;
    end

    if strcmp(species_c, 'human') && contains(subject_c, 'anesthesia') && n_slots == 3 && n_state > 3
        canonical_states = ["awake", "unconscious", "sedated"];
        if c < 1 || c > 3
            error('resolve_hctsa_label_meta:BadSlotIndex', ...
                'Unexpected slot index c=%d for merged 3-state case in subject %s.', c, subject_c);
        end
        meta.state = canonical_states(c);
        meta.dose = "";
        meta.fix_applied = true;
        meta.fix_rule = "canonical_merged3state_human_anesthesia_v1";
        return;
    end

    error('resolve_hctsa_label_meta:UnexpectedMismatch', ...
        'Unexpected metadata-slot mismatch for species=%s subject=%s: n_state=%d, n_slots=%d', ...
        species_c, subject_c, n_state, n_slots);
end

function out = local_get_cell_or_array_string(data, field, idx)
    out = "";
    if ~isfield(data, field)
        return;
    end

    v = data.(field);

    if iscell(v)
        if numel(v) >= idx && ~isempty(v{idx})
            try
                out = string(v{idx});
            catch
                out = "";
            end
        end
        return;
    end

    if isnumeric(v)
        if numel(v) >= idx
            out = string(v(idx));
        end
        return;
    end

    if isstring(v)
        if numel(v) >= idx
            out = string(v(idx));
        else
            out = string(v);
        end
        return;
    end

    if ischar(v)
        out = string(v);
        return;
    end
end
