#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="${MODEL_DIR:-/models}"
ENGINE_PATH="${ENGINE_PATH:-${MODEL_DIR}/engines/owl_image_encoder_patch32.engine}"
PORT="${PORT:-7860}"
CAMERA_INDEX="${CAMERA_INDEX:-0}"
OFFLINE_MODE="${OFFLINE_MODE:-auto}"   # auto|0|1
OFFLINE_READY_MARKER="${OFFLINE_READY_MARKER:-${MODEL_DIR}/.offline-ready}"

HF_HOME="${HF_HOME:-${MODEL_DIR}/cache/huggingface}"
TRANSFORMERS_CACHE="${TRANSFORMERS_CACHE:-${HF_HOME}}"
TORCH_HOME="${TORCH_HOME:-${MODEL_DIR}/cache/torch}"
CLIP_DOWNLOAD_ROOT="${CLIP_DOWNLOAD_ROOT:-${MODEL_DIR}/cache/clip}"
HOME="${HOME:-${MODEL_DIR}/cache/home}"

export HF_HOME TRANSFORMERS_CACHE TORCH_HOME CLIP_DOWNLOAD_ROOT HOME OFFLINE_READY_MARKER

mkdir -p "$(dirname "${ENGINE_PATH}")" "${HF_HOME}" "${TORCH_HOME}" "${CLIP_DOWNLOAD_ROOT}" "${HOME}"

if [[ "${OFFLINE_MODE}" == "1" || "${OFFLINE_MODE}" == "true" || "${OFFLINE_MODE}" == "yes" || "${OFFLINE_MODE}" == "on" ]]; then
  echo "[bootstrap] offline mode forced"
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 NANOOWL_LOCAL_FILES_ONLY=1
elif [[ "${OFFLINE_MODE}" == "auto" && -f "${OFFLINE_READY_MARKER}" ]]; then
  echo "[bootstrap] offline mode auto-enabled (marker found: ${OFFLINE_READY_MARKER})"
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 NANOOWL_LOCAL_FILES_ONLY=1
else
  echo "[bootstrap] offline mode disabled for this run (preparing cache if needed)"
fi

python3 - <<'PY'
import os
import subprocess
from nanoowl.owl_predictor import OwlPredictor
from nanoowl.tree_predictor import TreePredictor
from nanoowl.tree import Tree

engine = os.environ["ENGINE_PATH"]
if not os.path.exists(engine):
    print(f"[bootstrap] engine not found, building: {engine}", flush=True)
    subprocess.run(["python3", "-m", "nanoowl.build_image_encoder_engine", engine], check=True)
else:
    print(f"[bootstrap] engine exists: {engine}", flush=True)

print("[bootstrap] warmup start", flush=True)
owl = OwlPredictor(image_encoder_engine=engine)
tp = TreePredictor(owl_predictor=owl)
tree = Tree.from_prompt("[a person]")
tp.encode_clip_text(tree)
tp.encode_owl_text(tree)
print("[bootstrap] warmup done", flush=True)
marker = os.environ.get("OFFLINE_READY_MARKER")
if marker:
    with open(marker, "w", encoding="utf-8") as f:
        f.write("ready\n")
    print(f"[bootstrap] offline marker updated: {marker}", flush=True)
PY

cd /opt/nanoowl/examples/tree_demo
exec python3 tree_demo.py "${ENGINE_PATH}" --host 0.0.0.0 --port "${PORT}" --camera "${CAMERA_INDEX}"
