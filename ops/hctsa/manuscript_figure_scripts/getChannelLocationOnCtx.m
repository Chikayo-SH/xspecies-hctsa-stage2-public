function [channelID, XX, YY, ZZ, LOBE, sideImage, subject_date] = ...
    getChannelLocationOnCtx(species, sid)
lobeNames = {'parietal','temporal','frontal'};
[channelID, suffix] = getAllChannels(species, sid, lobeNames);
parts = split(suffix, '_');
thisSubject = parts{1};
thisDate = parts{2};
subject_date = [thisSubject '-' thisDate];
switch species
    case 'human'
        kirillDir = get_xspecies_env_dir("XSPECIES_KIRILL_STAGE2_DIR", fullfile("data", "Kirill Iowa Intracranial Data", "Stage2"));
        directory_lobe = fullfile(kirillDir, thisDate);

        fullpath_xlsx_lobe =fullfile(directory_lobe, [ thisSubject  'R_Electrode_Sites_KN_DS.xlsx']);
        hemisphere = 'r';
        if ~exist(fullpath_xlsx_lobe, 'file')
            fullpath_xlsx_lobe =fullfile(directory_lobe, [ thisSubject  'L_Electrode_Sites_KN_DS.xlsx']);
            hemisphere = 'l';
        end
        xlsxdata_lobe = readtable(fullpath_xlsx_lobe);
        %channelID_ori = xlsxdata.Channel;
        %channelOrder = intersect(channelID, channelID_ori);
        % XX = xlsxdata_lobe.MNIX(channelID);
        % YY = xlsxdata_lobe.MNIY(channelID);
        % ZZ = xlsxdata_lobe.MNIZ(channelID);
        LOBE = xlsxdata_lobe.lobe(channelID);
        sideImage = [];

        directory_xyz = get_xspecies_env_dir("XSPECIES_KIRILL_STAGE2_DIR", fullfile("data", "Kirill Iowa Intracranial Data", "Stage2"));
        fullpath_xlsx =fullfile(directory_xyz, [ thisSubject  '_contact_locations_fsparc.csv']);
        xlsxdata = readtable(fullpath_xlsx);
        channelID_ori = xlsxdata.Var3; %Var2
        [~,channelOrder] = intersect(channelID_ori,channelID);
        XX = xlsxdata.Var9(channelOrder);
        YY = xlsxdata.Var10(channelOrder);
        if strcmp(hemisphere,'l')
            YY =  - YY;
        end
        ZZ = xlsxdata.Var11(channelOrder);
        if strcmp(thisSubject,'403')
            ZZ = ZZ - 50;
        end

    case 'macaque'
        directory = get_xspecies_env_dir("XSPECIES_NEUROTYCHO_CHANNELMAP_DIR", fullfile("data", "Neurotycho Data", "Stage2", "channelMap"));
        load(fullfile(directory, [thisSubject 'Map']),'I','X','Y');

        LOBE = cell(numel(channelID),1);
        for ll = 1:numel(lobeNames)
            channelID_tmp = getAllChannels(species, sid, lobeNames(ll));
            LOBE(find(ismember(channelID, channelID_tmp))) = lobeNames(ll);
        end

        XX = [];
        YY = X(channelID);%size(I,2) - X(channelID);
        ZZ = size(I,1) - Y(channelID);
        sideImage = flipud(I); %flipud(fliplr(I));
end