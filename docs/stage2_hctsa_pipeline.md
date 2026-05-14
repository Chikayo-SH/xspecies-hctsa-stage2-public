# Stage2 HCTSA pipeline

## Scope

This document summarizes the main Stage2 200 ms HCTSA execution pipeline and lightweight metadata summaries included in this repository.

## Final Stage2 200 ms pipeline

Final status TSV:

```text
<LOCAL_STAGE2_REPO>/ops/job_audit/2026-02-03/run/postprocess_merged_status.updated_after_market_missing_82.tsv
```

Final HCTSA `.mat` output summary:

```text
ops/hctsa/provenance/stage2_final_hctsa_paths_summary.tsv
```

Notes:

- summarizes 1524 final HCTSA `.mat` outputs by species, subject, and run tag
- raw absolute path lists are retained only in the private/internal repository

Run tag count table:

```text
ops/hctsa/provenance/stage2_final_runtag_counts.tsv
```

## HCTSA / MATLAB environment

HCTSA repo:

```text
<HCTSA_REPO>
```

HCTSA commit:

```text
4e493c6acc24ffe4a53b1b0790348a6278227f61
```

HCTSA describe:

```text
v1.09-3-g4e493c6a-dirty
```

MATLAB:

```text
9.14.0.2337262 (R2023a) Update 5 release=2023a
```

xspecies repo:

```text
<PROJECT_ROOT>/repos/xspecies_blind_classify
```

xspecies commit:

```text
25df10dad6b9b681ef58b1d96ba0b095d7c08008
```

## 200 ms execution code included in this repository

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

## Reproducibility checklist

- Confirm the final status TSV.
- Confirm that `stage2_final_hctsa_paths_summary.tsv` summarizes the 1524 final HCTSA `.mat` outputs.
- Confirm MATLAB and HCTSA versions before rerunning.
- Confirm xspecies classifier code commit before interpreting classification outputs.
