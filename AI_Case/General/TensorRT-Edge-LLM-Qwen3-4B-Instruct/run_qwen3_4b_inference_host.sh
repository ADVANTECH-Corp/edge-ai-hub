#!/usr/bin/env bash
set -euo pipefail

export WORKSPACE_DIR=/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM-Qwen3-4B-Instruct/tensorrt-edgellm-workspace

/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM-Qwen3-4B-Instruct/TensorRT-Edge-LLM/build/examples/llm/llm_inference \
    --engineDir $WORKSPACE_DIR/Qwen3-4B-Instruct/engine \
    --inputFile $WORKSPACE_DIR/input_qwen.json \
    --outputFile $WORKSPACE_DIR/output_qwen.json \
    --dumpOutput
