#!/bin/bash
# Install Go on macOS/Linux

set -e

PLATFORM=$1
GO_VERSION=${2:-"latest"}

install_go_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    echo "📦 Installing Go..."
    brew install go
}

install_go_linux() {
    # Detect latest version if not specified
    if [ "$GO_VERSION" = "latest" ]; then
        GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
    fi

    echo "📦 Installing Go $GO_VERSION..."

    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        ARCH="arm64"
    elif [ "$ARCH" = "x86_64" ]; then
        ARCH="amd64"
    fi

    GO_PKG="go${GO_VERSION}.linux-${ARCH}.tar.gz"

    # Download and install
    wget "https://go.dev/dl/$GO_PKG" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    # Add to PATH
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    export PATH=$PATH:$HOME/go/bin
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_go_macos
            ;;
        linux)
            install_go_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install GoLang.Go"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v go &> /dev/null; then
        echo "✅ Go $(go version) installed successfully!"
        echo "📝 GOPATH: $GOPATH"
    else
        echo "❌ Installation verification failed"
        return 1
    fi
}

main
