# Code scope

## Scope

This document records which code is included in this repository and which code remains outside this repository.

## Included: 200 ms Stage2 HCTSA execution

Slurm entrypoints:

```text
ops/hctsa/sbatch/sbatch_stage2_human_array_long72.sbatch
ops/hctsa/sbatch/sbatch_stage2_macaque_array.sbatch
```

Drivers:

```text
ops/hctsa/drivers/driver_stage2_human_onech.m
ops/hctsa/drivers/driver_stage2_macaque_onech.m
```

Wrappers:

```text
ops/hctsa/wrappers/main_hctsa_1_init_patched.m
ops/hctsa/wrappers/main_hctsa_2_compute_local_patched_nopool.m
ops/hctsa/wrappers/add_toolbox.m
ops/hctsa/wrappers/bootstrap_stage1_ab.m
ops/hctsa/wrappers/force_findpeaks_matlab.m
```

Postprocess:

```text
ops/hctsa/postprocess/main_hctsa_3_postProcess_patched.m
```

Patch copies:

```text
ops/hctsa/patches/MF_steps_ahead.m
ops/hctsa/patches/NL_TISEAN_fnn.m
```

## Included: 6 s HCTSA execution

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

## Included: 6 s classification

```text
ops/hctsa/epoch6s_classification/NMclassification_selectCh_epoch6s_3lobe.m
ops/hctsa/epoch6s_classification/compareValidation_epoch6s_3lobe.m
```

## Excluded

The following are intentionally not included:

- coauthor-generated preprocessing scripts
- label-check scripts
- scratch/test/backup scripts
- 200 ms nearest-median classifier core scripts from the Stage1 canonical repository
- generated `.mat`, `.fig`, `.png`, `.pdf`, `.out`, and `.out.gz` files

## Dependency on Stage1 canonical codebase

The 200 ms nearest-median classifier core is primarily maintained in the Stage1 canonical codebase by Daisuke and collaborators. This repository avoids duplicating that core code unless a Stage2-specific wrapper or provenance file is required.
