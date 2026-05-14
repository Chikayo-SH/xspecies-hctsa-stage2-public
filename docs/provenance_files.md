# Released code manifest

## Scope

This document explains the lightweight public code manifest included under `ops/hctsa/provenance/`.

The private/internal repository retains raw provenance files, local absolute paths, final output path lists, run-tag counts, and detailed local execution notes. This public release includes only a minimal code manifest that documents which Stage2 execution files are included in this repository.

## File inventory

| File | Purpose | Notes |
|---|---|---|
| `stage2_used_code_manifest.public.tsv` | Manifest of Stage2 execution code included in this repository | Local source paths are replaced with placeholders |

## Not included

This public release intentionally excludes:

- raw provenance files containing local absolute paths
- final HCTSA `.mat` path lists
- run-tag count tables
- detailed local job/log evidence files
- generated output file listings for figures and `.mat` files
- label-check `.m` files
- scratch / test / backup / m3test / obs files
- generated `.mat`, `.fig`, `.png`, `.pdf`, `.out`, and `.out.gz` files
- preprocess scripts made by coauthors
- 200 ms nearest-median classifier core scripts from the Stage1 canonical repository

## Rationale

The goal of this public repository is to provide the released Stage2 execution scripts, compatibility patch copies, documentation, and a minimal code manifest. Detailed local provenance and machine-specific paths are retained only in the private/internal repository for internal reproducibility checks.
