#!/usr/bin/env bash
# stop_all.sh — Stop all sensor fusion containers.
set -euo pipefail

echo "Stopping all sensor fusion containers..."

docker stop ros2_camera_lidar_fusion 2>/dev/null && \
    echo "  Stopped: ros2_camera_lidar_fusion" || \
    echo "  Not running: ros2_camera_lidar_fusion"

# Stop any lidar containers (named lidar_foxy_host_*)
for cname in $(docker ps --format '{{.Names}}' | grep '^lidar_foxy_host_' || true); do
    docker stop "$cname" && echo "  Stopped: $cname"
done

# Stop camera container (docker compose run --rm cleans itself up, but just in case)
for cname in $(docker ps --format '{{.Names}}' | grep 'camera' || true); do
    docker stop "$cname" && echo "  Stopped: $cname"
done

echo "Done."
