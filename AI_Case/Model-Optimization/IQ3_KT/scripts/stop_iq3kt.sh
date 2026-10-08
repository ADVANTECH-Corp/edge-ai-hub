#!/usr/bin/env bash
set -euo pipefail

# IQ3_KT 與 Q4_K_M 共用此 API 容器；只停止目前模型，不刪容器或資料。
CONTAINER=$(sudo docker ps -aq --no-trunc --filter 'name=^/iq3kt-jp6-api$')
if [[ -n "$CONTAINER" ]]; then
  sudo docker stop "$CONTAINER"
else
  printf 'API 容器不存在，無需停止。\n'
fi
