#!/usr/bin/env bash
# foxglove_bridge.sh — Start Foxglove bridge inside the fusion container.
# Run this AFTER start_all.sh has the fusion container running.
# Connect from browser at: https://app.foxglove.dev -> ws://<JETSON_IP>:8765

PORT="${1:-8765}"

echo "[INFO] Starting Foxglove bridge inside fusion container on port ${PORT}"
echo "[INFO] Connect at: ws://$(hostname -I | awk '{print $1}'):${PORT}"
echo "[INFO] Open https://app.foxglove.dev in your browser"
echo ""

docker exec -it ros2_camera_lidar_fusion /bin/bash -c "
    apt update -q &&
    apt install -y ros-humble-foxglove-bridge &&
    source /opt/ros/humble/setup.bash &&
    ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=${PORT}
"
