#!/usr/bin/env bash
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/run_iq3kt.sh" "Qwen3VL-8B-Instruct-Q4_K_M.gguf"
