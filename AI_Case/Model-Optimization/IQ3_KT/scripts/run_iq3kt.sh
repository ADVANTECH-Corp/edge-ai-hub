#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="/home/ubuntu/Downloads/iq3kt/models"
MODEL="${1:-Qwen3VL-8B-Instruct-IQ3_KT.gguf}"
MODEL_NAME="${MODEL%.gguf}"
IMAGE="advigw/iq3kt-llama-server:jp6_b8779"
CONTAINER="iq3kt-jp6-api"

if (( $# > 1 )) || [[ ! "$MODEL" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.gguf$ ]]; then
  printf '請指定 models 資料夾內的 GGUF 檔名。\n' >&2
  exit 1
fi
if [[ ! -s "$MODEL_DIR/$MODEL" || ! -r "$MODEL_DIR/$MODEL" ]]; then
  printf '模型不存在、為空或不可讀：%s\n' "$MODEL_DIR/$MODEL" >&2
  exit 1
fi

# 先確認環境與本機 image，失敗時保留目前的容器。
RUNTIME=$(sudo docker info --format '{{if index .Runtimes "nvidia"}}nvidia{{end}}')
if [[ "$RUNTIME" != nvidia ]]; then
  printf 'Docker 未設定 NVIDIA Runtime。\n' >&2
  exit 1
fi
sudo docker image inspect "$IMAGE" >/dev/null

# 只停止、移除本專案的同名 API 容器，不碰 WebUI 或其他容器。
OLD_CONTAINER=$(sudo docker ps -aq --no-trunc --filter "name=^/${CONTAINER}$")
if [[ -n "$OLD_CONTAINER" ]]; then
  sudo docker stop "$OLD_CONTAINER"
  sudo docker rm "$OLD_CONTAINER"
fi
LISTENERS=$(ss -H -ltn 'sport = :18081')
if [[ -n "$LISTENERS" ]]; then
  printf 'Port 18081 仍被其他服務占用；未啟動模型，請先確認來源。\n' >&2
  exit 1
fi

sudo docker run -d --pull=never --name "$CONTAINER" \
  --runtime=nvidia --network host \
  --mount "type=bind,src=$MODEL_DIR,dst=/models,readonly" \
  "$IMAGE" \
  -m "/models/$MODEL" --alias "$MODEL_NAME" \
  --host 127.0.0.1 --port 18081 \
  -c 4096 -b 1024 -ub 512 -ngl 99 \
  -ctk q4_0 -ctv q4_0 -fa on --parallel 1

printf '模型：%s\nAPI：http://127.0.0.1:18081/v1\nCtrl+C 只離開 logs，容器繼續執行。\n' "$MODEL_NAME"
sudo docker logs -f "$CONTAINER"
