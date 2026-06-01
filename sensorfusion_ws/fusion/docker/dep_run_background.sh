 docker run -d \
    --name ros2_camera_lidar_fusion_background \
    --net host \
    --ipc host \
    --pid host \
    --privileged \
    --volume "$(pwd)/../:/ros2_ws/src/ros2_camera_lidar_fusion" \
    --volume "$HOME/david_lidar:/ros2_ws/david_lidar" \
    --volume "$HOME/dai_ws:/ros2_ws/dai_ws" \
    -w /ros2_ws \
    ros2_camera_lidar_fusion:latest \
    tail -f /dev/null
