function [tgtChannelsInLobe, suffix] = getAllChannels(species, sid, tgtlobe)
% [tgtChannelsInLobe, suffix] = getAllChannels(species, sid, tgtlobe)

%% Path
% addDirPrefs_COS;
dirPref = getpref('cosProject','dirPref');

if strcmp(species, 'macaque')
    switch sid
        case 1
            subject = 'Chibi';
            date = '20120730';
        case 2
            subject = 'Chibi';
            date = '20120802';
        case 3
            subject = 'George';
            date = '20120731';
        case 4 %used for classifier training in Stage 1
            subject = 'George';
            date = '20120803';
    end
    suffix = [subject '_' date];
    save_dir = fullfile(dirPref.rootDir, 'preprocessed',species,suffix);

    %% load channels to process
    load(fullfile(save_dir,['detectChannels_' suffix]) ,'channel','tgtChannels','lobe');
    channelsInLobe = channel(matches(string(lobe),tgtlobe));
    tgtChannelsInLobe = intersect(tgtChannels, channelsInLobe);


elseif strcmp(species, 'human')
       exp = 'anesthesia'; %only for human

    switch sid
        case 1
            subject = '372';
            year = '2018';
        case 2
            subject = '394';
            year = '2018';
        case 3
            subject = '399';
            year = '2018';
        case 4
            subject = '400';
            year = '2018';
        case 5
            subject = '372';
            year = '2020';
        case 6 
            subject = '376';
            year = '2020';
        case 7
            subject = '403';
            year = '2020';
        case 8
            subject = '409';
            year = '2020';
        case 9
            subject = '423';
            year = '2020';
        case 10 %used for classifier evaluation in Stage 1
            subject = '376';
            year = '2018';
    end
    suffix = [subject '_' year '_' exp];
    save_dir = fullfile(dirPref.rootDir, 'preprocessed',species,suffix);
    load(fullfile(save_dir,['detectChannels_' suffix]) ,'channel','tgtChannels','lobe');
    channelsInLobe = channel(matches(string(lobe),tgtlobe));
    tgtChannelsInLobe = intersect(tgtChannels, channelsInLobe)';
end