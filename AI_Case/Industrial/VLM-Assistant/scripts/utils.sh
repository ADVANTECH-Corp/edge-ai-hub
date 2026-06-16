#!/bin/bash

# ============================================================
# Shared Configuration
# ============================================================
# Get the absolute path to the directory containing this script
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

VLM_ASSISTANT_DIR="/opt/Advantech/EdgeAI/EdgeAIHub/edge-ai-hub/AI_Case/Industrial/VLM-Assistant"
MEDIA_GATEWAY_DIR="$VLM_ASSISTANT_DIR/media-gateway"
ENV_FILE="$VLM_ASSISTANT_DIR/config/vlm.env"

# Define key directories based on the expected GenAI installation structure
GENAI_DIR="/opt/Advantech/EdgeAI/System/Nvidia_Jetson/GenAI"
OLLAMA_DIR="$GENAI_DIR/app/engine/ollama"
OLLAMA_MODEL_DIR="$OLLAMA_DIR/ollama"

# Media-gateway script and runtime files
MEDIA_GATEWAY_SCRIPT="$MEDIA_GATEWAY_DIR/scripts/run.sh"
PID_FILE="$ROOT_DIR/media-gateway.pid"
LOG_FILE="$ROOT_DIR/media-gateway.log"

# Script paths
STOP_SCRIPT="$ROOT_DIR/stop.sh"

# Docker images
VLMA_ASSISTANT_IMAGE="advigw/vlm-assistant:1.0.0"
OLLAMA_IMAGE="ollama/ollama:0.23.0"

# Model names
OLLAMA_MODEL_NAME="gemma4:e4b-it-q4_K_M"

# Application URLs
URL="https://localhost:23954/"

# ============================================================
# Logging Helpers
# ============================================================
RED='\033[0;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_progress() {
  echo -e "${YELLOW}[${1}%] ${2}${NC}"
}

log_info()    { echo -e "${BLUE}[INFO] $1${NC}"; }
log_success() { echo -e "${GREEN}[OK]   $1${NC}"; }
log_error()   { echo -e "${RED}[ERROR] $1${NC}"; }
log_warn()    { echo -e "${YELLOW}[WARN] $1${NC}"; }
fail() {
  log_error "$1"
  exit 1
}