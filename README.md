# xspecies-hctsa-stage2-public

This repository contains release-oriented documentation, HCTSA execution scripts, compatibility patch copies, and provenance files for the Stage2 human/macaque ECoG cross-species HCTSA analysis.

## Overview

The repository is organized to document and reproduce the Stage2 HCTSA execution layer. It includes the main 200 ms HCTSA execution scripts, the epoch 6 s HCTSA execution scripts, selected epoch 6 s classification scripts, and lightweight provenance files.

Large generated outputs are intentionally not included.

## Where to start

- Main 200 ms Stage2 HCTSA pipeline: [docs/stage2_hctsa_pipeline.md](docs/stage2_hctsa_pipeline.md)
- Epoch 6 s HCTSA and classification pipeline: [docs/epoch6s_pipeline.md](docs/epoch6s_pipeline.md)
- Compatibility fixes: [docs/compatibility_fixes.md](docs/compatibility_fixes.md)
- Provenance file inventory: [docs/provenance_files.md](docs/provenance_files.md)
- Code scope and exclusions: [docs/code_scope.md](docs/code_scope.md)

## Repository contents

```text
.
├── README.md
├── docs/
├── diff/
├── manifests/
├── ops/hctsa/sbatch/
├── ops/hctsa/drivers/
├── ops/hctsa/wrappers/
├── ops/hctsa/postprocess/
├── ops/hctsa/patches/
├── ops/hctsa/epoch6s_execution/
├── ops/hctsa/epoch6s_classification/
└── ops/hctsa/provenance/
```

## Relationship to the Stage1 canonical codebase

This repository does not duplicate the main Stage1 nearest-median classifier core. The 200 ms nearest-median classifier core is maintained in the Stage1 canonical codebase. This repository focuses on Stage2 execution wrappers, patch copies, provenance, and Stage2-specific documentation.

See [docs/code_scope.md](docs/code_scope.md) for details.

## What is not included

The repository intentionally excludes:

- large `.mat` outputs
- generated figures
- scheduler logs
- scratch/test/backup files
- label-check scripts
- coauthor-generated preprocessing scripts
- 200 ms nearest-median classifier core scripts from the Stage1 canonical repository
- vendored third-party dependencies such as hctsa, Chronux, and JIDT

## Path configuration

Public-release scripts use placeholders such as `<PROJECT_ROOT>`, `<HCTSA_REPO>`, and `<LOCAL_STAGE2_REPO>` where the original analysis used local HPC paths. Users must replace these placeholders with their local paths before execution.

## Dependencies

Dependency versions, source URLs, commit hashes, checksums, and install locations are documented in:

- [manifests/DEPENDENCIES.md](manifests/DEPENDENCIES.md)

## Additional comparison document

- Stage1 vs Stage2 comparison: [diff/STAGE1_VS_STAGE2.md](diff/STAGE1_VS_STAGE2.md)
