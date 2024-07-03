#!/bin/bash

### Set's up the whole environment to mnt the harddisk, correctly build Docker images on it
### allocates SWAP memory and adds user to docker group
### Following these tutorials:
### https://medium.com/@ramin.nabati/installing-an-nvme-ssd-drive-on-nvidia-jetson-xavier-37183c948978
### https://github.com/dusty-nv/jetson-containers/blob/master/docs/setup.md

# Reminder to format SSD
echo "Please ensure your SSD is formatted correctly before proceeding."
echo "You can find the UUID of your SSD using the 'Disks' application."
echo "Press Enter to continue..."
read

# Ask for the UUID
echo "Enter the UUID of your SSD:"
read uuid

# Ask for SWAP size
echo "Enter the size of SWAP space you want to allocate (e.g., 32 for 32GB):"
read swapsize

# Backup fstab
echo "Backing up /etc/fstab to /etc/fstab.bkup..."
sudo cp /etc/fstab /etc/fstab.bkup

# Update fstab
echo "Updating /etc/fstab with the SSD mount information..."
echo "UUID=$uuid  /mnt  ext4  defaults  0  2" | sudo tee -a /etc/fstab

# Mount /mnt
echo "Mounting /mnt..."
sudo mount /mnt

# Install necessary packages
echo "Updating package list and installing git, python3-pip..."
sudo apt-get update && sudo apt-get install -y git python3-pip

# Clone jetson-containers repo
cd /mnt/
echo "Cloning jetson-containers repository..."
git clone --depth=1 https://github.com/Gunreben/jetson-containers
cd jetson-containers || exit

# Install Python requirements
echo "Installing Python requirements..."
pip3 install -r requirements.txt

# Copy docker data directory
echo "Copying Docker data directory to /mnt/docker..."
sudo cp -r /var/lib/docker /mnt/docker

# Edit Docker daemon configuration
echo "Configuring Docker to use the new data root..."
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia",
    "data-root": "/mnt/docker"
}
EOF

# Restart Docker service
echo "Restarting Docker service..."
sudo systemctl restart docker

# Disable nvzramconfig
echo "Disabling nvzramconfig..."
sudo systemctl disable nvzramconfig

# Allocate SWAP file
echo "Allocating SWAP file of size $swapsize..."
sudo fallocate -l ${swapsize}G /mnt/${swapsize}GB.swap

# Format SWAP file
echo "Formatting SWAP file..."
sudo mkswap /mnt/${swapsize}GB.swap

# Enable SWAP file
echo "Enabling SWAP file..."
sudo swapon /mnt/${swapsize}GB.swap

# Update fstab with SWAP
echo "Updating /etc/fstab with SWAP information..."
echo "/mnt/${swapsize}GB.swap  none  swap  sw 0  0" | sudo tee -a /etc/fstab

# Add user to Docker group
echo "Adding $(whoami) to the Docker group..."
sudo usermod -aG docker $(whoami)

# Add your username here or dynamically retrieve it
USERNAME=$(whoami)

# Create a systemd service to set permissions at startup
echo "Creating a systemd service to ensure permissions are set correctly on boot..."
sudo tee /etc/systemd/system/set-permissions.service > /dev/null <<EOF
[Unit]
Description=Set permissions for /mnt/docker and other necessary directories

[Service]
Type=oneshot
ExecStart=/bin/chown -R $USERNAME:$USERNAME /mnt
ExecStart+=/bin/chmod -R 755 /mnt
# Add any other permission modifications you need
# ExecStart+=/bin/chmod -R 755 /another/directory

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
echo "Enabling and starting the set-permissions service..."
sudo systemctl daemon-reload
sudo systemctl enable set-permissions.service
sudo systemctl start set-permissions.service

echo "Setup complete. Please reboot/logout for all changes to take effect."

