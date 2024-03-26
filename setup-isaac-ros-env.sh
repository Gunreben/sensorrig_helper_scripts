#!/bin/bash

# This script sets up the ISAAC ROS development environment and clones necessary repositories.

# Create the workspace directory
mkdir -p /mnt/workspaces/isaac_ros-dev/src

# Add ISAAC_ROS_WS variable to .bashrc if not already present
if ! grep -q "export ISAAC_ROS_WS=/mnt/workspaces/isaac_ros-dev/" ~/.bashrc; then
  echo "export ISAAC_ROS_WS=/mnt/workspaces/isaac_ros-dev/" >> ~/.bashrc
  # Apply changes made to .bashrc
  source ~/.bashrc
else
  echo "ISAAC_ROS_WS already set in .bashrc"
fi

cd /mnt/workspaces/isaac_ros-dev/src || exit

# Clone necessary repositories if they don't already exist
REPOS=(
  "arkvision_six_cameras"
  "ouster-ros"
  "blickfeld_qb2_ros2_driver"
  "isaac_ros_common"
  "zed-ros2-wrapper"
)

URLS=(
  "https://github.com/Gunreben/arkvision_six_cameras.git"
  "https://github.com/Gunreben/ouster-ros.git"
  "https://github.com/Gunreben/blickfeld_qb2_ros2_driver.git"
  "https://github.com/Gunreben/isaac_ros_common.git"
  "https://github.com/stereolabs/zed-ros2-wrapper --recurse-submodules"
)

for i in "${!REPOS[@]}"; do
  if [ ! -d "${REPOS[$i]}" ]; then
    git clone ${URLS[$i]}
  else
    echo "${REPOS[$i]} already cloned."
  fi
done

# Setup and run necessary scripts
if [ -d "isaac_ros_common" ]; then
  cd isaac_ros_common || exit
  ./scripts/setup_zed_udev-rules.sh  # Necessary to access zed via USB
  sudo -u user ./scripts/run_dev.sh  # Builds, installs all dependencies, and runs the container
else
  echo "isaac_ros_common directory does not exist. Skipping setup scripts."
fi

