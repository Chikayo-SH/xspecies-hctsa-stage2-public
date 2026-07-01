function [hctsaData, filename] = retrieveOnehctsaData(hctsa_dir, species, suffix, ich, hctsaType, omitSedated)
%[data_all, TimeSeries_all, validFeatures_all, nEpochs_all, err_all] = retrieveAllhctsaData(species_validate, tgtlobe, channelSelection)

% if nargin < 3
%     channelSelection =  'allCh';%% 'oneCh';%'allCh'
% end
if nargin < 5
hctsaType = 'TS_DataMat';
end
if nargin < 6
    omitSedated = 1;
end

filename = sprintf('%s_%s_ch%03d_hctsa', species, suffix, ich);
filename_latest = [filename '.LATEST'];
if exist(fullfile(hctsa_dir, [filename_latest '.mat']),'file')
    filename = filename_latest;
end

% try
file_string = fullfile(hctsa_dir,  filename);
if strcmp(hctsaType,'TS_DataMat')
    hctsaData = load([file_string '.mat'],  'TS_DataMat', 'TimeSeries');%, 'TS_Normalised', 'Operations',
elseif strcmp(hctsaType,'TS_Normalised')
    hctsaData = load([file_string '.mat'],  'TS_Normalised', 'TimeSeries');%, 'TS_Normalised', 'Operations',
end
nEpochs = size(hctsaData.(hctsaType),1);

hctsaData.TimeSeries = hctsaData.TimeSeries(:,1:5);

%hack for human with sedated states
%unconscious condition is wrongly labeled as sedated condition
% if nansum(getCondTrials(htcsaData.TimeSeries,{'sedated'})) > nansum(getCondTrials(htcsaData.TimeSeries,{'awake'}))
if strcmp(species, 'human')
    if contains(suffix,'376_2020')
        hctsaData.TimeSeries = hctsaData.TimeSeries([             1:nEpochs/3                                                  2*nEpochs/3+1:nEpochs                                          nEpochs/3+1:2*nEpochs/3],:);
       end
    %at this point the data should be stored in awake-unconscious-sedated

    if omitSedated == 1
        hctsaData.(hctsaType) =  hctsaData.(hctsaType)(1:2*nEpochs/3,:); % 2*nEpochs/3+1:nEpochs],:);
        hctsaData.TimeSeries = hctsaData.TimeSeries(1:2*nEpochs/3,:); % 2*nEpochs/3+1:nEpochs],:);
        nEpochs = size(hctsaData.(hctsaType),1);
    else
        %reorder awake - sedated - unconscious
        hctsaData.(hctsaType) = cat(1, hctsaData.(hctsaType)(1:nEpochs/3,:), hctsaData.(hctsaType)(2*nEpochs/3+1:end,:), hctsaData.(hctsaType)(nEpochs/3+1:2*nEpochs/3,:));
        hctsaData.TimeSeries = hctsaData.TimeSeries([             1:nEpochs/3                                                  2*nEpochs/3+1:nEpochs                                          nEpochs/3+1:2*nEpochs/3],:); %14/4/26
    end
end

