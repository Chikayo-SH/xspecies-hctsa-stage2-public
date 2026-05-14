# Stage1 vs Stage2 (Gold vs Patched) — Verified Similarities and Differences

Date: 2026-01-30

This document summarizes what has been *verified* so far when comparing the
Stage2 wrapper code against the Stage1 “gold” reference in
`xspecies_blind_classify` at commit `25df10d...`.

The goal is to clarify:
- What is identical (core computational semantics preserved)
- What was intentionally changed (operational safety/reproducibility on HPC)

---

## Evidence: what was compared (ground truth)

### Stage1 (Gold) reference
Source repo (gold):
- `https://github.com/dshimaoka/xspecies_blind_classify.git`
- Commit:
  - `25df10dad6b9b681ef58b1d96ba0b095d7c08008` (short: `25df10d`)

Gold files used for comparison were extracted directly from the commit:
- `main_hctsa_1_init.m`
- `main_hctsa_2_compute_local.m`

Verification method:
- `git show <commit>:<path> | sha256sum` matched the saved `stage1_ref/*.m`
  files (i.e., `stage1_ref` is identical to the GitHub gold code at that
  commit).

### Stage2 (Patched) wrapper files executed in Stage2 pipeline
These Stage2 wrapper files were compared against Stage1 gold:
- `wrappers/main_hctsa_1_init_patched.m`
- `wrappers/main_hctsa_2_compute_local_patched_nopool.m`

Driver scripts (Stage2) that call these wrappers:
- `drivers/driver_stage2_human_onech.m`
- `drivers/driver_stage2_macaque_onech.m`

---

## 1) Verified similarities (Stage1 == Stage2)

### 1.1 Core hctsa calls and key arguments are preserved
**TS_Init**
- Stage1:
  - `TS_Init(loadName, 'hctsa', [false, false, false], hctsaName);`
- Stage2:
  - `TS_Init(tsName,  'hctsa', [false, false, false], hctsaName);`

The **mode and flags are identical**:
- 2nd arg: `'hctsa'`
- 3rd arg: `[false, false, false]`
- 4th arg: `hctsaName`

**TS_Compute**
- Stage1 and Stage2 both call:
  - `TS_Compute(true, [], [], [], hctsaName);`

Thus, the **core compute invocation and its arguments are unchanged**.

### 1.2 The time-series matrix construction logic is structurally the same
Both versions follow the same core approach:
- Take `data.data_proc`
- Create per-epoch/condition identifiers (labels/keywords)
- Reshape/permute into `(series x time)` matrix (`timeSeriesData`)
- Provide `labels` and `keywords` for hctsa ingestion

---

## 2) Verified differences (Stage1 != Stage2)

### 2.1 Stage2 avoids mutating preprocessed input files (major operational change)
Stage1 (gold) writes hctsa-required variables into the *preprocessed* input mat:
- `save(loadName, 'timeSeriesData', 'labels', 'keywords', '-append');`
- Then runs `TS_Init(loadName, ...)`

Stage2 (patched) writes a **run-specific TS file** and uses it as input:
- `save(tsName, 'timeSeriesData', 'labels', 'keywords');`  (no `-append`)
- Then runs `TS_Init(tsName, ...)`

**Effect**
- Stage2 preserves the original preprocessed `.mat` as immutable.
- This prevents accidental data contamination across reruns and users.

### 2.2 Stage2 introduces `runTag` to isolate outputs per run (reproducibility)
Stage2 adds an optional `runTag` (derived from env `RUN_TAG` when not provided),
and uses it to:
- Build run-specific output directories:
  - `save_base = 'hctsa' + preprocessSuffix + '_' + runTag`
- Name run-specific TS files:
  - `*_ts_<runTag>.mat`

**Effect**
- Outputs can be traced to a specific run/job submission.
- Multiple runs can coexist without overwriting each other.

### 2.3 Stage2 allows driver overrides (species/subject/preprocessSuffix/tgtChannels/runTag)
In Stage1 gold, key variables are fixed in-script:
- `species = 'macaque'`
- `subject = 'George'`
- `preprocessSuffix = '_subtractMean_removeLineNoise'`
- `tgtChannels` is loaded from `detectChannels_<subject>.mat`

In Stage2 patched, these can be set upstream (e.g., by driver scripts):
- If variables already exist, Stage2 uses them.
- Otherwise it falls back to Stage1-like defaults.

Additionally:
- Stage2 allows `tgtChannels` to be injected externally (e.g., to run one
  channel per Slurm task).

**Effect**
- Enables Slurm array design: **one task = one subject × one channel**
  (HPC-friendly and debuggable).

### 2.4 Stage2 disables explicit MATLAB parpool creation (“nopool” wrapper)
Stage1 gold explicitly creates a parallel pool:
- `parpool(nCores)` (if not already running)

Stage2 patched “nopool” wrapper comments this out:
- The parpool block is disabled (marked as `STAGE2_NOPARPOOL`).

**Effect**
- Avoids per-task parallel pool creation overhead on HPC.
- (Note: actual parallelism may still depend on hctsa internals and settings.)

### 2.5 Stage2 forces MATLAB’s builtin `findpeaks` resolution
Stage2 explicitly calls:
- `force_findpeaks_matlab();`

This aims to ensure:
- `findpeaks` resolves to MATLAB’s builtin implementation (not shadowed by
  other toolboxes).

### 2.6 Stage2 dumps compute source into logs (audit trail)
Stage2 compute wrapper prints its own source code into stdout:
- `fileread(mfilename("fullpath"))`

**Effect**
- The exact compute script used at runtime is recorded in the Slurm `.out`
  file (strong reproducibility evidence even if code changes later).

---

## Interpretation (high confidence)
Stage2 preserves the *core computational semantics* (TS_Init/TS_Compute call
signatures and the time-series formatting logic), while introducing
operational changes that improve:
- Safety: do not mutate preprocessed inputs
- Reproducibility: runTag-based output isolation + source dumps in logs
- HPC suitability: one-channel-per-task + no explicit parpool per task

---

## Next: postprocess (planned verification)
Gold reference (Stage1) postprocess:
- `xspecies_blind_classify` @ `25df10d...`:
  - `main_hctsa_3_postProcess.m`

Stage2 candidates found locally:
- `<PROJECT_ROOT>/04_pipelines/xspecies_wrapper/main_hctsa_3_postProcess_patched.m`
- `<PROJECT_ROOT>/04_pipelines/xspecies_wrapper/main_hctsa_3_postProcess_patched_ROOTFIX.m`

Next step:
- Extract gold postprocess into `stage1_ref/main_hctsa_3_postProcess.m`
  (already done)
- Diff each Stage2 candidate against gold and summarize:
  - algorithmic equivalence vs operational adjustments
  - any changes that affect feature filtering / valid-feature definition

---

## Notes / TODOs
- hctsa repo is at `v1.09-3-g4e493c6a` and shows local modifications
  (`Toolboxes/catch22`). If this affects results, it should be documented in
  Methods (not only README).
