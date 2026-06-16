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

# Loading model — wait for ollama healthcheck to pass before pulling it into memory
OLLAMA_WAIT_TIMEOUT=120
OLLAMA_WAIT_ELAPSED=0
while [ "$OLLAMA_WAIT_ELAPSED" -lt "$OLLAMA_WAIT_TIMEOUT" ]; do
    STATUS="$(docker inspect -f '{{.State.Health.Status}}' "$OLLAMA_CONTAINER_NAME" 2>/dev/null)"
    [ "$STATUS" = "healthy" ] && break
    sleep 5
    OLLAMA_WAIT_ELAPSED=$((OLLAMA_WAIT_ELAPSED + 5))
done

if [ "$(docker inspect -f '{{.State.Health.Status}}' "$OLLAMA_CONTAINER_NAME" 2>/dev/null)" = "healthy" ]; then
    docker exec -i "$OLLAMA_CONTAINER_NAME" \
        ollama run "$OLLAMA_MODEL_NAME" <<< "hello" \
        >/dev/null 2>&1
else
    log_warn "ollama container did not become healthy within ${OLLAMA_WAIT_TIMEOUT}s, skipping model load"
fi