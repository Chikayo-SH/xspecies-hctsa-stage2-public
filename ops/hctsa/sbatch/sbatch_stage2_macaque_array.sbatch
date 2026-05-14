#!/usr/bin/env bash
#SBATCH --job-name=st2_macaque_hctsa
#SBATCH --array=2-189%50
#SBATCH --partition=comp
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=72:00:00
#SBATCH --output=<PROJECT_ROOT>/COSproject_A/04_pipelines/stage2_macaque_hctsa/logs/%x_%A_%a.out
#SBATCH --error=<PROJECT_ROOT>/COSproject_A/04_pipelines/stage2_macaque_hctsa/logs/%x_%A_%a.err

set -euo pipefail
unset DRYRUN

# Thread control (force single-thread per task)
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

ROOT="<PROJECT_ROOT>/COSproject_A"
WRAP="<PROJECT_ROOT>/04_pipelines/xspecies_wrapper"
HCTSA_A="<HCTSA_REPO>"

WORKDIR="${ROOT}/04_pipelines/stage2_macaque_hctsa"
DEFAULT_TASKS="${WORKDIR}/tasks/tasks_macaque_chibi.tsv"
TASKS_TSV="${TASKS_TSV_OVERRIDE:-$DEFAULT_TASKS}"

DRIVER_M="<PROJECT_ROOT>/04_pipelines/xspecies_wrapper_stage2/driver_stage2_macaque_onech.m"

mkdir -p "${WORKDIR}/logs"

if [[ -z "${RUN_TAG:-}" ]]; then
  RUN_TAG="stage2_macaque_$(date +%Y%m%d)_${SLURM_JOB_ID:-manual}"
fi
export RUN_TAG

line="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${TASKS_TSV}" || true)"
if [[ -z "${line}" ]]; then
  echo "ERROR: No line for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID} in ${TASKS_TSV}" 1>&2
  exit 1
fi

export SUBJECT="$(printf "%s" "${line}" | cut -f1)"  # Chibi_20120730 / Chibi_20120802
export CH="$(printf "%s" "${line}" | cut -f2)"

echo "RUN_TAG=${RUN_TAG}"
echo "TASKS_TSV=${TASKS_TSV}"
echo "SUBJECT=${SUBJECT}"
echo "CH=${CH}"
echo "ROOT=${ROOT}"
echo "WRAP=${WRAP}"
echo "HCTSA_A=${HCTSA_A}"

module purge
module load matlab/r2023a

# --- MATLAB prefs isolation (safe) ---
if [ -n "${SLURM_TMPDIR:-}" ] && [ -d "${SLURM_TMPDIR}" ]; then
  export HOME="${SLURM_TMPDIR}/home_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
else
  export HOME="<TMPDIR>/home_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
fi
mkdir -p "${HOME}/.matlab/R2023a"
# ------------------------------------

matlab -batch "addpath('${WRAP}'); addpath('<PROJECT_ROOT>/04_pipelines/xspecies_wrapper_stage2'); bootstrap_stage1_ab('${HCTSA_A}','${ROOT}'); cd('${WRAP}'); run('${DRIVER_M}'); exit"
