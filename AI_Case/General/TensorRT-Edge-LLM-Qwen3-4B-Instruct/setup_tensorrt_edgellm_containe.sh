#!/usr/bin/env bash
set -euo pipefail

cd /workspace

git clone https://github.com/NVIDIA/TensorRT-Edge-LLM.git
cd TensorRT-Edge-LLM
git checkout v0.7.1
git submodule update --init --recursive

python3 -m venv --system-site-packages venv
source venv/bin/activate

pip3 install --no-deps .
sed '/^torch/d' requirements.txt > /tmp/reqs.txt
pip3 install -r /tmp/reqs.txt

export WORKSPACE_DIR=/workspace/tensorrt-edgellm-workspace
