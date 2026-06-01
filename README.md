
# CSE 145 Sensor Fusion

Unified workspace for the OAK-D Pro + Livox MID-360 sensor fusion pipeline
running on the NVIDIA Jetson AGX Xavier (ucsd-agx-03).

## Directory layout
# CSE 145 Sensor_Fusion

**Last Updated:** 04/23/2026  
**Project Report:** `<insert project report link>`

This document explains how to  SSH into the Jetson,launch camera/LiDAR nodes, use Foxglove, run sensor fusion.

> **Security Note:** This documentation may contain private IP addresses, usernames, and hardware-specific paths. Do not commit passwords, private IPs, or private access details to a public GitHub repository. Replace private values with placeholders such as `<JETSON_IP>` and `<JETSON_PASSWORD>` before publishing.

---

# Table of Contents

1. [System Overview](#1-system-overview)
2. [Finding the Jetson IP Address](#4-finding-the-jetson-ip-address)
3. [SSH Access](#5-ssh-access)
4. [USB Device Names](#8-usb-device-names)
5. [Editing Files on the Jetson](#9-editing-files-on-the-jetson)
6. [ROS 2 Basic Commands](#17-ros-2-basic-commands)
7. [Docker Basic Commands](#18-docker-basic-commands)
8. [Camera and LiDAR ROS 2 Nodes](#19-camera-and-lidar-ros-2-nodes)
19. [Sensor Fusion](#20-sensor-fusion)
20. [Foxglove Visualization](#21-foxglove-visualization)

---

# 1. System Overview

The car stack currently uses:

- **Jetson AGX Xavior** as the main onboard computer
- **OAK D Pro Wide Camera** for image data
- **Livox LiDAR** for point cloud data
- **ROS 2** for sensor topics and bridge workflows
- **Foxglove** for live visualization


Sensor fusion project folder:

```bash
/home/jetson/sensorfusion_ws
```

# 2. Finding the Jetson IP Address

## Current Known Jetson IP

```bash
192.168.139.178
```

This IP may change depending on the network or hotspot.

## If You Are Physically on the Jetson

Run:

```bash
myip
```

Or run:

```bash
ip addr show wlan0
```

Look for the `inet` field. The IP address is the first number string after `inet`.

Example:

```text
inet 192.168.139.178/24
```
---

# 3. SSH Access

From your personal computer:

```bash
ssh jetson@<JETSON_IP>
```

Example:

```bash
ssh jetson@192.168.139.178
```

If using X forwarding:

```bash
ssh -X jetson@<JETSON_IP>
```

Example:

```bash
ssh -X jetson@192.168.139.178
```

If you do not need X forwarding, use:

```bash
ssh -x jetson@<JETSON_IP>
```

Example:

```bash
ssh -x jetson@192.168.139.178
```

---

# 4. USB Device Names

List all connected USB serial devices:

```bash
ls /dev/ttyACM*
```

Expected devices may include:

```bash
/dev/ttyACM0
/dev/ttyACM1
/dev/ttyACM2
/dev/ttyACM3
```

If devices are not detected, power cycle the cables by unplugging and replugging them.

USB names can change if ports are swapped. If the car stops working after moving USB cables, check the detected devices again:

```bash
ls /dev/ttyACM*
```

# 5. Editing Files on the Jetson

Use `nano` for simple terminal editing:

```bash
nano <filename>
```

# 6. ROS 2 Basic Commands

List all visible ROS 2 topics:

```bash
ros2 topic list
```

Echo a topic:

```bash
ros2 topic echo <topic_name>
```

Examples:

```bash
ros2 topic echo /oak/rgb/image_raw
```

```bash
ros2 topic echo /livox/lidar
```

If nothing appears, then the topic is not publishing or the current shell/container cannot see it.

---

# 7. Docker Basic Commands

See running containers:

```bash
docker ps
```

See available Docker images:

```bash
docker images
```

Stop a container:

```bash
docker stop <container_name>
```

Enter a running container:

```bash
docker exec -it <container_name> /bin/bash
```

Example:

```bash
docker exec -it ros2_camera_lidar_fusion /bin/bash
```

---

# 9. Sensor Fusion

The sensor fusion project is located at:

```bash
~/sensorfusion_ws
```

The Docker directory is:

```bash
~/sensorfusion_ws/shared/docker
```

---
## 9.10 Start all containers


```bash
bash ~/sensorfusion_ws/shared/start_all.sh 99
```
------
Note: Replace 99 with the last two digits of your Livox MID-360 serial number if different.

You should see:

```text
• === 1/3 — Camera === waits for /oak/rgb/image_raw
• === 2/3 — LiDAR === waits for /livox/lidar
• === 3/3 — Fusion === starts fusion container in background
```

## 9.20 Enter the Sensor Fusion Container Manually

```bash
docker exec -it ros2_camera_lidar_fusion /bin/bash
```

---



## 9.3 Check ROS Topics Inside the Container

Inside the container:

```bash
ros2 topic list
```

You should see:

```text
/livox/lidar
/oak/rgb/image_raw
```

Echo LiDAR:

```bash
ros2 topic echo /livox/lidar
```


```bash
This will show raw data stream of Lidar
```


Echo camera:

```bash
ros2 topic echo /oak/rgb/image_raw
```


```bash
This will show raw data stream of Oak D Camera

```
---

## 9.4 Build and Launch Sensor Fusion

Inside the container:

```bash
bash cd /ros2_ws
```

Show available launch options:

```bash
bash launch.sh
```

Build and source the workspace:

```bash
start.sh
```
---

## 9.5 Manual Camera Calibration(Optional) 

Leave Camera with factory calibration (Recommended) or follow the below steps for manual calibration.

Inside the sensor fusion container:

```bash
cd /ros2_ws
bash launch.sh 1
```

////////////Use a 10 x 8 inch checker board and begin calibraiton.

After calibration, values are saved on the Jetson under:

```cd
~/sensorfusion_ws/fusion/config
```

Important calibration files:

```text
camera_extrinsic_calibration.yaml
camera_intrinsic_calibration.yaml
```
---

## 9.6 Factory Calibratinon(Recommended):

Camera comes Factory calibrated. 

If neccessry to revert back to factory calibration, factory calibration values are stored in the Camera.

Make to edit yaml file to match factory calibration values and run a factory reset script.

File located in 

```text
~/sensorfusion_ws/fusion/config
```
---

## 9.7 Synchronized data

Extract synchronized data from both Lidar and Camera 

```bash
cd /ros2_ws
bash launch.sh 2
```

Lidar point cloud data and Camera image at synchronized time will be saved in 

```cd
sensorfusin_ws/fusion/data
```
------


## 9.8 LiDAR Calibration (Match points) 

Inside the sensor fusion container:

```bash
cd /ros2_ws
bash launch.sh 3

*You will be prompted to match points for both Camera and Lidar
*Make sure to match points in correct order.
```


After LiDAR calibration, check that the fused output topic exists:

```bash
ros2 topic list
```

You should see:

```text
/sensorfusion_out
```

Echo the fused output:

```bash
ros2 topic echo /sensorfusion_out
```

---

## 9.9 Compute Lidar & Camera Calibration 

In order for the 3d point cloud to be projected on a 2d image a matrix transformation needs to be done. The below command will run a python script to perform this computation.

```bash
bash launch.sh 4
```


# FOX GLOVE VISULATION MUST BE SETUP FIRST AND STARTED FOR THE FOLLOWING COMMANDS


## 10.0 Projection of Lidar Point Cloud on Video Stream (Sensor Fusion)


```bash
bash launch.sh 5
```

## 10.1 Sensor Fusion w/ Yolo detection

```bash
bash launch.sh 6
```

## 10.2 Sensor Fusion w/ Yolo detection in 2 meter radius 

# 11. Foxglove Visualization

Foxglove is used instead of RViz for live ROS visualization.

General workflow:

1. Start the camera node.
2. Start the LiDAR node.
3. Start the sensor fusion Docker container if needed.
4. Start the Foxglove bridge.
5. Open Foxglove in a browser.
6. Connect to the Jetson WebSocket.

---

## 11.1 Launch Foxglove Bridge

Open a new termianl:

```bash
  source /opt/ros/galactic/setup.bash
```

```bash
  export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
```

```bash

ros2 run foxglove_bridge foxglove_bridge --ros-args -p port:=8765

```
## 11.3 Connect Through Foxglove

Open a Chromium-based browser and go to:

```text
https://app.foxglove.dev
```

Open a Connection using:

```text
ws://<JETSON_IP>:8765
```

Example:

```text
ws://192.168.139.178:8765
```

Foxglove will show point cloud data and video stream simulatenously.

To view sensor fusion change Topic od image panel to Sensor_out.


---

## 11.6 Full Camera, LiDAR, Sensor Fusion, and Foxglove Workflow (After all calibraiton is done)

### Terminal 1: Camera.Lidar, docker

```bash
bash ~/sensorfusion_ws/shared/start_all.sh 99
```

### Terminal 3: Sensor Fusion Docker & Foxglove

```bash
docker exec -it <container_name> /bin/bash
```

```bash
ros2 launch foxglove_bridge foxglove_bridge_launch.xml
```

Then run one of the followingcommands:

```bash
bash launch.sh 5
bash launch.sh 6
bash launch.sh 7
```

Then open Foxglove w/Chrome and connect to:

```text
ws://<JETSON_IP>:8765
```
---

>>>>>>> d3696a25c68125002223678754ad4a97a7df4113
