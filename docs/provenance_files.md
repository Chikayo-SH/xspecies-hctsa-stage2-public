# Metadata and summary files

## Scope

This document explains the lightweight public metadata and summary files included under `ops/hctsa/provenance/`.

The private/internal repository retains raw provenance files with local absolute paths and detailed local execution notes. This public release includes only minimal, sanitized metadata summaries needed to document the released code scope and final output set at a high level.

## File inventory

| File | Purpose | Notes |
|---|---|---|
| `stage2_used_code_manifest.public.tsv` | Manifest of Stage2 execution code included in this repository | Local source paths are replaced with placeholders |
| `stage2_final_hctsa_paths_summary.tsv` | Summary of the final 200 ms HCTSA `.mat` output set | Summarizes 1524 outputs by species, subject, and run tag without exposing local absolute paths |
| `stage2_final_runtag_counts.tsv` | Run tag count table | Contains run-tag counts and no local absolute paths |

## Not included

This public release intentionally excludes:

- raw provenance files containing local absolute paths
- detailed local job/log evidence files
- generated output file listings for figures and `.mat` files
- label-check `.m` files
- scratch / test / backup / m3test / obs files
- generated `.mat`, `.fig`, `.png`, `.pdf`, `.out`, and `.out.gz` files
- preprocess scripts made by coauthors
- 200 ms nearest-median classifier core scripts from the Stage1 canonical repository

## Rationale

The goal of this public repository is to provide the released Stage2 execution scripts, compatibility patch copies, documentation, and lightweight metadata summaries. Detailed local provenance and machine-specific paths are retained only in the private/internal repository for internal reproducibility checks.
