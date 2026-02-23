#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/deploy"

if [[ ! -f "$DEPLOY_DIR/.env" ]]; then
  echo "[ERROR] 找不到 $DEPLOY_DIR/.env"
  echo "[HINT] 先執行：./scripts/init-env.sh"
  exit 1
fi

cd "$DEPLOY_DIR"
docker compose --env-file .env pull
docker compose --env-file .env up -d
docker compose --env-file .env ps
