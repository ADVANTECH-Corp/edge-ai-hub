#!/bin/bash

# ============================================================
# Script Setup
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ============================================================
# Install Functions
# ============================================================

# Download Ollama model
download_ollama_model() {
  local model_name="$1"
  log_info "Downloading Ollama model: $model_name"
  docker run -d --rm \
    --name ollama \
    -v $OLLAMA_MODEL_DIR:/root/.ollama \
    -e OLLAMA_MODELS=/root/.ollama \
    $OLLAMA_IMAGE
  sleep 10
  docker exec -ti ollama bash -c "ollama pull $model_name"
  docker stop ollama
}

# ============================================================
# Main Flow
# ============================================================

MODEL_NAME="${1:-$OLLAMA_MODEL_NAME}"
download_ollama_model "$MODEL_NAME"