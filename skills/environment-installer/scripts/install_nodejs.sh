#!/bin/bash
# Install Node.js on macOS/Linux using version managers

set -e

PLATFORM=$1
NODE_VERSION=${2:-"lts"}

install_nodejs_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    # Install nvm (Node Version Manager)
    if ! command -v nvm &> /dev/null; then
        echo "📦 Installing nvm..."
        brew install nvm
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install Node.js
    echo "📦 Installing Node.js $NODE_VERSION..."
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
}

install_nodejs_linux() {
    # Install nvm
    if ! command -v nvm &> /dev/null; then
        echo "📦 Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install Node.js
    echo "📦 Installing Node.js $NODE_VERSION..."
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_nodejs_macos
            ;;
        linux)
            install_nodejs_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install OpenJS.NodeJS.LTS"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v node &> /dev/null; then
        echo "✅ Node.js $(node --version) installed successfully!"
        echo "✅ npm $(npm --version) installed successfully!"
    else
        echo "❌ Installation verification failed"
        return 1
    fi
}

main
