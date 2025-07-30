#!/bin/bash
set -e

echo "Start install and setting..."

echo "Setup shekan DNS..."

# Set DNS shekan
sudo bash -c 'echo -e "nameserver 178.22.122.100\nnameserver 185.51.200.2" > /etc/resolv.conf'

echo "shekan DNS is set."

echo "Install Docker..."

# Remove last docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Install prerequisite
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

# Add GPG key of Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker resource and in apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install and update Docker Engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo docker --version

echo "Install Docker is done."

echo "Set mirror for docker..."

# Setting Mirror for Docker (example: https://registry.docker-cn.com)
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com", "https://docker.iranserver.com", "https://docker.haiocloud.com", "https://docker.arvancloud.ir"]
}
EOF


# Restart Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker

# Add current user in docker group
sudo usermod -aG docker $USER

echo "Set mirror for docker is done."

# Install Portainer
echo "Install Portainer..."

# Remove old container
sudo docker rm -f portainer || true

# Download and run Portainer(last version)
sudo docker volume create portainer_data

echo "Install Protainer is done."

echo "Running Protainer..."


sudo docker run -d -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest


echo "The Portainer is run."

# Install Git
echo "Install Git..."
sudo apt-get install -y git

# Install GitHub CLI (gh)
echo "Install GitHub CLI..."

# Add GitHub CLI resource
# type -p curl >/dev/null || sudo apt-get install curl -y
# curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
# sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
# sudo apt-get update -y
sudo apt-get install -y gh

echo "Installation and control were successful."

echo "To apply the docker group changes, log out and log back in or run the following command:"

echo "    newgrp docker"
