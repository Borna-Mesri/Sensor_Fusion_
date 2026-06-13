# CSE 145 Sensor Fusion

**Last Updated:** 04/23/2026  
**Project Report:** `<insert project report link>`

Unified workspace for the OAK-D Pro + Livox MID-360 sensor fusion pipeline running on the NVIDIA Jetson AGX Xavier (ucsd-agx-03). This document explains how to SSH into the Jetson, launch camera/LiDAR nodes, use Foxglove, and run sensor fusion.

> **Security Note:** This documentation may contain private IP addresses, usernames, and hardware-specific paths. Do not commit passwords, private IPs, or private access details to a public GitHub repository. Replace private values with placeholders such as `<JETSON_IP>` and `<JETSON_PASSWORD>` before publishing.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Finding the Jetson IP Address](#2-finding-the-jetson-ip-address)
3. [SSH Access](#3-ssh-access)
4. [USB Device Names](#4-usb-device-names)
5. [Launching Containers Individually](#5-launching-containers-individually)
6. [Sensor Fusion](#6-sensor-fusion)
7. [Foxglove Visualization](#7-foxglove-visualization)

---

## 1. System Overview

The car stack currently uses:

* **Jetson AGX Xavier** as the main onboard computer
* **OAK-D Pro Wide Camera** for image data
* **Livox MID-360 LiDAR** for point cloud data
* **ROS 2** for sensor topics and bridge workflows
* **Foxglove** for live visualization

Sensor fusion project folder:

```bash
/home/jetson/sensorfusion_ws
```

---

## 2. Finding the Jetson IP Address

### Current Known Jetson IP

```text
192.168.***.***
```

*This IP may change depending on the network or hotspot.*

### If You Are Physically on the Jetson

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
inet 192.168.***.***/24
```

---

## 3. SSH Access

From your personal computer:

```bash
ssh jetson@<JETSON_IP>
```

Example:

```bash
ssh jetson@192.168.***.***
```

If using X forwarding:

```bash
ssh -X jetson@<JETSON_IP>
```

If you do not need X forwarding, use:

```bash
ssh -x jetson@<JETSON_IP>
```

---

## 4. USB Device Names

List all connected USB serial devices:

```bash
ls /dev/ttyACM*
```

Expected devices may include:

```text
/dev/ttyACM0
/dev/ttyACM1
/dev/ttyACM2
/dev/ttyACM3
```

If devices are not detected, power cycle the cables by unplugging and replugging them. USB names can change if ports are swapped. If the car stops working after moving USB cables, check the detected devices again.

---

## 5. Launching Containers Individually

Use these commands when you only need one sensor or want to debug a specific container. 

### Camera Only

```bash
cd ~/sensorfusion_ws/camera
bash launch_camera_host.sh
```
*(Alternatively, use the shared script: `bash ~/sensorfusion_ws/shared/launch_camera.sh`)*

* **Publishes:** `/oak/rgb/image_raw` at 640x400 @ 30 FPS (USB 3) or ~6-7 Hz (USB 2).

### LiDAR Only

```bash
cd ~/sensorfusion_ws/lidar
bash launch_lidar_foxy_host.sh 99
```
*(Alternatively, use the shared script: `bash ~/sensorfusion_ws/shared/launch_lidar.sh 99`)*

* **Publishes:** `/livox/lidar` at 10 Hz.

### Fusion Container Only (Manual)

```bash
cd ~/sensorfusion_ws/fusion/docker
bash run.sh
```
*(Alternatively, use the shared script: `bash ~/sensorfusion_ws/shared/launch_fusion.sh`)*

* This drops you into the container interactively. 

---

## 6. Sensor Fusion

The sensor fusion project is located at:

```bash
~/sensorfusion_ws
```

The Docker directory is:

```bash
~/sensorfusion_ws/shared/docker
```

### 6.1 Start All Containers (Recommended)

To run the full pipeline, start all containers together:

```bash
bash ~/sensorfusion_ws/shared/start_all.sh 99
```

> **Note:** Replace `99` with the last two digits of your Livox MID-360 serial number if different.

You should see output indicating:
* Starts camera container -> waits for `/oak/rgb/image_raw`
* Starts LiDAR container -> waits for `/livox/lidar`
* Starts fusion container in background

### 6.2 Enter the Sensor Fusion Container Manually

```bash
docker exec -it ros2_camera_lidar_fusion /bin/bash
```

### 6.3 Check ROS Topics Inside the Container

Inside the container:

```bash
ros2 topic list
```

You should see:

```text
/livox/lidar
/oak/rgb/image_raw
```

Echo LiDAR (This will show the raw data stream of the LiDAR):

```bash
ros2 topic echo /livox/lidar
```

Echo camera (This will show the raw data stream of the OAK-D Camera):

```bash
ros2 topic echo /oak/rgb/image_raw
```

### 6.4 Build and Launch Sensor Fusion

Inside the container:

```bash
cd /ros2_ws
```

Build and source the workspace (once per container session):

```bash
bash start.sh
```

To see available launch options, run:

```bash
bash launch.sh
```

### 6.5 Manual Camera Calibration (Optional) 

Leave the camera with factory calibration (Recommended) or follow the steps below for manual calibration. Inside the sensor fusion container:

```bash
cd /ros2_ws
bash launch.sh 1
```

Use a 10 x 8 inch checkerboard and begin calibration. After calibration, values are saved on the Jetson under:

```bash
~/sensorfusion_ws/fusion/config
```

Important calibration files:

```text
camera_extrinsic_calibration.yaml
camera_intrinsic_calibration.yaml
```

### 6.6 Factory Calibration (Recommended)

The camera comes factory calibrated. If necessary to revert back to factory calibration, the values are stored in the camera. Make sure to edit the YAML file to match factory calibration values and run a factory reset script. Files are located in:

```bash
~/sensorfusion_ws/fusion/config
```

### 6.7 Synchronized Data

Extract synchronized data from both LiDAR and Camera:

```bash
cd /ros2_ws
bash launch.sh 2
```

LiDAR point cloud data and camera images at synchronized times will be saved in:

```bash
~/sensorfusion_ws/fusion/data
```

### 6.8 LiDAR Calibration (Match Points) 

Inside the sensor fusion container:

```bash
cd /ros2_ws
bash launch.sh 3
```

> *You will be prompted to match points for both the camera and LiDAR. Make sure to match points in the correct order.*

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

### 6.9 Compute LiDAR & Camera Calibration 

In order for the 3D point cloud to be projected on a 2D image, a matrix transformation needs to be done. The below command will run a Python script to perform this computation:

```bash
bash launch.sh 4
```

> **IMPORTANT: FOXGLOVE OR RVIZ VISUALIZATION MUST BE SETUP AND STARTED FIRST BEFORE THE FOLLOWING COMMANDS.**

### 6.10 Projection of LiDAR Point Cloud on Video Stream

Projects LiDAR point cloud onto the camera image:

```bash
bash launch.sh 5
```

### 6.11 Sensor Fusion w/ YOLO Detection

Runs LiDAR projection plus YOLOv8 object detection and HSV-based cone detection:

```bash
bash launch.sh 6
```

### 6.12 Sensor Fusion w/ YOLO Detection in 2-Meter Radius 

Extends detection with physical measurements and surface classification for objects within 2 meters:

```bash
bash launch.sh 7
```

---

## 7. Foxglove Visualization

Foxglove can be used instead of RViz for live ROS visualization.

**General workflow:**
1. Start the camera node.
2. Start the LiDAR node.
3. Start the sensor fusion Docker container if needed.
4. Start the Foxglove bridge.
5. Open Foxglove in a browser.
6. Connect to the Jetson WebSocket.

### 7.1 Launch Foxglove Bridge

Open a new terminal on the Jetson host:

```bash
source /opt/ros/galactic/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ros2 run foxglove_bridge foxglove_bridge --ros-args -p port:=8765
```

### 7.2 Connect Through Foxglove

Open a Chromium-based browser (Chrome, Edge, or Arc) on your personal computer and go to:

```text
[https://app.foxglove.dev](https://app.foxglove.dev)
```

Click **Open Connection** -> **Foxglove WebSocket**, and connect using:

```text
ws://<JETSON_IP>:8765
```

Example:

```text
ws://192.168.139.178:8765
```

Foxglove will show point cloud data and the video stream simultaneously. To view the sensor fusion output, change the Topic of the image panel to `/sensorfusion_out` or `/sensorfusion_out2`.

### 7.3 Full Camera, LiDAR, Sensor Fusion, and Foxglove Workflow 

*(Assuming all calibration is complete)*

**Terminal 1: Start All Containers**
```bash
bash ~/sensorfusion_ws/shared/start_all.sh 99
```

**Terminal 2: Foxglove Bridge (Jetson Host)**
```bash
source /opt/ros/galactic/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ros2 run foxglove_bridge foxglove_bridge --ros-args -p port:=8765
```

**Terminal 3: Sensor Fusion Docker**
```bash
docker exec -it ros2_camera_lidar_fusion /bin/bash
cd /ros2_ws
bash start.sh
```

Then run one of the following fusion modes:
```bash
bash launch.sh 5
# OR
bash launch.sh 6
# OR
bash launch.sh 7
```

Finally, open Foxglove in Chrome on your Mac/PC and connect to:
```text
ws://<JETSON_IP>:8765
```

## 8.EDIT: RViz Visualization (Recommended)

Rviz tends to havea higher FPS then Foxglove.
Run the following Commands in a new terminal.

```text
source /opt/ros/foxy/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
rviz2
```

Note: Do not have Rviz and Foxglove on at the same time

