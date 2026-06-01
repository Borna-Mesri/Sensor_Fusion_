#!/bin/bash
#apt-get update && apt-get install -y vim nano
colcon build
exec bash -c "source install/setup.bash && exec bash"
