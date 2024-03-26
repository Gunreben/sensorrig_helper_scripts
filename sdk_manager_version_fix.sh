 #!/bin/bash

### Since NVIDIA SDKMANAGER for jetson doesn't allow you to install Jetpack <= 5.x on Ubuntu 22.04
### this script automates the switching of OS versions 
### (more see: https://forums.developer.nvidia.com/t/how-to-install-jetpack-5-1-2-using-sdk-manager-2-0-and-host-computer-running-ubuntu-22-04/280502)

# Function to check and create backup file if it doesn't exist
create_backup_if_missing() {
    local backup_file="$1"
    local os_version="$2"

    if [ ! -f "$backup_file" ]; then
        echo "Creating backup file for $os_version..."
        case $os_version in
            20.04)
                cat > "$backup_file" <<EOF
NAME="Ubuntu"
VERSION="20.04.6 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.6 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
EOF
                ;;
            22.04)
                cat > "$backup_file" <<EOF
PRETTY_NAME="Ubuntu 22.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
EOF
                ;;
            *)
                echo "Unsupported OS version. Exiting."
                exit 1
                ;;
        esac
        echo "$os_version backup file created: $backup_file"
    else
        echo "$os_version backup file already exists: $backup_file"
    fi
}

# Function to restore a given backup file
restore_backup() {
    local backup_file="$1"
    if [ -f "$backup_file" ]; then
        sudo cp "$backup_file" /etc/os-release
        echo "Restored OS release from $backup_file"
    else
        echo "Backup file $backup_file not found!"
    fi
}

# Create backups if they don't exist
create_backup_if_missing "/etc/os-release.20.04.back" "20.04"
create_backup_if_missing "/etc/os-release.22.04.back" "22.04"

echo "Select the OS release to restore:"
echo "1) Ubuntu 20.04"
echo "2) Ubuntu 22.04"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        restore_backup "/etc/os-release.20.04.back"
        ;;
    2)
        restore_backup "/etc/os-release.22.04.back"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

