#!/bin/bash

# Create the directory for the GPG keyring with the necessary permissions
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download the GPG key and save it to the specified location
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null

# Ensure the GPG keyring file is readable by others
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

# Add the GitHub CLI software repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update the package index
sudo apt update

# Install the GitHub CLI
sudo apt install gh -y

# Note: The 'gh auth login' command requires interactive user input.
# You must run this command manually after the script execution to authenticate.
# For an automated setup, consider other authentication methods or prepare your environment accordingly.

echo "Remember to authenticate GitHub CLI by running 'gh auth login' and follow the prompts."

