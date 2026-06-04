#!/bin/bash
#SBATCH --ntasks-per-node 16
#SBATCH -J chai_ex
#SBATCH -o run_restr_example.out
#SBATCH -e run_restr_example.err
#SBATCH -p q1
#SBATCH --gres=gpu:1
# chai-lab RGI example runner. GPU work must go through sbatch (not the login node).
# Submit from THIS repo directory:  cd chai-lab_restr && sbatch run_restr_example.sh
set -e
cd "${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source .venv/bin/activate

export PATH="$HOME/.local/bin:$PATH"
python -c "import yaml" 2>/dev/null || uv pip install pyyaml   # chai1.py imports yaml (not a chai dep)
export CHAI_DOWNLOADS_DIR="${CHAI_DOWNLOADS_DIR:-$HOME/.cache/chai}"

rm -rf out_restr_example
# restr_example.yaml IS the restraints_config dict at top level (chai sidecar style).
# RGI: rgi_utils minimizes distance + conformer restraints on the x0 prediction each step.
# (fasta & out_dir are POSITIONAL; chai exposes no bond orders, so dihedrals=0 here.)
python -m chai_lab.main fold \
    restr_example.fasta \
    out_restr_example \
    --restraints-config-path restr_example.yaml \
    --num-diffn-timesteps 200 --num-diffn-samples 2 --seed 0 \
    --no-use-esm-embeddings

CIF=$(find out_restr_example -name '*.cif' | head -1)
echo "prediction: $CIF"
echo done
