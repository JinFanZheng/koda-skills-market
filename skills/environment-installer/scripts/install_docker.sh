#!/bin/bash
# Install Docker on macOS/Linux

set -e

PLATFORM=$1

install_docker_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    echo "📦 Installing Docker Desktop via Homebrew..."
    brew install --cask docker

    echo "✅ Docker Desktop installed!"
    echo "📝 Please open Docker Desktop from Applications to complete the setup."
    echo "   Docker daemon will start automatically after first launch."
}

install_docker_linux() {
    # Detect distribution
    if [ -f /etc/debian_version ]; then
        echo "📦 Installing Docker on Debian/Ubuntu..."
        install_docker_debian
    elif [ -f /etc/redhat-release ]; then
        echo "📦 Installing Docker on Red Hat/CentOS..."
        install_docker_redhat
    else
        echo "⚠️  Unsupported Linux distribution. Please install Docker manually:"
        echo "   https://docs.docker.com/engine/install/"
        return 1
    fi
}

install_docker_debian() {
    # Update package index
    sudo apt-get update

    # Install dependencies
    sudo apt-get install -y ca-certificates curl gnupg

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group (no sudo required)
    echo "📝 Adding current user to docker group..."
    sudo usermod -aG docker $USER

    echo "✅ Docker installed successfully!"
    echo "📝 Please log out and log back in to use Docker without sudo."
    echo "   Or run: 'newgrp docker' to apply group changes immediately."
}

install_docker_redhat() {
    # Install dependencies
    sudo yum install -y yum-utils

    # Add Docker repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Install Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Add user to docker group
    echo "📝 Adding current user to docker group..."
    sudo usermod -aG docker $USER

    echo "✅ Docker installed successfully!"
    echo "📝 Please log out and log back in to use Docker without sudo."
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_docker_macos
            ;;
        linux)
            install_docker_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install Docker.DockerDesktop"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation (skip for macOS as Docker Desktop needs manual launch)
    if [ "$PLATFORM" != "macos" ]; then
        if command -v docker &> /dev/null; then
            echo ""
            echo "✅ Docker $(docker --version | cut -d' ' -f3 | tr -d ',') installed successfully!"
            echo "✅ Docker Compose is available via 'docker compose' command"
        else
            echo "⚠️  Docker is installed but not in PATH. Please log out and log back in."
        fi
    fi
}

main
