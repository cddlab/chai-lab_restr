#!/bin/bash
#SBATCH --ntasks-per-node 16
#SBATCH -J chai_grp
#SBATCH -o run_grp_test.out
#SBATCH -e run_grp_test.err
#SBATCH -p q3
#SBATCH --gres=gpu:1
set -e
cd "${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source .venv/bin/activate
export PATH="$HOME/.local/bin:$PATH"
python -c "import yaml" 2>/dev/null || uv pip install pyyaml
export CHAI_DOWNLOADS_DIR="${CHAI_DOWNLOADS_DIR:-$HOME/.cache/chai}"
rm -rf out_grp_test
python -m chai_lab.main fold restr_example.fasta out_grp_test --restraints-config-path grp_test.yaml --num-diffn-timesteps 200 --num-diffn-samples 1 --seed 0 --no-use-esm-embeddings > run_grp_test.log 2>&1 || { echo "chai FAILED:"; tail -n 40 run_grp_test.log; exit 1; }
grep -iE "built spec|setup:|finalize" run_grp_test.log || true
CIF=$(find out_grp_test -name '*.cif' | head -1); echo "CIF: $CIF"
GP=.venv/bin/python
"$GP" ../check_angle.py "$CIF" 5-84 90-180 186-224 || true
"$GP" ../check_dihedral.py "$CIF" 5-50 51-100 101-150 151-224 || true
echo done
