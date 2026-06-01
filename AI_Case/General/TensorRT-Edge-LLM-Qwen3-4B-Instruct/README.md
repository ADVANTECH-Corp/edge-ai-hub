# TensorRT Edge-LLM Qwen3-4B-Instruct

TensorRT Edge-LLM Qwen3-4B-Instruct provides on-device large language model inference for edge devices, enabling real-time text generation and instruction-following inference on NVIDIA Jetson Thor. It is suitable for rapid PoC and production deployment in industrial AI assistants, robotics control interfaces, edge chatbot services, and private on-premises GenAI scenarios.

Upstream project: [NVIDIA TensorRT Edge-LLM](https://github.com/NVIDIA/TensorRT-Edge-LLM)

- **Category**: General-purpose Edge LLM

![](assets/qwen3-edgellm-jetson-thor.png)

## NVIDIA TensorRT Edge-LLM

- **Qwen3-4B-Instruct LLM**
 Qwen3-4B-Instruct is used as the target text-only LLM for instruction-following, text generation, and edge-side chatbot inference.

- **TensorRT Edge-LLM Inference Pipeline**
 The Hugging Face model is downloaded on Jetson Thor, quantized to NVFP4, exported to ONNX, compiled into a TensorRT engine, and executed through the native C++ inference binary.

- **NVFP4 Runtime Optimization**
 NVFP4 quantization is used on Jetson Thor to reduce model weight footprint and improve edge deployment feasibility with TensorRT engine optimization.

## Supported Platform

| Platform | Hardware Spec | OS | Edge AI SDK |
|---|---|---|---|
| [AIR-075](https://docs.edge-ai-sdk.advantech.com/docs/Hardware/AI_System/Nvidia/Jetson%20Thor/AIR-075) | NVIDIA Jetson T5000 / T4000, up to 2070 TFLOPS FP4 AI inference performance, 128GB RAM | Ubuntu 24.04, JetPack 7.1 | [Install](https://docs.edge-ai-sdk.advantech.com/docs/Hardware/AI_System/Nvidia/Jetson%20Thor/AIR-075) |

---

# Setup

## Step 1: Download this project

```bash
mkdir -p /opt/Advantech/EdgeAI/EdgeAIHub
cd /opt/Advantech/EdgeAI/EdgeAIHub
git clone https://github.com/ADVANTECH-Corp/edge-ai-hub
cd edge-ai-hub/AI_Case/General/TensorRT-Edge-LLM-Qwen3-4B-Instruct
```

Expected: the project should be downloaded and the working directory should point to this AI Case.

## Step 2: Set up the export environment on Jetson Thor

```bash
docker pull nvcr.io/nvidia/pytorch:25.12-py3

docker run -it --runtime nvidia \
 --name edgellm-export \
 -v $(pwd):/workspace \
 -w /workspace \
 nvcr.io/nvidia/pytorch:25.12-py3 \
 bash
```

Expected: the NVIDIA PyTorch container should start on Jetson Thor with the current directory mounted to `/workspace`.

## Step 3: Install TensorRT Edge-LLM inside the container

```bash
git clone https://github.com/NVIDIA/TensorRT-Edge-LLM.git
cd TensorRT-Edge-LLM
git submodule update --init --recursive

python3 -m venv --system-site-packages venv
source venv/bin/activate

pip3 install --no-deps .
sed '/^torch/d' requirements.txt > /tmp/reqs.txt
pip3 install -r /tmp/reqs.txt

export WORKSPACE_DIR=/workspace/tensorrt-edgellm-workspace
```

Expected: TensorRT Edge-LLM export and quantization tools should be available inside the container.

## Step 4: Verify TensorRT Edge-LLM export tools

```bash
tensorrt-edgellm-export-llm --help
tensorrt-edgellm-quantize-llm --help
```

Expected: both commands should print usage information without errors.

## Step 5: Download, quantize, and export Qwen3-4B-Instruct to NVFP4 ONNX on Jetson Thor

```bash
export WORKSPACE_DIR=/workspace/tensorrt-edgellm-workspace
export MODEL_NAME=Qwen3-4B-Instruct

mkdir -p $WORKSPACE_DIR
cd $WORKSPACE_DIR

tensorrt-edgellm-quantize-llm \
 --model_dir Qwen/Qwen3-4B-Instruct-2507 \
 --output_dir $MODEL_NAME/quantized \
 --quantization nvfp4

tensorrt-edgellm-export-llm \
 --model_dir $MODEL_NAME/quantized \
 --output_dir $MODEL_NAME/onnx
```

Expected: the Qwen3-4B-Instruct model should be downloaded, quantized to NVFP4, and exported to ONNX under `$WORKSPACE_DIR/$MODEL_NAME/onnx`.

---

# Development and Deployment

## Setup 1: Build the C++ runtime on Jetson Thor

```bash
exit

sudo chown -R $(whoami):$(whoami) tensorrt-edgellm-workspace

sudo apt update
sudo apt install -y cmake build-essential git \
 cuda-toolkit-13-0 \
 libnvinfer-headers-dev libnvinfer-dev libnvonnxparsers-dev

export PATH=/usr/local/cuda/bin:$PATH
nvcc --version

cd ~
git clone https://github.com/NVIDIA/TensorRT-Edge-LLM.git
cd TensorRT-Edge-LLM
git submodule update --init --recursive

rm -rf build
mkdir build && cd build

cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DTRT_PACKAGE_DIR=/usr \
 -DCMAKE_TOOLCHAIN_FILE=cmake/aarch64_linux_toolchain.cmake \
 -DEMBEDDED_TARGET=jetson-thor

make -j$(nproc)
```

Expected: the TensorRT Edge-LLM C++ runtime should be built successfully for Jetson Thor.

## Setup 2: Configure runtime environment variables

```bash
cd ~/TensorRT-Edge-LLM

export EDGELLM_PLUGIN_PATH=$(pwd)/build/libNvInfer_edgellm_plugin.so
export WORKSPACE_DIR=$HOME/tensorrt-edgellm-workspace

./build/examples/llm/llm_build --help
./build/examples/llm/llm_inference --help
```

Expected: the TensorRT Edge-LLM build and inference binaries should be available.

## Setup 3: Build the Qwen3-4B-Instruct TensorRT engine with NVFP4 ONNX

```bash
cd ~/TensorRT-Edge-LLM

export MODEL_NAME=Qwen3-4B-Instruct
export WORKSPACE_DIR=$HOME/tensorrt-edgellm-workspace
export EDGELLM_PLUGIN_PATH=$(pwd)/build/libNvInfer_edgellm_plugin.so

./build/examples/llm/llm_build \
 --onnxDir $WORKSPACE_DIR/$MODEL_NAME/onnx \
 --engineDir $WORKSPACE_DIR/$MODEL_NAME/engine \
 --maxBatchSize 1 \
 --maxInputLen 1024 \
 --maxKVCacheCapacity 4096
```

Expected: the optimized TensorRT engine should be generated under `$WORKSPACE_DIR/$MODEL_NAME/engine`.

## Setup 4: Create an input prompt file

```bash
cat > $WORKSPACE_DIR/input_qwen.json << 'EOF_JSON'
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
```

Expected: the input prompt file should be created at `$WORKSPACE_DIR/input_qwen.json`.

## Setup 5: Run Qwen3-4B-Instruct inference on Jetson Thor

```bash
./build/examples/llm/llm_inference \
 --engineDir $WORKSPACE_DIR/$MODEL_NAME/engine \
 --inputFile $WORKSPACE_DIR/input_qwen.json \
 --outputFile $WORKSPACE_DIR/output_qwen.json \
 --dumpOutput
```

Expected: Qwen3-4B-Instruct should generate a text response using the TensorRT engine on Jetson Thor.

## Setup 6: Check output

```bash
cat $WORKSPACE_DIR/output_qwen.json
```

Expected: the output JSON should contain the generated response from Qwen3-4B-Instruct.

## Result

![](assets/qwen3-edgellm-result.png)
