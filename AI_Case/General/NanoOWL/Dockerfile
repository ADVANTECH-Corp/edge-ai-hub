# syntax=docker/dockerfile:1.6
# JetPack 7.x / L4T r38.x base image for Jetson Thor
# You can override BASE_IMAGE at build time if needed.
ARG BASE_IMAGE=nvcr.io/nvidia/cuda:13.0.0-runtime-ubuntu24.04
ARG NANOOWL_REF=fb553dee4c58f8c53ec2bf01f355a54648e67dbd
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

# Pull pinned NanoOWL source from upstream instead of local examples/nanoowl dirs
RUN git clone https://github.com/NVIDIA-AI-IOT/nanoowl.git /opt/nanoowl/upstream && \
    cd /opt/nanoowl/upstream && \
    git checkout ${NANOOWL_REF} && \
    cp -r /opt/nanoowl/upstream/examples /opt/nanoowl/examples && \
    cp -r /opt/nanoowl/upstream/nanoowl /opt/nanoowl/nanoowl

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

# Install NanoOWL package from upstream source
RUN python3 -m pip install --break-system-packages -e /opt/nanoowl/upstream

# Tree demo runtime deps
RUN python3 -m pip install --break-system-packages aiohttp matplotlib git+https://github.com/openai/CLIP.git

RUN mkdir -p /opt/nanoowl/docker/jetpack7-thor
COPY ./run_tree_demo_persistent.sh /opt/nanoowl/docker/jetpack7-thor/run_tree_demo_persistent.sh
RUN chmod +x /opt/nanoowl/docker/jetpack7-thor/run_tree_demo_persistent.sh

CMD ["python3", "docker/jetpack7-thor/smoke_test.py"]
