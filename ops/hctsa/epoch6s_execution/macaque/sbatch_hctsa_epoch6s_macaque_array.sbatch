#!/usr/bin/env bash
#SBATCH --job-name=epoch6s_mac_hctsa
#SBATCH --array=1-336%50
#SBATCH --partition=comp
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=7-00:00:00
#SBATCH --output=<PROJECT_ROOT>/logs/%x_%A_%a.out
#SBATCH --error=<PROJECT_ROOT>/logs/%x_%A_%a.err

set -euo pipefail

export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

RUN_BASE="<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238"
TASKS_TSV="${TASKS_TSV_OVERRIDE:-<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238/tasks_macaque_epoch6s.tsv}"
DRIVER_M="<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238/driver_stage2_macaque_onech_epoch6s.m"

if [[ -z "${RUN_TAG:-}" ]]; then
  RUN_TAG="epoch6s_macaque_${SLURM_JOB_ID:-manual}"
fi
export RUN_TAG

line="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${TASKS_TSV}" || true)"
if [[ -z "${line}" ]]; then
  echo "ERROR: No line for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID} in ${TASKS_TSV}" 1>&2
  exit 1
fi

export SUBJECT="$(printf "%s" "${line}" | cut -f1)"
export CH="$(printf "%s" "${line}" | cut -f2)"

echo "[START] $(date) job=${SLURM_JOB_ID:-manual} task=${SLURM_ARRAY_TASK_ID:-na} run_tag=${RUN_TAG} subject=${SUBJECT} ch=${CH}"

module purge
module load matlab/r2023a

if [ -n "${SLURM_TMPDIR:-}" ] && [ -d "${SLURM_TMPDIR}" ]; then
  export HOME="${SLURM_TMPDIR}/home_${SLURM_JOB_ID:-manual}_${SLURM_ARRAY_TASK_ID:-na}"
else
  export HOME="<TMPDIR>/home_${SLURM_JOB_ID:-manual}_${SLURM_ARRAY_TASK_ID:-na}"
fi
mkdir -p "${HOME}/.matlab/R2023a"

if [[ "${DRYRUN:-0}" == "1" ]]; then
  matlab -batch "run('<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238/driver_stage2_macaque_onech_epoch6s.m'); exit"
else
  matlab -batch "addpath('<PROJECT_ROOT>/04_pipelines/xspecies_wrapper'); addpath('<PROJECT_ROOT>/04_pipelines/xspecies_wrapper_stage2'); addpath('<LOCAL_STAGE2_REPO>/ops/job_audit/2026-02-03/run/audit_2026-02-16_1722_stage2'); bootstrap_stage1_ab('<HCTSA_REPO>','<PROJECT_ROOT>/COSproject'); run('<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_macaque_20260406_2238/driver_stage2_macaque_onech_epoch6s.m'); exit"
fi

echo "[END] $(date) job=${SLURM_JOB_ID:-manual} task=${SLURM_ARRAY_TASK_ID:-na} run_tag=${RUN_TAG} subject=${SUBJECT} ch=${CH}"
