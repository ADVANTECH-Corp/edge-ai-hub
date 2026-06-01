#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

sudo chown -R "$(whoami):$(whoami)" tensorrt-edgellm-workspace
sudo chown -R "$(whoami):$(whoami)" TensorRT-Edge-LLM

sudo apt update
sudo apt install -y \
    cmake \
    build-essential \
    git \
    cuda-toolkit-13-0 \
    libnvinfer-headers-dev \
    libnvinfer-dev \
    libnvonnxparsers-dev

export PATH=/usr/local/cuda/bin:${PATH}

nvcc --version

cd TensorRT-Edge-LLM

rm -rf build
mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DTRT_PACKAGE_DIR=/usr \
    -DCMAKE_TOOLCHAIN_FILE=cmake/aarch64_linux_toolchain.cmake \
    -DEMBEDDED_TARGET=jetson-thor

make -j"$(nproc)"
