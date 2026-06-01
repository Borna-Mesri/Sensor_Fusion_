#!/bin/bash
set -e

# Change MID360 sensor IP address if provided
if [[ $1 =~ ^[0-9]+$ ]]; then
    sensor_ip="192.168.1.1$1"
    host_ip="${LIVOX_HOST_IP:-}"
    if [[ -z "$host_ip" ]]; then
        host_ip="$(ip route get "$sensor_ip" 2> /dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "src") { print $(i+1); exit }}')"
    fi
    if [[ -z "$host_ip" ]]; then
        host_ip="192.168.1.50"
    fi

    config_files=(
        /home/devuser/livox_ws/install/livox_ros_driver2/share/livox_ros_driver2/config/MID360_config.json
        /home/devuser/livox_ws/src/livox_ros_driver2/config/MID360_config.json
    )

    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            sed -i -E "s/(\"ip\"[[:space:]]*:[[:space:]]*\")192\\.168\\.1\\.[0-9]+(\")/\1$sensor_ip\2/" "$config_file"

            if [[ -n "$host_ip" ]]; then
                sed -i -E "s/(\"cmd_data_ip\"[[:space:]]*:[[:space:]]*\")([0-9]{1,3}\\.){3}[0-9]{1,3}(\")/\1$host_ip\3/" "$config_file"
                sed -i -E "s/(\"push_msg_ip\"[[:space:]]*:[[:space:]]*\")([0-9]{1,3}\\.){3}[0-9]{1,3}(\")/\1$host_ip\3/" "$config_file"
                sed -i -E "s/(\"point_data_ip\"[[:space:]]*:[[:space:]]*\")([0-9]{1,3}\\.){3}[0-9]{1,3}(\")/\1$host_ip\3/" "$config_file"
                sed -i -E "s/(\"imu_data_ip\"[[:space:]]*:[[:space:]]*\")([0-9]{1,3}\\.){3}[0-9]{1,3}(\")/\1$host_ip\3/" "$config_file"
            fi
        fi
    done
    shift
fi

# Source the necessary ROS2 and workspaces
source /opt/ros/humble/setup.bash
source /home/devuser/livox_ws/install/setup.bash
# This will fail in the base livox container since it doesn't use that workspace. Hence I send the error to /dev/null.
source /home/devuser/ros2_ws/install/setup.bash 2> /dev/null || true
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
# Run the provided command
"$@"
