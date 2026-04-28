# syntax=docker/dockerfile:1.6
# JetPack 7.x / L4T r38.x base image for Jetson Thor
# You can override BASE_IMAGE at build time if needed.
ARG BASE_IMAGE=nvcr.io/nvidia/cuda:13.0.0-runtime-ubuntu24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    libopenblas-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

WORKDIR /opt/nanoowl
COPY . /opt/nanoowl

# Core runtime deps used by NanoOWL examples
RUN python3 -m pip install --break-system-packages \
      torch \
      torchvision \
      "transformers>=4.40" \
      accelerate \
      pillow \
      scipy \
      tqdm \
      opencv-python-headless \
      onnx \
      onnxscript

# TensorRT + torch2trt for NanoOWL TRT flow
RUN python3 -m pip install --break-system-packages tensorrt
RUN python3 -m pip install --break-system-packages git+https://github.com/NVIDIA-AI-IOT/torch2trt.git

# Install NanoOWL package in editable mode
RUN python3 -m pip install --break-system-packages -e .

# Tree demo runtime deps
RUN python3 -m pip install --break-system-packages aiohttp matplotlib git+https://github.com/openai/CLIP.git

RUN mkdir -p /opt/nanoowl/docker/jetpack7-thor
COPY ./smoke_test.py /opt/nanoowl/docker/jetpack7-thor/smoke_test.py
COPY ./run_tree_demo_persistent.sh /opt/nanoowl/docker/jetpack7-thor/run_tree_demo_persistent.sh
RUN chmod +x /opt/nanoowl/docker/jetpack7-thor/run_tree_demo_persistent.sh

CMD ["python3", "docker/jetpack7-thor/smoke_test.py"]
