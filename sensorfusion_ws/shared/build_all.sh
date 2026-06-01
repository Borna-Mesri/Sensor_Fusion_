#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== [1/2] Building camera + lidar images ==="
cd "$ROOT/camera"
docker compose -f docker-compose.yml -f docker-compose.arm64.yml build
echo "[OK] ece191/camera:humble and ece191/lidar:humble built."

echo ""
echo "=== [2/2] Building fusion image ==="
cd "$ROOT/fusion/docker"
bash build.sh
echo "[OK] ros2_camera_lidar_fusion:latest built."

echo ""
echo "============================================================"
echo "  All images built. You can now run:"
echo "  bash ~/sensorfusion_ws/shared/start_all.sh 99"
echo "============================================================"
