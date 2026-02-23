#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/deploy"
ENV_FILE="$DEPLOY_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  echo "[INFO] $ENV_FILE 已存在，不覆蓋。"
  echo "[INFO] 若要重建，先手動刪除後再執行本腳本。"
  exit 0
fi

if [[ ! -f "$DEPLOY_DIR/.env.example" ]]; then
  echo "[ERROR] 找不到 $DEPLOY_DIR/.env.example"
  exit 1
fi

cp "$DEPLOY_DIR/.env.example" "$ENV_FILE"

DB_PASSWORD="$(openssl rand -base64 32 | tr -d '\n')"
SESSION_SECRET="$(openssl rand -hex 32 | tr -d '\n')"

sed -i "s|DB_PASSWORD=replace-with-strong-password|DB_PASSWORD=${DB_PASSWORD}|" "$ENV_FILE"
sed -i "s|SESSION_SECRET=replace-with-64-hex-secret|SESSION_SECRET=${SESSION_SECRET}|" "$ENV_FILE"

echo "[OK] 已建立 $ENV_FILE"
echo "[NEXT] 請手動編輯 DOMAIN 與 EMAIL："
echo "       nano $ENV_FILE"
