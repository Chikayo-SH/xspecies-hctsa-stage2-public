load('data_supplementary_figure2.mat','nSig_accuracy_ind');



%% topographic representation
clear f axbar
for ispecies = 1:2
    f(ispecies) = figure('position',[0 0 1800 1300]);
    switch ispecies
        case 1
            species_validate = 'macaque';
            nsid = 3;
        case 2
            species_validate = 'human';
            nsid = 10;
    end
    nCols = 10; %#training channels + lobe location
    ha = tight_subplot(nsid,nCols,[.02 .01],[.01 .01],[.01 .01]);

    for sid = 1:nsid %row
        [channelID, MNIX, MNIY, MNIZ, LOBE, sideImage, subject_date] = ...
            getChannelLocationOnCtx(species_validate, sid);

        channelValues = squeeze(nSig_accuracy_ind(4:12,ispecies,sid,1:numel(channelID)));
        climit = round(prctile(channelValues(:),[1 99]));


        for JID=3:12 %column
            thisAx = ha((JID-2) + (sid-1)*nCols);
            if JID==3
                thisAx = topoplot(thisAx, MNIX, MNIY, MNIZ, LOBE, sideImage, [],'side',1);
            else
                thisAx = topoplot(thisAx, MNIX, MNIY, MNIZ, LOBE, sideImage, channelValues(JID-3,:),'side');
            end
            axis equal;
            axis xy;
            switch species_validate
                case 'macaque'
                    xlim(thisAx,[0 1000]); ylim(gca, [0 1200]);
                case 'human'
                    xlim(thisAx,[-95 95]); ylim(gca, [-60 60]);
            end
            clim(thisAx, climit);
            if JID==3
                ylabel(subject_date,'Rotation',0);
            elseif JID==12
                [~,axbar] = mcolorbar(thisAx,0.5);
                axbar.Position(1)=0.98;
            end
            axis off
            set(thisAx,'xtick',[],'ytick',[]);

            if JID==3 && sid==nsid
                legend({'frontal','temporal','parietal'});
            end
            if JID==12 && sid==nsid
               axbar.Label.String = '# sig. features';
            end
        end
    end
    % savePaperFigure(f(ispecies), ['topolot_' species_validate]);
    % close(f(ispecies));
end
