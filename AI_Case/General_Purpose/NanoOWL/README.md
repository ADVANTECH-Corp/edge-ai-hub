# NanoOWL

NanoOWL provides prompt-driven vision inference for edge devices, enabling real-time object detection and tree-structured semantic inference (Tree Prediction). It is suitable for rapid PoC and production deployment in smart manufacturing, retail, public spaces, and industrial monitoring scenarios.

Upstream project: <https://github.com/NVIDIA-AI-IOT/nanoowl>

- **Category**: General-purpose Edge Vision AI

<p align="center">
  <img src="assets/jetson_person_2x.gif" width="70%" />
</p>

## OWL-ViT

- **OWL-ViT (Open-Vocabulary Detection)**  
  Uses natural language descriptions for target classes, enabling open-vocabulary object detection without retraining.
- **Tree Prompt Inference Pipeline**  
  Supports nested prompts so a single pipeline can perform object detection and fine-grained attribute/sub-object recognition.
- **TensorRT Optimization**  
  Uses TensorRT engine acceleration to improve inference efficiency while maintaining real-time performance and deployment feasibility.

## Supported Platform

| Platform | Hardware Spec | OS | Edge AI SDK |
|---|---|---|---|
| AIR-075 | NVIDIA Jetson Thor - RAM: 128/64 GB, Storage: 512 GB | JetPack 7.1 | [Install](https://docs.edge-ai-sdk.advantech.com/docs/Hardware/AI_System/Nvidia/Jetson%20Thor/AIR-075) |

---

# Setup

## Step 1: Download this project
```bash
mkdir /opt/Advantech/EdgeAI/EdgeAIHub
cd /opt/Advantech/EdgeAI/EdgeAIHub
git clone https://github.com/hsulin0806/NanoOWL
```

## Step 2: Check AI environment
```bash
/opt/Advantech/EdgeAI/System/System_Check/ai_stack_check.sh
```
Expected: pass.

## Step 3: Ensure a camera device is connected
```bash
ls -l /dev/video*
```
If no video device is found, leave the container and verify the video device is visible on the host.

---

# Development and Deployment

## Setup 1: Build Docker image
```bash
cd /opt/Advantech/EdgeAI/EdgeAIHub/NanoOWL/
docker build -t nanoowl:jp7-thor-persist -f ./Dockerfile .
```

## Setup 2: Launch the demo
```bash
docker compose up -d
```

## Setup 3: Open your browser
Open: `http://<device-ip>:7860`

## Result
<p align="center"> <img src="assets/nanoowl_chrome_window.png" width="70%" /> </p>
