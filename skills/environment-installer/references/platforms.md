# Platform-Specific Installation Reference

This document contains platform-specific installation patterns and best practices for various development environments.

## Table of Contents

1. [macOS](#macos)
2. [Linux](#linux)
3. [Windows](#windows)
4. [Version Managers](#version-managers)

---

## macOS

### Package Managers

- **Homebrew**: The de facto standard package manager for macOS
  - Install: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - Usage: `brew install <package>`

### Installation Patterns

```bash
# Using Homebrew (recommended)
brew install node python go openjdk

# Using version managers (for multiple versions)
nvm install 18          # Node.js
pyenv install 3.12      # Python
sdk install java 21     # Java
```

### Configuration

Add to `~/.zshrc` (macOS Catalina and later uses zsh by default):

```bash
# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Java
export JAVA_HOME=$(/usr/libexec/java_home)
```

---

## Linux

### Package Managers by Distribution

- **Debian/Ubuntu**: `apt` or `apt-get`
- **Fedora**: `dnf`
- **Arch Linux**: `pacman`

### Installation Patterns

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install nodejs python3 golang openjdk-21-jdk

# Fedora
sudo dnf install nodejs python3 golang java-21-openjdk-devel

# Arch Linux
sudo pacman -S nodejs python go jdk-openjdk
```

### Version Managers (Recommended)

```bash
# Node.js (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Python (pyenv)
curl https://pyenv.run | bash

# Java (SDKMAN)
curl -s "https://get.sdkman.io" | bash

# Rust (rustup)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Configuration

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Java (SDKMAN)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -d "$SDKMAN_DIR/bin" ]] && export PATH="$PATH:$SDKMAN_DIR/bin"

# Go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```

---

## Windows

### Package Managers

- **winget**: Built-in package manager (Windows 10 1809+)
- **Chocolatey**: Third-party package manager
  - Install: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

### Installation Patterns

```powershell
# Using winget (built-in)
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.12
winget install GoLang.Go
winget search Oracle.JDK.21

# Using Chocolatey
choco install nodejs python golang jdk21
```

### Version Managers

```powershell
# Node.js (nvm-windows)
winget search nvm

# Python (pyenv-win)
winget install Pyenv-win

# Java (SDKMAN)
# SDKMAN doesn't support Windows; use manual install or alternatives
```

### Configuration

Add to System Environment Variables:

- `PATH`: Add installation directories (e.g., `C:\Program Files\nodejs`, `C:\Python312`)
- `JAVA_HOME`: Set to JDK installation directory (e.g., `C:\Program Files\Java\jdk-21`)
- `GOPATH`: Set to `C:\Users\<username>\go`

---

## Version Managers

### Node.js: nvm (Node Version Manager)

- **macOS/Linux**: `nvm`
- **Windows**: `nvm-windows` (separate project)

Usage:
```bash
nvm install 18          # Install specific version
nvm use 18              # Switch version
nvm alias default 18    # Set default
nvm ls                  # List installed versions
```

### Python: pyenv

- **macOS/Linux**: `pyenv`
- **Windows**: `pyenv-win`

Usage:
```bash
pyenv install 3.12      # Install specific version
pyenv global 3.12       # Set global version
pyenv local 3.12        # Set per-project version
pyenv versions          # List installed versions
```

### Java: SDKMAN

- **macOS/Linux**: `sdkman`
- **Windows**: Not supported; use alternatives like jabba or manual install

Usage:
```bash
sdk install java 21     # Install specific version
sdk use java 21         # Switch version for current session
sdk default java 21     # Set default
sdk list java           # List available versions
```

### Go: No version manager needed

Go supports multiple versions installed in parallel by installing to different directories.

---

## Official Resources

- **Node.js**: https://nodejs.org
- **Python**: https://python.org
- **Go**: https://go.dev
- **Java (OpenJDK)**: https://adoptium.net (formerly AdoptOpenJDK)
- **Rust**: https://rustup.rs
