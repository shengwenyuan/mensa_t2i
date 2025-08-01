#!/bin/bash
#SBATCH --job-name=lora-train
#SBATCH --partition=dllabdlc_gpu-rtx2080
#SBATCH --gres=gpu:1
#SBATCH --mem=40G
#SBATCH --time=12:00:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

# load CUDA drivers (pick your installed version)
module load cuda/11.7

#! Change to your own paths
CONDA_ROOT=/work/dlclarge2/alidemaa-dl_lab/conda/miniconda3
source "$CONDA_ROOT/etc/profile.d/conda.sh"
conda activate dllab

cd /work/dlclarge2/alidemaa-dl_lab/mensa_t2i/lora

# double-check PyTorch sees the GPU
python - <<EOF
import torch
print("cuda available:", torch.cuda.is_available())
print("cuda device count:", torch.cuda.device_count())
EOF

# launch with Accelerate
export MODEL="runwayml/stable-diffusion-v1-5"
accelerate launch train_text_to_image_lora.py \
  --pretrained_model_name_or_path="$MODEL" \
  --csv_file="/work/dlclarge2/alidemaa-dl_lab/mensa_t2i/data/meals_raw_2025-07-09_2024-01-01.csv" \
  --resolution=512 \
  --train_batch_size=1 \
  --max_train_steps=30000 \
  --learning_rate=2e-4 \
  --rank=8 \
  --output_dir="./lora-adapters-second-train" \
  --push_to_hub \
  --hub_model_id="username/my-lora-model-second-train" \
  --log_dir="/work/dlclarge2/alidemaa-dl_lab/mensa_t2i/logs" \
