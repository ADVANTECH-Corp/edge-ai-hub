#!/bin/bash

# ============================================================
# Script Setup
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ============================================================
# Function to Stop Media-gateway
# ============================================================
stop_media_gateway() {
    if [[ ! -f "$PID_FILE" ]]; then
        echo "[stop] media-gateway is not running (pid file not found)"
        return 0
    fi

    PID=$(cat "$PID_FILE")

    if ! kill -0 "$PID" 2>/dev/null; then
        echo "[stop] process not running, cleaning pid file"
        rm -f "$PID_FILE"
        return 0
    fi

    echo "[stop] stopping media-gateway (PID=$PID)..."
    kill "$PID"

    for i in {1..10}; do
        if ! kill -0 "$PID" 2>/dev/null; then
            echo "[stop] stopped successfully"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
    done

    echo "[stop] force killing media-gateway (SIGKILL)"
    kill -9 "$PID" 2>/dev/null
    rm -f "$PID_FILE"
}

# ============================================================
# Service Shutdown
# ============================================================
DOCKER_COMPOSE_CMD=()
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker-compose)
else
    log_error "Neither docker-compose nor 'docker compose' is available!"
    exit 1
fi

# Start Docker Compose services.
"${DOCKER_COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down

# Stop media gateway
stop_media_gateway

log_success "All services stopped successfully."