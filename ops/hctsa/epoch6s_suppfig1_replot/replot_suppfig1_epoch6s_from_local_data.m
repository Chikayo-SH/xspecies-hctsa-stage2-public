function out = replot_suppfig1_epoch6s_from_local_data(refCodeStrings)
% Reproduce Supplementary Figure 1-like 6-s epoch analysis figure
% from local copied data.
%
% This script does not recompute HCTSA and does not rerun classification.
% It reads:
%   data/epoch6s_suppfig1/aggregate/compareValidation.mat
%   data/epoch6s_suppfig1/pair_accuracy_mats/*validate_human*_accuracy.mat
%
% Outputs:
%   data/epoch6s_suppfig1/derived_outputs/suppfig1_epoch6s_<timestamp>/

    if nargin < 1 || isempty(refCodeStrings)
        refCodeStrings = [
            "DN_rms"
            "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"
        ];
    else
        refCodeStrings = string(refCodeStrings(:));
    end

    here = fileparts(mfilename("fullpath"));
    baseDir = fileparts(fileparts(fileparts(here)));
    dataDirEnv = getenv("XSPECIES_EPOCH6S_SUPPFIG1_DATA_DIR");
if ~isempty(dataDirEnv)
    dataDir = dataDirEnv;
else
    dataDir = fullfile(baseDir, "data", "epoch6s_suppfig1_minimal");
end

    aggregateDir = fullfile(dataDir, "aggregate");
    pairDir = fullfile(dataDir, "pair_accuracy_mats");

    stamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
    outDir = fullfile(dataDir, "derived_outputs", "suppfig1_epoch6s_" + stamp);

    if ~exist(outDir, "dir")
        mkdir(outDir);
    end

    compareMat = fullfile(aggregateDir, "compareValidation.mat");
    if ~isfile(compareMat)
        error("Missing compareValidation.mat: %s", compareMat);
    end

    S = load(compareMat);

    requiredVars = ["mean_accuracy_all", "validFeatures_all", "sigFeatures", "nSig_accuracy"];
    for i = 1:numel(requiredVars)
        if ~isfield(S, requiredVars(i))
            error("compareValidation.mat is missing variable: %s", requiredVars(i));
        end
    end

    pairMats = dir(fullfile(pairDir, "*validate_human*_accuracy.mat"));
    if isempty(pairMats)
        error("No validate_human pair accuracy MAT files found in: %s", pairDir);
    end

    pairMat = fullfile(pairMats(1).folder, pairMats(1).name);
    P = load(pairMat, "classifier_cv");

    ops = P.classifier_cv.operations;
    rawCodeStrings = ops.CodeString;

    if iscell(rawCodeStrings)
        codeStrings = string(rawCodeStrings(:));
    else
        codeStrings = string(rawCodeStrings(:));
    end

    refIdx = nan(numel(refCodeStrings), 1);
    for i = 1:numel(refCodeStrings)
        idx = find(strcmp(codeStrings, refCodeStrings(i)), 1);
        if isempty(idx)
            error("Reference CodeString not found: %s", refCodeStrings(i));
        end
        refIdx(i) = idx;
    end

    pairInfo = table;
    pairInfo.pair_index = (1:9)';
    pairInfo.lobe = [
        "Parietal"; "Parietal"; "Parietal"; ...
        "Temporal"; "Temporal"; "Temporal"; ...
        "Frontal"; "Frontal"; "Frontal"
    ];
    pairInfo.channel_order = [1;2;3;1;2;3;1;2;3];
    pairInfo.macaque_channel = [11;12;17;44;55;65;69;72;106];
    pairInfo.human_channel = [224;208;140;166;134;226;114;217;158];

    x = pairInfo.pair_index;

    mean_accuracy_all = S.mean_accuracy_all;
    sigFeatures = S.sigFeatures;
    nSig_accuracy = S.nSig_accuracy;

    panelA = table;
    for f = 1:numel(refIdx)
        idx = refIdx(f);

        for p = 1:9
            rowM = table;
            rowM.feature_order = f;
            rowM.feature_index_matlab1 = idx;
            rowM.CodeString = refCodeStrings(f);
            rowM.pair_index = p;
            rowM.lobe = pairInfo.lobe(p);
            rowM.channel_order = pairInfo.channel_order(p);
            rowM.macaque_channel = pairInfo.macaque_channel(p);
            rowM.human_channel = pairInfo.human_channel(p);
            rowM.species = "macaque";
            rowM.accuracy = mean_accuracy_all(p, 1, idx);
            rowM.significant = logical(sigFeatures(idx, p, 1));

            rowH = rowM;
            rowH.species = "human";
            rowH.accuracy = mean_accuracy_all(p, 2, idx);
            rowH.significant = logical(sigFeatures(idx, p, 2));

            panelA = [panelA; rowM; rowH]; %#ok<AGROW>
        end
    end

    panelAFile = fullfile(outDir, "suppfig1_epoch6s_panelA_accuracy_data.tsv");
    writetable(panelA, panelAFile, "FileType", "text", "Delimiter", "\t");

    panelB = pairInfo;
    panelB.macaque_sig_features = nSig_accuracy(:, 1);
    panelB.human_sig_features = nSig_accuracy(:, 2);
    panelB.both_sig_features = nSig_accuracy(:, 3);

    panelBFile = fullfile(outDir, "suppfig1_epoch6s_panelB_nsig_data.tsv");
    writetable(panelB, panelBFile, "FileType", "text", "Delimiter", "\t");

    fig = figure("Color", "w", "Units", "pixels", "Position", [100 100 430 650]);

    ax1 = subplot(2, 1, 1);
    hold(ax1, "on");

    featureColors = [
        0.00 0.90 0.00
        1.00 0.00 0.00
    ];

    for f = 1:numel(refIdx)
        idx = refIdx(f);
        c = featureColors(f, :);

        mAcc = squeeze(mean_accuracy_all(:, 1, idx));
        hAcc = squeeze(mean_accuracy_all(:, 2, idx));
        sigM = squeeze(sigFeatures(idx, :, 1))';
        sigH = squeeze(sigFeatures(idx, :, 2))';

        plot(ax1, x(sigM), mAcc(sigM), "s", "Color", c, ...
            "MarkerFaceColor", "none", "MarkerSize", 5, ...
            "LineWidth", 1.4, "LineStyle", "none");

        plot(ax1, x(sigH), hAcc(sigH), "o", "Color", c, ...
            "MarkerFaceColor", "none", "MarkerSize", 5, ...
            "LineWidth", 1.4, "LineStyle", "none");

        plot(ax1, x(~sigM), mAcc(~sigM), "s", "Color", c, ...
            "MarkerFaceColor", "none", "MarkerSize", 5, ...
            "LineWidth", 0.5, "LineStyle", "none");

        plot(ax1, x(~sigH), hAcc(~sigH), "o", "Color", c, ...
            "MarkerFaceColor", "none", "MarkerSize", 5, ...
            "LineWidth", 0.5, "LineStyle", "none");
    end

    xline(ax1, 3.5, "--", "Color", [0.75 0.75 0.75], "LineWidth", 1);
    xline(ax1, 6.5, "--", "Color", [0.75 0.75 0.75], "LineWidth", 1);
    yline(ax1, 0.5, "-", "Color", [0.75 0.75 0.75], "LineWidth", 0.5);

    xlim(ax1, [0.5 9.5]);
    ylim(ax1, [0.35 0.90]);
    xticks(ax1, [2 5 8]);
    xticklabels(ax1, {"Parietal", "Temporal", "Frontal"});
    ylabel(ax1, "Accuracy");
    box(ax1, "off");
    set(ax1, "TickDir", "out", "FontName", "Arial", "FontSize", 10);

    hM = plot(ax1, nan, nan, "ks", "MarkerFaceColor", "none", "MarkerSize", 5, "LineWidth", 1.2);
    hH = plot(ax1, nan, nan, "ko", "MarkerFaceColor", "none", "MarkerSize", 5, "LineWidth", 1.2);
    legend(ax1, [hM hH], {"Macaque", "Human"}, "Location", "southeast", "Box", "off", "FontSize", 8);

    text(ax1, -0.20, 1.04, "A", "Units", "normalized", ...
        "FontName", "Arial", "FontWeight", "bold", "FontSize", 16);

    ax2 = subplot(2, 1, 2);
    hold(ax2, "on");

    plot(ax2, x, nSig_accuracy(:, 1), "ks", ...
        "MarkerFaceColor", "none", "MarkerSize", 5, "LineWidth", 1.3, "LineStyle", "none");

    plot(ax2, x, nSig_accuracy(:, 2), "ko", ...
        "MarkerFaceColor", "none", "MarkerSize", 5, "LineWidth", 1.3, "LineStyle", "none");

    plot(ax2, x, nSig_accuracy(:, 3), "kx", ...
        "MarkerSize", 6, "LineWidth", 1.3, "LineStyle", "none");

    xline(ax2, 3.5, "--", "Color", [0.75 0.75 0.75], "LineWidth", 1);
    xline(ax2, 6.5, "--", "Color", [0.75 0.75 0.75], "LineWidth", 1);

    xlim(ax2, [0.5 9.5]);
    ylim(ax2, [0 5200]);
    xticks(ax2, [2 5 8]);
    xticklabels(ax2, {"Parietal", "Temporal", "Frontal"});
    ylabel(ax2, "#Significant features");
    box(ax2, "off");
    set(ax2, "TickDir", "out", "FontName", "Arial", "FontSize", 10);

    legend(ax2, {"Macaque", "Human", "Both"}, "Location", "southeast", "Box", "off", "FontSize", 8);

    text(ax2, -0.20, 1.04, "B", "Units", "normalized", ...
        "FontName", "Arial", "FontWeight", "bold", "FontSize", 16);

    figBase = fullfile(outDir, "suppfig1_epoch6s_replot");

    savefig(fig, figBase + ".fig");
    saveas(fig, figBase + ".png");
    saveas(fig, figBase + ".pdf");

    close(fig);

    readmeFile = fullfile(outDir, "README_suppfig1_epoch6s_replot.txt");
    fid = fopen(readmeFile, "w");
    fprintf(fid, "Purpose: reproduce Supplementary Figure 1-like 6-s epoch figure from local copied outputs only.\n");
    fprintf(fid, "No HCTSA recomputation. No nearest-median classification rerun.\n\n");
    fprintf(fid, "Local data directory:\n%s\n\n", dataDir);
    fprintf(fid, "Input aggregate MAT:\n%s\n\n", compareMat);
    fprintf(fid, "Operation source MAT:\n%s\n\n", pairMat);
    fprintf(fid, "Reference CodeStrings:\n");
    for i = 1:numel(refCodeStrings)
        fprintf(fid, "  %d: %s, feature_index_matlab1=%d\n", i, refCodeStrings(i), refIdx(i));
    end
    fclose(fid);

    out = struct;
    out.outDir = outDir;
    out.figureFig = figBase + ".fig";
    out.figurePng = figBase + ".png";
    out.figurePdf = figBase + ".pdf";
    out.panelAData = panelAFile;
    out.panelBData = panelBFile;
    out.readme = readmeFile;

    fprintf("DONE replot_suppfig1_epoch6s_from_local_data\n");
    fprintf("outDir: %s\n", outDir);
    fprintf("figure png: %s\n", out.figurePng);
end
