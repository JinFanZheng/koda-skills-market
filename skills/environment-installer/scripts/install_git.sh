#!/bin/bash
# Install Git on macOS/Linux

set -e

PLATFORM=$1

install_git_macos() {
    # Check if git is already installed
    if command -v git &> /dev/null; then
        echo "✅ Git is already installed: $(git --version)"
        echo "   To upgrade, run: brew upgrade git"
        return 0
    fi

    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    echo "📦 Installing Git via Homebrew..."
    brew install git

    echo "✅ Git installed successfully!"
}

install_git_linux() {
    # Check if git is already installed
    if command -v git &> /dev/null; then
        echo "✅ Git is already installed: $(git --version)"
        echo "   To upgrade, run: sudo apt update && sudo apt install git"
        return 0
    fi

    # Detect distribution
    if [ -f /etc/debian_version ]; then
        echo "📦 Installing Git on Debian/Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        echo "📦 Installing Git on Red Hat/CentOS..."
        sudo yum install -y git
    elif [ -f /etc/arch-release ]; then
        echo "📦 Installing Git on Arch Linux..."
        sudo pacman -S git
    else
        echo "⚠️  Unsupported Linux distribution."
        echo "   Please install Git manually: https://git-scm.com/downloads"
        return 1
    fi

    echo "✅ Git installed successfully!"
}

configure_git() {
    echo ""
    echo "📝 Recommended Git Configuration:"
    echo ""
    echo "   git config --global user.name 'Your Name'"
    echo "   git config --global user.email 'your.email@example.com'"
    echo ""
    echo "   # Set default branch name to main"
    echo "   git config --global init.defaultBranch main"
    echo ""
    echo "   # Choose your preferred editor"
    echo "   git config --global core.editor vim"
    echo ""
    echo "   # Enable colored output"
    echo "   git config --global color.ui auto"
    echo ""
    echo "   # Rebase by default when pulling"
    echo "   git config --global pull.rebase true"
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_git_macos
            ;;
        linux)
            install_git_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install Git.Git"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v git &> /dev/null; then
        echo ""
        echo "✅ Git $(git --version) installed successfully!"
        configure_git
    else
        echo "❌ Installation verification failed"
        return 1
    fi
}

main
