#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${APP_ARCHIVE_URL:-}" ]]; then
  echo "错误：未设置 APP_ARCHIVE_URL 环境变量。" >&2
  exit 1
fi

APP_DIR="/opt/app"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

ARCHIVE_FILE="app_archive"

# 下载归档文件，不输出 URL 防止泄露
if ! curl -fsSL "$APP_ARCHIVE_URL" -o "$ARCHIVE_FILE"; then
  echo "错误：无法下载应用归档文件。" >&2
  exit 1
fi

# 根据文件类型解压 zip 或 tar.gz
if file "$ARCHIVE_FILE" | grep -qi "zip"; then
  unzip -q "$ARCHIVE_FILE" -d "$APP_DIR"
elif file "$ARCHIVE_FILE" | grep -Eqi "gzip compressed data|tar archive"; then
  tar -xzf "$ARCHIVE_FILE" -C "$APP_DIR"
else
  echo "错误：不支持的归档格式。" >&2
  exit 1
fi

# 选择解压后的第一个目录作为应用目录
APP_SUBDIR=$(find "$APP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [[ -z "$APP_SUBDIR" ]]; then
  echo "错误：未找到解压后的应用目录。" >&2
  exit 1
fi

cd "$APP_SUBDIR"

exec uvicorn app:app --host 0.0.0.0 --port 7860
