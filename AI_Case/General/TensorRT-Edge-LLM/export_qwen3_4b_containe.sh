#!/usr/bin/env bash
set -euo pipefail

cd /workspace/TensorRT-Edge-LLM

source venv/bin/activate

export WORKSPACE_DIR=/workspace/tensorrt-edgellm-workspace
export MODEL_NAME=Qwen3-4B-Instruct

mkdir -p "${WORKSPACE_DIR}"
cd "${WORKSPACE_DIR}"

rm -rf "${MODEL_NAME}/quantized" "${MODEL_NAME}/onnx"

tensorrt-edgellm-quantize-llm \
    --model_dir Qwen/Qwen3-4B-Instruct-2507 \
    --output_dir "${MODEL_NAME}/quantized" \
    --quantization nvfp4 \
    --dataset_dir abisee/cnn_dailymail

tensorrt-edgellm-export-llm \
    --model_dir "${MODEL_NAME}/quantized" \
    --output_dir "${MODEL_NAME}/onnx"
