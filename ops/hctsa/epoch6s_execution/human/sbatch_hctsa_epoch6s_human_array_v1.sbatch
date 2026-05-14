#!/usr/bin/env bash
#SBATCH --job-name=epoch6s_hum_hctsa
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
TASKS_TSV="${TASKS_TSV_OVERRIDE:-<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_human_20260407/tasks_human_epoch6s.tsv}"
DRIVER_M="<LOCAL_STAGE2_REPO>/ops/hctsa_epoch6s_human_20260407/driver_stage2_human_onech_epoch6s_v1.m"

ARRAY_ROOT_JOB_ID="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-manual}}"

if [[ -z "${RUN_TAG:-}" ]]; then
  RUN_TAG="epoch6s_human_${ARRAY_ROOT_JOB_ID}"
fi
export RUN_TAG

if [[ -z "${OUT_DIR:-}" ]]; then
  OUT_DIR="<PROJECT_ROOT>/COSproject/hctsa_subtractMean_removeLineNoise_${RUN_TAG}"
fi
export OUT_DIR

line="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${TASKS_TSV}" || true)"
if [[ -z "${line}" ]]; then
  echo "ERROR: No line for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID} in ${TASKS_TSV}" 1>&2
  exit 1
fi

export SUBJECT="$(printf "%s" "${line}" | cut -f1)"
export CH="$(printf "%s" "${line}" | cut -f2)"

echo "[START] $(date) array_job=${SLURM_ARRAY_JOB_ID:-na} job=${SLURM_JOB_ID:-manual} task=${SLURM_ARRAY_TASK_ID:-na} run_tag=${RUN_TAG} out_dir=${OUT_DIR} subject=${SUBJECT} ch=${CH}"

module purge
module load matlab/r2023a

if [ -n "${SLURM_TMPDIR:-}" ] && [ -d "${SLURM_TMPDIR}" ]; then
  export HOME="${SLURM_TMPDIR}/home_${SLURM_JOB_ID:-manual}_${SLURM_ARRAY_TASK_ID:-na}"
else
  export HOME="<TMPDIR>/home_${SLURM_JOB_ID:-manual}_${SLURM_ARRAY_TASK_ID:-na}"
fi
mkdir -p "${HOME}/.matlab/R2023a"

if [[ "${DRYRUN:-0}" == "1" ]]; then
  matlab -batch "run('${DRIVER_M}'); exit"
else
  matlab -batch "addpath('<PROJECT_ROOT>/04_pipelines/xspecies_wrapper'); addpath('<PROJECT_ROOT>/04_pipelines/xspecies_wrapper_stage2'); addpath('<LOCAL_STAGE2_REPO>/ops/job_audit/2026-02-03/run/audit_2026-02-16_1722_stage2'); bootstrap_stage1_ab('<HCTSA_REPO>','<PROJECT_ROOT>/COSproject'); run('${DRIVER_M}'); exit"
fi

echo "[END] $(date) array_job=${SLURM_ARRAY_JOB_ID:-na} job=${SLURM_JOB_ID:-manual} task=${SLURM_ARRAY_TASK_ID:-na} run_tag=${RUN_TAG} out_dir=${OUT_DIR} subject=${SUBJECT} ch=${CH}"
