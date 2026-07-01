%from NMclassification_selectCh.m
save_dir = get_xspecies_env_dir("XSPECIES_STAGE1_REANALYSIS_DIR", fullfile("data", "Stage1reanalysis"));
load(fullfile(save_dir, 'data_figure1'),'data_all',...
    'subjectEpochs','order_f');

%% single trial
fig = figure('position',[0 0 1000 50]);
ax(1)=subplot(121);
imagesc(data_all(subjectEpochs{1}(1),order_f));
ax(2)=subplot(122);
imagesc(data_all(subjectEpochs{2}(1),order_f));
colormap(inferno);
linkcaxes(ax(:), [0 1]); set(ax,'tickdir','out','ytick',[]);
savePaperFigure(fig,fullfile(save_dir,'HCTSA_barcode_single'));

