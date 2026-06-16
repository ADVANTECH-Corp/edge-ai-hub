#!/bin/bash

# ============================================================
# Script Setup
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ============================================================
# Install Functions
# ============================================================
# Check network connectivity
check_network() {
  curl -s --head https://www.google.com | grep -q "200" || ping -c 1 8.8.8.8 &>/dev/null
}

# Pull Docker image if not exists
pull_image_if_needed() {
  local image="$1"
  if docker image inspect "$image" &>/dev/null; then
    log_success "$image already exists"
  else
    docker pull "$image" || fail "Failed to pull $image"
    log_success "$image pulled"
  fi
}

# Download Ollama model
download_ollama_model() {
  log_info "Downloading Ollama model"
  docker run -d --rm \
    --name ollama \
    -v $OLLAMA_MODEL_DIR:/root/.ollama \
    -e OLLAMA_MODELS=/root/.ollama \
    $OLLAMA_IMAGE
  sleep 10
  docker exec -ti ollama bash -c "ollama pull $OLLAMA_MODEL_NAME"
  docker stop ollama
}

# Install miniconda
setup_miniconda() {
    # ===== Configurable variables =====
    local CONDA_DIR="${CONDA_DIR:-$HOME/miniconda3}"

    # ===== Detect architecture =====
    local ARCH
    ARCH="$(uname -m)"

    local INSTALLER
    case "$ARCH" in
        x86_64)
            INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
            ;;
        aarch64)
            INSTALLER="Miniconda3-latest-Linux-aarch64.sh"
            ;;
        *)
            echo "[ERROR] Unsupported architecture: $ARCH"
            return 1
            ;;
    esac

    # ===== Install Miniconda if missing =====
    if [ ! -d "$CONDA_DIR" ]; then
        log_info "Installing Miniconda to $CONDA_DIR"
        wget -q "https://repo.anaconda.com/miniconda/$INSTALLER" -O /tmp/$INSTALLER
        bash /tmp/$INSTALLER -b -p "$CONDA_DIR"
        rm -f /tmp/$INSTALLER
    else
        log_info "Miniconda already exists at $CONDA_DIR"
    fi

    # ===== Load conda into current shell =====
    if [ -f "$CONDA_DIR/etc/profile.d/conda.sh" ]; then
        # shellcheck source=/dev/null
        source "$CONDA_DIR/etc/profile.d/conda.sh"
    else
        echo "[ERROR] conda.sh not found"
        return 1
    fi

    # ===== Avoid auto-activating base =====
    "$CONDA_DIR/bin/conda" config --set auto_activate_base false

    log_info "Conda is ready:"
    conda --version
}

# Install conda env
func_install_miniconda_env() {
    local MEDIA_GATEWAY_URL="https://github.com/WillQiuAd/media-gateway.git"
    local ENV_NAME="media-gateway"
    local PYTHON_VERSION="3.10"
    local INSTALL_DIR="$MEDIA_GATEWAY_DIR"
    local INSTALL_PACKAGE_PATH="$INSTALL_DIR/scripts/install.sh"

    # Git clone media-gateway if not exists
    if [ ! -d "$INSTALL_DIR" ]; then
        log_info "Cloning media-gateway repository to $INSTALL_DIR"
        git clone "$MEDIA_GATEWAY_URL" "$INSTALL_DIR" || {
            log_error "Failed to clone media-gateway repository"
            return 1
        }
    else
        log_info "media-gateway repository already exists at $INSTALL_DIR"
    fi

    # Ensure conda is available in current shell
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        log_error "Conda not found. Please install Miniconda first."
        return 1
    fi

    # --------------------------------------------------
    # IMPORTANT: Accept Conda Terms of Service (non-interactive safe)
    # --------------------------------------------------
    log_info "Ensuring conda Terms of Service are accepted"
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main >/dev/null 2>&1 || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r    >/dev/null 2>&1 || true

    # --------------------------------------------------
    # Create conda environment if it does not exist
    # (more robust than grep "^name ")
    # --------------------------------------------------
    if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
        log_info "Creating conda environment: $ENV_NAME"
        conda create -y -n "$ENV_NAME" python="$PYTHON_VERSION" || {
            log_error "Failed to create conda environment: $ENV_NAME"
            return 1
        }
    else
        log_info "Conda environment already exists: $ENV_NAME"
    fi

    # Activate environment
    conda activate "$ENV_NAME" || {
        log_error "Failed to activate conda environment: $ENV_NAME"
        return 1
    }

    # Run install script
    if [ -x "$INSTALL_PACKAGE_PATH" ]; then
        log_info "Running install script: $INSTALL_PACKAGE_PATH"
        "$INSTALL_PACKAGE_PATH"
    else
        log_error "Install script not found or not executable:"
        log_error "        $INSTALL_PACKAGE_PATH"
        return 1
    fi
}

# ============================================================
# Main Flow
# ============================================================
log_info "Starting vlm-assistant installation"

# Check internet connection
show_progress 20 "Checking network"
check_network || fail "No internet connection"
log_success "Network OK"

# Install package
show_progress 40 "Preparing system"
sudo apt update
sudo apt install -y curl wget git jq

# Pull Docker images
show_progress 50 "Pulling Docker images"
pull_image_if_needed "$VLM_ASSISTANT_IMAGE"
pull_image_if_needed "$OLLAMA_IMAGE"

# Download and install additional models
show_progress 60 "Downloading model: $OLLAMA_MODEL_NAME"
download_ollama_model
log_success "Model downloaded successfully."

# Check and install Miniconda
show_progress 80 "Installing miniconda"
setup_miniconda || fail "Failed to install miniconda."
log_success "miniconda installed"

# Install miniconda media-gateway
show_progress 90 "Installing miniconda: media-gateway"
func_install_miniconda_env || fail "Failed to set up conda environment and install media-gateway"
log_success "media-gateway installed"

# Finished
show_progress 100 "Installation completed"
log_success "All steps completed successfully!"