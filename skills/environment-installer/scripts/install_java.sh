#!/bin/bash
# Install Java (OpenJDK) on macOS/Linux using SDKMAN

set -e

PLATFORM=$1
JAVA_VERSION=${2:-"21"}

install_java_macos() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install it first: https://brew.sh"
        return 1
    fi

    echo "📦 Installing OpenJDK $JAVA_VERSION..."
    brew install --cask temurin@$JAVA_VERSION
}

install_java_linux() {
    # Install SDKMAN
    if ! command -v sdk &> /dev/null; then
        echo "📦 Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    echo "📦 Installing Java $JAVA_VERSION..."
    sdk install java "$JAVA_VERSION"
    sdk default java "$JAVA_VERSION"
}

main() {
    echo "🔍 Detecting platform..."
    case "$PLATFORM" in
        macos)
            install_java_macos
            ;;
        linux)
            install_java_linux
            ;;
        windows)
            echo "❌ Windows not supported by this script. Use winget: winget search Oracle.JDK.21"
            return 1
            ;;
        *)
            echo "❌ Unknown platform: $PLATFORM"
            return 1
            ;;
    esac

    # Verify installation
    if command -v java &> /dev/null; then
        echo "✅ Java $(java -version 2>&1 | head -n 1) installed successfully!"
    else
        echo "❌ Installation verification failed"
        return 1
    fi
}

main
