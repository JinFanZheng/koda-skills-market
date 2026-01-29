#!/bin/bash
# Install .NET on macOS/Linux

set -e

PLATFORM=$1
DOTNET_VERSION=${2:-"latest"}

install_dotnet_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    echo "📦 Installing .NET via Homebrew..."
    brew install dotnet-sdk

    echo "✅ .NET SDK installed!"
}

install_dotnet_linux() {
    # Detect distribution
    if [ -f /etc/debian_version ]; then
        echo "📦 Installing .NET on Debian/Ubuntu..."
        install_dotnet_debian
    elif [ -f /etc/redhat-release ]; then
        echo "📦 Installing .NET on Red Hat/CentOS..."
        install_dotnet_redhat
    else
        echo "⚠️  Unsupported Linux distribution. Please install .NET manually:"
        echo "   https://learn.microsoft.com/en-us/dotnet/core/install/linux"
        return 1
    fi
}

install_dotnet_debian() {
    # Get Ubuntu version
    . /etc/os-release
    UBUNTU_VERSION=$VERSION_ID

    # Add Microsoft package repository
    wget https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
    sudo dpkg -i /tmp/packages-microsoft-prod.deb
    rm /tmp/packages-microsoft-prod.deb

    # Update package list
    sudo apt-get update

    # Install .NET SDK
    sudo apt-get install -y dotnet-sdk-8.0

    echo "✅ .NET SDK 8.0 installed successfully!"
    echo "📝 To install other versions, use:"
    echo "   sudo apt-get install -y dotnet-sdk-7.0"
    echo "   sudo apt-get install -y dotnet-sdk-6.0"
}

install_dotnet_redhat() {
    # Install .NET SDK
    sudo yum install -y dotnet-sdk-8.0

    echo "✅ .NET SDK 8.0 installed successfully!"
    echo "📝 To install other versions, use:"
    echo "   sudo yum install -y dotnet-sdk-7.0"
    echo "   sudo yum install -y dotnet-sdk-6.0"
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_dotnet_macos
            ;;
        linux)
            install_dotnet_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget install Microsoft.DotNet.SDK.8"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v dotnet &> /dev/null; then
        echo ""
        echo "✅ .NET SDK $(dotnet --version) installed successfully!"
        echo ""
        echo "📝 Useful commands:"
        echo "   dotnet --info          Show .NET information"
        echo "   dotnet --list-sdks     List installed SDKs"
        echo "   dotnet --list-runtimes List installed runtimes"
        echo "   dotnet new             Create a new project"
    else
        echo "❌ Installation verification failed"
        echo "📝 Please restart your terminal or run: source ~/.zshrc (macOS) or source ~/.bashrc (Linux)"
        return 1
    fi
}

main
