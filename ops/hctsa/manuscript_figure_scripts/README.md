# Manuscript figure scripts

This folder contains MATLAB scripts used to reproduce manuscript figures from analysis-level data stored outside this repository.

Large data files and generated figure files are not included in this repository.

## Software

The scripts were prepared and tested using MATLAB R2023a on a Linux/HPC environment.

## Data

The corresponding analysis-level data are available separately on Monash Bridges.

## Script-data mapping

- `script_figure1.m`
  - data: `data_figure1.mat`

- `script_figure2.m`
  - data: `data_figure2A.mat`, `data_figure2B.mat`, `data_figure2CD.mat`

- `script_figure3.m`
  - data: `data_figure3.mat`

- `script_figure4.m`
  - data: `data_figure4.mat`

- `script_figure5.m`
  - data: `data_figure5.mat`

- `script_figure6.m`
  - data: `data_figure6.mat`

- `script_fig7abc.m`, `script_fig7d.m`, `script_fig8.m`
  - data: `data_figure_7 & 8`

- `script_supplementary_figure1.m`
  - data: `data_supplementary_figure_1`

- `script_supplementary_figure2.m`
  - data: `data_supplementary_figure2.mat`

- `script_supplementary_figure3.m`
  - data: `data_supplementary_figure3.mat`

## Supplementary Figure 1

Before running `script_supplementary_figure1.m`, set:

    export XSPECIES_EPOCH6S_SUPPFIG1_DATA_DIR="/path/to/data_supplementary_figure_1"

Then run in MATLAB from this folder:

    script_supplementary_figure1

This script regenerates the 6-s epoch Supplementary Figure 1-like output from copied analysis-level outputs. It does not recompute HCTSA features and does not rerun nearest-median classification from raw HCTSA outputs.


## Notes on helper functions

- `topoplot.m` is a project-specific helper for plotting ECoG channel locations from MNI coordinates and lobe labels. It is not the EEGLAB `topoplot` function.


## Data directory environment variables

Because large analysis-level data files are not included in this repository, some scripts require data directories to be specified using environment variables.

Common variables:

- `XSPECIES_STAGE1_REANALYSIS_DIR`
  - Directory containing Stage 1 reanalysis figure data such as `data_figure1.mat`, `data_figure2A.mat`, `data_figure3.mat`, and `data_figure4.mat`.

- `XSPECIES_STAGE2_ANALYSIS_DIR`
  - Directory containing Stage 2 figure data, including the `data/` subdirectory used by some scripts.

- `XSPECIES_EPOCH6S_SUPPFIG1_DATA_DIR`
  - Directory containing `data_supplementary_figure_1` for the 6-s epoch Supplementary Figure 1-like output.

- `XSPECIES_KIRILL_STAGE2_DIR`
  - Directory containing human intracranial channel-location data used by helper functions.

- `XSPECIES_NEUROTYCHO_CHANNELMAP_DIR`
  - Directory containing macaque channel-map data used by helper functions.
