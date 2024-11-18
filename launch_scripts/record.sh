#!/bin/bash

docker_cmd="docker run -it --rm \
    --privileged \
    --network host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/user/.Xauthority:/home/admin/.Xauthority:rw \
    -e DISPLAY \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -e FASTRTPS_DEFAULT_PROFILES_FILE=/usr/local/share/middleware_profiles/rtps_udp_profile.xml \
    -e ROS_DOMAIN_ID \
    -e USER \
    -v /usr/bin/tegrastats:/usr/bin/tegrastats \
    -v /tmp/argus_socket:/tmp/argus_socket \
    -v /usr/local/cuda-11.4/targets/aarch64-linux/lib:/usr/local/cuda-11.4/targets/aarch64-linux/lib \
    -v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra \
    -v /usr/src/jetson_multimedia_api:/usr/src/jetson_multimedia_api \
    -v /opt/nvidia/nsight-systems-cli:/opt/nvidia/nsight-systems-cli \
    --pid=host \
    -v /opt/nvidia/vpi2:/opt/nvidia/vpi2 \
    -v /usr/share/vpi2:/usr/share/vpi2 \
    -v /mnt/workspaces/isaac_ros-dev/:/workspaces/isaac_ros-dev \
    -v /dev/*:/dev/* \
    -v /etc/localtime:/etc/localtime:ro \
    -v /mnt/data:/data \
    --name isaac_ros_dev-aarch64-container \
    --runtime nvidia \
    --user=admin \
    --entrypoint /usr/local/bin/scripts/record_entrypoint.sh \
    --workdir /workspaces/isaac_ros-dev \
    isaac_ros_dev-aarch64 \
    /bin/bash"
    
echo "Executing command: $docker_cmd"

eval "$docker_cmd"

