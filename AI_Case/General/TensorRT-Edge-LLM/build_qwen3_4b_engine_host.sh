#!/usr/bin/env bash
set -euo pipefail

cd "/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM/TensorRT-Edge-LLM"

export MODEL_NAME=Qwen3-4B-Instruct
export WORKSPACE_DIR="/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM/tensorrt-edgellm-workspace"
export EDGELLM_PLUGIN_PATH="/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM/TensorRT-Edge-LLM/build/libNvInfer_edgellm_plugin.so"

mkdir -p "${WORKSPACE_DIR}/${MODEL_NAME}/engine"

/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM/TensorRT-Edge-LLM/build/examples/llm/llm_build \
    --onnxDir "${WORKSPACE_DIR}/${MODEL_NAME}/onnx" \
    --engineDir "${WORKSPACE_DIR}/${MODEL_NAME}/engine" \
    --maxBatchSize 1 \
    --maxInputLen 1024 \
    --maxKVCacheCapacity 4096
