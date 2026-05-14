# Epoch 6 s HCTSA pipeline

## Scope

This document summarizes the epoch 6 s HCTSA execution pipeline, 3-lobe classification scripts, and output provenance.

## Human 6 s HCTSA run

Job ID:

```text
54608906
```

Representative log:

```text
<PROJECT_ROOT>/logs/epoch6s_hum_hctsa_54608906_1.out
```

Output root:

```text
<PROJECT_ROOT>/COSproject/hctsa_subtractMean_removeLineNoise_epoch6s_human_54608906
```

## Macaque 6 s HCTSA run

Job ID used for log search:

```text
54572633
```

Representative log:

```text
<PROJECT_ROOT>/logs/epoch6s_mac_hctsa_54572633_1.out
```

Note:

```text
representative log internally shows job=54572634 and run_tag=epoch6s_macaque_54572634
```

Output root:

```text
<PROJECT_ROOT>/COSproject/hctsa_subtractMean_removeLineNoise_epoch6s_macaque_54572634
```

## findpeaks path check

Across epoch 6 s logs, extracted `which_findpeaks_after_force` paths were:

```text
2166 /usr/local/matlab/r2023a/toolbox/signal/signal/findpeaks.m
```

## 6 s execution scripts included in this repository

Human:

```text
ops/hctsa/epoch6s_execution/human/sbatch_hctsa_epoch6s_human_array_v1.sbatch
ops/hctsa/epoch6s_execution/human/driver_stage2_human_onech_epoch6s_v1.m
ops/hctsa/epoch6s_execution/human/main_hctsa_1_init_epoch6s_patched_humanlabel.m
ops/hctsa/epoch6s_execution/human/main_hctsa_2_compute_epoch6s_patched_nopool.m
```

Macaque:

```text
ops/hctsa/epoch6s_execution/macaque/sbatch_hctsa_epoch6s_macaque_array.sbatch
ops/hctsa/epoch6s_execution/macaque/driver_stage2_macaque_onech_epoch6s.m
ops/hctsa/epoch6s_execution/macaque/main_hctsa_1_init_epoch6s_patched.m
ops/hctsa/epoch6s_execution/macaque/main_hctsa_2_compute_epoch6s_patched_nopool.m
```

## 6 s classification scripts

```text
ops/hctsa/epoch6s_classification/NMclassification_selectCh_epoch6s_3lobe.m
ops/hctsa/epoch6s_classification/compareValidation_epoch6s_3lobe.m
```

`NMclassification_selectCh_epoch6s_3lobe.m` is a minimal wrapper for the 6 s / 3-lobe / 9-channel analysis. It runs nearest-median classifiers for each matched channel pair and saves per-pair results.

`compareValidation_epoch6s_3lobe.m` reads per-pair results, saves `compareValidation.mat`, and generates Panel-B-style summary figures.

## 6 s provenance files

```text
ops/hctsa/provenance/epoch6s_pipeline_evidence.tsv
ops/hctsa/provenance/epoch6s_3lobe_outputs_filelist.tsv
```

## Output directory

```text
<PROJECT_ROOT>/COSproject_A/results_subtractMean_removeLineNoise_epoch6s_3lobe
```

This directory contained 47 files, including:

- `compareValidation.mat`
- per-pair `*_accuracy.mat`
- `nSig_accuracy_epoch6s_3lobe.tsv`
- summary figure files

Large outputs are not included in GitHub. Only the file listing is included:

```text
ops/hctsa/provenance/epoch6s_3lobe_outputs_filelist.tsv
```
