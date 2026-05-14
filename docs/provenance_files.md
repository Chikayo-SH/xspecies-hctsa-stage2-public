# Provenance files

## Scope

This document explains the lightweight public provenance files included under `ops/hctsa/provenance/`.

The private/internal repository retains raw provenance files with local absolute paths. This public release includes sanitized or summarized provenance files only.

## File inventory

| File | Purpose | Notes |
|---|---|---|
| `stage2_final_hctsa_paths_summary.tsv` | Summary of the final 200 ms HCTSA `.mat` output set | Summarizes 1524 paths by species, subject, and run tag without exposing local absolute paths |
| `stage2_final_runtag_counts.tsv` | Run tag count table | Contains run-tag counts and no local absolute paths |
| `stage2_used_code_manifest.public.tsv` | Sanitized manifest of Stage2 execution code included in this repository | Local source paths are replaced with placeholders |
| `epoch6s_pipeline_evidence.public.tsv` | Sanitized epoch 6 s pipeline evidence | Local log/repo paths are replaced with placeholders |
| `epoch6s_3lobe_outputs_filelist.public.tsv` | Sanitized epoch 6 s / 3-lobe output file listing | Contains basenames, sizes, and timestamps only |

## Exclusion policy

Do not include:

- raw provenance files containing local absolute paths
- label-check `.m` files
- scratch / test / backup / m3test / obs files
- generated `.mat`, `.fig`, `.png`, `.pdf`, `.out`, and `.out.gz` files
- preprocess scripts made by coauthors
- 200 ms nearest-median classifier core scripts from the Stage1 canonical repository

## Rationale

Large generated outputs and local machine-specific paths are intentionally excluded from this public release. The repository includes scripts, dependency information, and sanitized provenance sufficient to identify the execution scope without exposing local HPC paths.
