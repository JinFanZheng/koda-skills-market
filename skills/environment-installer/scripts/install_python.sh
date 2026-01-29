#!/bin/bash
# Install Python on macOS/Linux using pyenv

set -e

PLATFORM=$1
PYTHON_VERSION=${2:-"3.12"}

install_python_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    # Install pyenv
    if ! command -v pyenv &> /dev/null; then
        echo "📦 Installing pyenv..."
        brew install pyenv
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(pyenv init -)"' >> ~/.zshrc
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi

    # Install Python
    echo "📦 Installing Python $PYTHON_VERSION..."
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
}

install_python_linux() {
    # Install dependencies
    echo "📦 Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
        liblzma-dev python-openssl git

    # Install pyenv
    if ! command -v pyenv &> /dev/null; then
        echo "📦 Installing pyenv..."
        curl https://pyenv.run | bash
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi

    # Install Python
    echo "📦 Installing Python $PYTHON_VERSION..."
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_python_macos
            ;;
        linux)
            install_python_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install Python.Python.3.12"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v python &> /dev/null; then
        echo "✅ Python $(python --version) installed successfully!"
        echo "✅ pip $(pip --version) installed successfully!"
    else
        echo "❌ Installation verification failed"
        return 1
    fi
}

main
