#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM/tensorrt-edgellm-workspace"

mkdir -p "${WORKSPACE_DIR}"

cat > "${WORKSPACE_DIR}/input_qwen.json" << 'EOF_JSON'
{
    "batch_size": 1,
    "temperature": 1.0,
    "top_p": 1.0,
    "top_k": 50,
    "max_generate_length": 512,
    "requests": [
        {
            "messages": [
                {
                    "role": "user",
                    "content": "Explain the benefits of running large language models locally on NVIDIA Jetson Thor."
                }
            ]
        }
    ]
}
EOF_JSON

echo "Created: ${WORKSPACE_DIR}/input_qwen.json"
