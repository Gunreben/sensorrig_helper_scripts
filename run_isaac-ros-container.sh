#!/bin/bash

docker_cmd="cd /mnt/workspaces/isaac_ros-dev/src/isaac_ros_common/scripts && ./run_dev.sh /mnt/workspaces/isaac_ros-dev/"
    
echo "Executing command: $docker_cmd"

eval "$docker_cmd"

