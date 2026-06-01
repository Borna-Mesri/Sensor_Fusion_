#!/bin/bash
set -e

PACKAGE="ros2_camera_lidar_fusion"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <number>"
  echo ""
  echo "Available nodes:"
  echo "  1. get_intrinsic_camera_calibration.py  - Computes intrinsic camera calibration"
  echo "  2. save_sensor_data.py                  - Records synchronized camera and LiDAR data"
  echo "  3. extract_points.py                    - Manual selection of camera/LiDAR point pairs"
  echo "  4. get_extrinsic_camera_calibration.py  - Computes extrinsic camera/LiDAR calibration"
  echo "  5. lidar_camera_projection.py           - Projects LiDAR points onto camera image"
  echo "  6. lidar_camera_projection_detection.py - Projects Lidar points and includes detection"
  exit 1
fi

case "$1" in
  1) NODE="get_intrinsic_camera_calibration" ;;
  2) NODE="save_data" ;;
  3) NODE="extract_points" ;;
  4) NODE="get_extrinsic_camera_calibration" ;;
  5) NODE="lidar_camera_projection" ;;
  6) NODE="lidar_camera_projection_detection" ;;
  7) NODE="lidar_camera_projection_detection_v2" ;;
  *)
    echo "Error: invalid selection '$1'. Choose a number 1-5."
    exit 1
    ;;
esac

echo "Running: ros2 run $PACKAGE $NODE"
ros2 run "$PACKAGE" "$NODE"
