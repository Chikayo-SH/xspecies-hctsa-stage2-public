% Project-specific helper for plotting ECoG channel locations.
% This is not the EEGLAB topoplot function.
function ax = topoplot(ax, MNIX, MNIY, MNIZ, LOBE, sideImage, channelValue, viewOrientation, showEdgeColor)
% topoplot(MNIX, MNIY, MNIZ, LOBE, channelValue, viewOrientation)
% created from channelLocation.m

axes(ax);

if nargin < 9
    showEdgeColor = false;
end

channelSize = 10;%20;

if ~isempty(sideImage)
    imagesc(sideImage); hold on;
end
%figure('position',[0 0 500 500])
for ll = 1:3%4
    switch ll
        case 1
            thisLobe = 'frontal'; edgeColor='r';
        case 2
            thisLobe = 'temporal';edgeColor='g';
        case 3
            thisLobe = 'parietal'; edgeColor='b';
        case 4
            thisLobe = 'occipital'; edgeColor = 'k';
    end

    theseChannels = find(strcmp(string(LOBE), thisLobe ));

    % h = scatter3(MNIX(theseChannels), MNIY(theseChannels), ...
    %     MNIZ(theseChannels), channelSize, channelValue(theseChannels), 'filled');
    
    switch viewOrientation
        case 'side'
            if isempty(channelValue)
                h = scatter(MNIY(theseChannels),MNIZ(theseChannels),channelSize);
            else
                h = scatter(MNIY(theseChannels),MNIZ(theseChannels),channelSize, channelValue(theseChannels),'filled');
            end
        case 'top'
            if isempty(channelValue)
                h = scatter(MNIY(theseChannels),MNIX(theseChannels),channelSize);
            else
                h = scatter(MNIY(theseChannels),MNIX(theseChannels),channelSize, channelValue(theseChannels),'filled');
            end
        otherwise
            error([viewOrientation 'is not recognised']);
    end
    hold on
    if ~showEdgeColor
        h.MarkerEdgeColor = 'k';
    else
        h.MarkerEdgeColor = edgeColor;
    end
end


%     screen2png([year '-' subject]);
%  close all
%
% end