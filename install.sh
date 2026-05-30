#!/usr/bin/env bash

set -xe

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y \
    ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo groupadd docker || echo Docker group exists
sudo usermod -aG docker $USER || echo "User '$USER' already part of Docker group"

sudo tee /etc/systemd/system/compose.service <<EOF
[Unit]
Description=Docker services
After=network-online.target

[Service]
Type=simple
User=${USER}
Group=docker
WorkingDirectory=${HOME}
ExecStart=/usr/bin/docker compose up
ExecStop=/usr/bin/docker compose down --remove-orphans
Restart=on-failure
RestartSec=10
EOF

sudo systemctl restart compose