#!/bin/bash

# ============================================================
# Script Setup
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ============================================================
# Service Startup
# ============================================================
# Start the Media-gateway
if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    log_error "[start] media-gateway already running"
    return 0
fi
# Starting media-gateway...
"${MEDIA_GATEWAY_SCRIPT}" --env conda --mode prod > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

# Check docker compose cli
DOCKER_COMPOSE_CMD=()
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD=(docker-compose)
else
    log_error "Neither docker-compose nor 'docker compose' is available!" >&2
    exit 1
fi

# Start Docker Compose services.
"${DOCKER_COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d > /dev/null 2>&1

# Loading model 
if [ "$(docker inspect -f '{{.State.Running}}' "$OLLAMA_CONTAINER_NAME" 2>/dev/null)" = "true" ]; then
    docker exec -i "$OLLAMA_CONTAINER_NAME" \
        ollama run "$OLLAMA_MODEL_NAME" <<< "hello" \
        >/dev/null 2>&1
fi