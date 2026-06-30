# 6-s epoch Supplementary Figure 1 replot

This folder contains MATLAB scripts for regenerating the 6-s epoch Supplementary Figure 1-like output from copied analysis-level outputs.

## Main script

Run:

    run_reproduce_suppfig1_epoch6s.m

## Required data

The required analysis-level data are not included in this public repository. They are available separately on Monash Bridges as `data_supplementary_figure_1`.

The script expects a data directory containing:

- `aggregate/compareValidation.mat`
- `aggregate/nSig_accuracy_epoch6s_3lobe.tsv`
- `pair_accuracy_mats/*_accuracy.mat`
- `operations/epoch6s_operations_codestring.tsv`

Set the data directory with:

    export XSPECIES_EPOCH6S_SUPPFIG1_DATA_DIR="/path/to/data_supplementary_figure_1"

Then run from this folder:

    module purge
    module load matlab/r2023a
    matlab -nodisplay -nosplash -batch "run_reproduce_suppfig1_epoch6s; exit"

## Notes

This script regenerates the figure from copied analysis-level outputs.

It does not recompute HCTSA features and does not rerun the nearest-median classification from raw HCTSA outputs.

Generated figure files and large analysis outputs are intentionally not included in this repository.
