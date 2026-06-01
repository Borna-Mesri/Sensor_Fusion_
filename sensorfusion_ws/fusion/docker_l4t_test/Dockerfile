FROM dustynv/ros:humble-ros-base-l4t-r35.4.1

LABEL maintainer="Clemente Donoso <clemente.donosok@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

###### Install python packages
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    apt-get update && apt-get install -y \
    python3-pip \
    python3 \
    libopenblas-dev \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Remove conflicting cv2 installations from base image
RUN rm -rf /usr/local/lib/python3.8/dist-packages/cv2 \
           /usr/lib/python3.8/dist-packages/cv2 \
           /usr/lib/python3/dist-packages/cv2 2>/dev/null || true
RUN pip install opencv-contrib-python-headless==4.5.5.64
RUN pip install --upgrade numpy==1.24.3
RUN pip install matplotlib==3.6.0
RUN pip install \
    pandas \
    open3d
RUN pip install depthai==2.29.0
RUN pip install ultralytics --no-deps
RUN pip install --ignore-installed sympy mpmath

###### Install NVIDIA L4T r35.4 torch wheel (CUDA 11.4, JetPack 5.1.2)
RUN wget https://developer.download.nvidia.com/compute/redist/jp/v512/pytorch/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl \
    -O torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl && \
    pip install torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl && \
    rm torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl

COPY torchvision /usr/local/lib/python3.8/dist-packages/torchvision
COPY torchvision-0.16.0+fbb4cc5.dist-info /usr/local/lib/python3.8/dist-packages/torchvision-0.16.0+fbb4cc5.dist-info
RUN pip install cupy-cuda11x

###### Install package dependencies
RUN apt-get update && apt-get install -y \
    git \
    libpcl-dev \
    terminator

###### Install ros dependencies from source
RUN apt-get update && apt-get install -y \
    ros-dev-tools \
    libpcl-dev \
    libwebsocketpp-dev \
    libboost-all-dev \
    libssl-dev

RUN pip install catkin-pkg

RUN mkdir -p /opt/ros_extra/src && \
    cd /opt/ros_extra/src && \
    git clone https://github.com/ros-perception/perception_pcl.git -b humble && \
    git clone https://github.com/ros-perception/pcl_msgs.git -b ros2 && \
    cd /opt/ros_extra && \
    . /opt/ros/humble/install/setup.sh && \
    colcon build --symlink-install && \
    echo "source /opt/ros_extra/install/setup.bash" >> ~/.bashrc

RUN apt-get install -y nano vim

RUN apt-get update && apt-get install -y \
    x11-apps \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

###### Build CycloneDDS from source for ROS2 Humble compatibility
RUN mkdir -p /opt/cyclone_ws/src && \
    cd /opt/cyclone_ws/src && \
    git clone https://github.com/eclipse-cyclonedds/cyclonedds.git --branch 0.9.0 && \
    git clone https://github.com/ros2/rmw_cyclonedds.git --branch humble && \
    cd /opt/cyclone_ws && \
    . /opt/ros/humble/install/setup.sh && \
    colcon build --symlink-install --cmake-args -DBUILD_TESTING=OFF -DENABLE_SHM=OFF -DBUILD_DDSPERF=OFF && \
    echo "source /opt/cyclone_ws/install/setup.bash" >> ~/.bashrc

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

###### Build the workspace
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/install/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/install/setup.bash && source /opt/cyclone_ws/install/setup.bash && colcon build"

###### Source the workspace
RUN echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc
