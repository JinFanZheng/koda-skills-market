---
name: environment-installer
description: >-
  Cross-platform development environment installer for Git, Node.js, Python, Go, Java,
  .NET, Docker, Rust, and other programming languages. Automatically detects platform
  (macOS/Linux/Windows) and uses appropriate package managers (Homebrew, apt, dnf, winget)
  and version managers (nvm, pyenv, sdkman). Use when user needs to: (1) Install a
  programming language runtime, (2) Set up development environment, (3) Manage multiple
  language versions, (4) Install containerization tools (Docker), (5) Install version
  control (Git), (6) Verify installation, (7) Get platform-specific installation
  instructions, or (8) Uninstall development environments.
---

# Environment Installer

Cross-platform development environment installer that detects the operating system and uses the appropriate installation method for each platform.

## Quick Start

### Fully Automated Installation (All Platforms)

The skill automatically detects your platform and uses the appropriate installer:

**macOS/Linux**:
```bash
# Auto-detect platform and install
PLATFORM=$(scripts/detect_platform.sh)
scripts/install_git.sh $PLATFORM
scripts/install_nodejs.sh $PLATFORM lts
scripts/install_python.sh $PLATFORM 3.12
scripts/install_golang.sh $PLATFORM latest
scripts/install_java.sh $PLATFORM 21
scripts/install_docker.sh $PLATFORM
scripts/install_dotnet.sh $PLATFORM
```

**Windows** (Command Prompt/PowerShell):
```cmd
REM Auto-detect and install (Windows)
scripts\install_git.bat
scripts\install_nodejs.bat
scripts\install_python.bat
scripts\install_golang.bat
scripts\install_java.bat
scripts\install_docker.bat
scripts\install_dotnet.bat
```

### Manual Platform Detection

```bash
# macOS/Linux
scripts/detect_platform.sh

# Windows
scripts\detect_platform.bat
```

**Outputs**: `macos` | `linux` | `windows` | `unknown`

---

## ✨ True Cross-Platform Automation

This skill provides **zero-configuration** installation on all major platforms:

| Platform | Installer Type | Automation Level |
|----------|---------------|------------------|
| macOS | Bash scripts | ✅ Fully automated |
| Linux | Bash scripts | ✅ Fully automated |
| Windows | Batch scripts | ✅ Fully automated |

**No manual intervention required** - the skill handles:
- ✅ Platform detection
- ✅ Package manager selection (Homebrew/apt/winget)
- ✅ Version manager installation (nvm/pyenv/sdkman)
- ✅ Environment configuration
- ✅ Installation verification

---

## Supported Environments

### Git
- **macOS**: Homebrew
- **Linux**: System package manager (apt/yum/pacman)
- **Windows**: winget (Git.Git)

### Node.js
- **macOS**: Homebrew + nvm
- **Linux**: nvm (curl installer)
- **Windows**: winget (OpenJS.NodeJS.LTS)

### Python
- **macOS**: Homebrew + pyenv
- **Linux**: pyenv (curl installer)
- **Windows**: winget (Python.Python.3.12) or pyenv-win

### Go
- **macOS**: Homebrew
- **Linux**: Official tarball (go.dev)
- **Windows**: winget (GoLang.Go)

### Java
- **macOS**: Homebrew (Temurin/Eclipse Adoptium)
- **Linux**: SDKMAN
- **Windows**: winget (EclipseAdoptium.Temurin)

### Rust
- **All platforms**: rustup (official installer)

### Docker
- **macOS**: Homebrew (Docker Desktop)
- **Linux**: Official repository (docker-ce)
- **Windows**: winget (Docker Desktop)

### .NET
- **macOS**: Homebrew (dotnet-sdk)
- **Linux**: Microsoft official repository (dotnet-sdk-8.0)
- **Windows**: winget (Microsoft.DotNet.SDK.8)

---

## 🚫 NEVER Do These Things

**NEVER install Python via apt on Ubuntu without deadsnakes PPA** - it installs ancient Python versions that conflict with pyenv and can break system tools that depend on specific Python versions.

**NEVER install Node.js via apt on Ubuntu** - the version is 4+ years old. Always use nvm or NodeSource repository.

**NEVER mix Homebrew and manual installations** - e.g., installing Go via both `brew install go` AND manual tarball creates unresolvable PATH conflicts and version confusion.

**NEVER install Docker Desktop on headless Linux servers** - use docker-ce package instead. Docker Desktop requires GUI and is designed for desktop use.

**NEVER use sudo with nvm/pyenv/sdkman** - these tools are designed for user-space installation. Using sudo breaks permissions and defeats the purpose of version managers.

**NEVER skip the verification step** - scripts can exit without errors while installation fails silently. Always run `--version` commands after installation.

**NEVER mix system and version-manager installations** - e.g., installing Python via both apt AND pyenv creates unresolvable version conflicts that are difficult to debug.

---

## Before Installing - Ask Yourself

1. **Purpose**: What will this environment be used for?
   - Web development → Node.js
   - Data science/AI → Python
   - Cloud native → Go + Docker
   - Enterprise → Java/.NET
   - Containerization → Docker

2. **Scope**: Is this for:
   - **Personal learning** → Version manager recommended (flexibility)
   - **Team project** → Match team's version manager
   - **Production** → Use system packages for stability

3. **Constraints**:
   - **No sudo access?** → Use user-space tools (nvm/pyenv)
   - **Corporate firewall?** → May need manual installation
   - **CI/CD environment?** → Use Docker images instead of installing
   - **Headless server?** → Don't install Docker Desktop, use docker-ce

---

## Installation Workflow

### 1. Detect Platform

Always start by detecting the platform:

```bash
PLATFORM=$(scripts/detect_platform.sh)
echo "Detected platform: $PLATFORM"
```

### 2. Install Environment

Use the appropriate script based on the environment:

```bash
scripts/install_git.sh $PLATFORM
scripts/install_nodejs.sh $PLATFORM [version]
scripts/install_python.sh $PLATFORM [version]
scripts/install_golang.sh $PLATFORM [version]
scripts/install_java.sh $PLATFORM [version]
scripts/install_docker.sh $PLATFORM
scripts/install_dotnet.sh $PLATFORM [version]
```

### 3. Verify Installation

All scripts include automatic verification. Manual verification:

```bash
# Git
git --version

# Node.js
node --version && npm --version

# Python
python --version && pip --version

# Go
go version

# Docker
docker --version
docker compose version

# .NET
dotnet --version

# Java
java -version
```

---

## Platform-Specific Notes

### macOS
- **Non-obvious**: Docker Desktop requires manual launch after installation (not automatic)
- **Dependency**: Xcode Command Line Tools for Python compilation

### Linux
- **Critical**: `build-essential` required for Python pyenv compilation
- **Docker**: Add user to docker group to avoid sudo (automatically done by script)
- **Package managers**: Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman)

### Windows
- **Requirement**: Windows 10 1809+ for winget
- **Privileges**: Administrator access required for some installations
- **Alternative**: Chocolatey if winget unavailable
- **Critical**: ⚠️ **ALL installations require terminal restart** - Close and reopen Command Prompt/PowerShell after installation
- **Docker**: Requires manual start from Start Menu after installation

---

## Version Managers

Quick reference for version managers used by this skill:

| Manager | Language | Install | Switch | Set Default |
|---------|----------|---------|--------|-------------|
| nvm | Node.js | `nvm install 18` | `nvm use 18` | `nvm alias default 18` |
| pyenv | Python | `pyenv install 3.12` | `pyenv global 3.12` | `pyenv global 3.12` |
| sdkman | Java | `sdk install java 21` | `sdk use java 21` | `sdk default java 21` |

For detailed usage, see [`references/environments.md`](references/environments.md).

---

## Common Patterns

### Install Multiple Environments

```bash
PLATFORM=$(scripts/detect_platform.sh)

# Install Node.js, Python, and Go
scripts/install_nodejs.sh $PLATFORM lts
scripts/install_python.sh $PLATFORM 3.12
scripts/install_golang.sh $PLATFORM latest
```

### Install Specific Versions

```bash
# Node.js 18
scripts/install_nodejs.sh macos 18

# Python 3.11
scripts/install_python.sh linux 3.11

# Java 17
scripts/install_java.sh macos 17
```

### Minimal Installation (No Version Managers)

For system-level installations without version managers:

```bash
# macOS
brew install node python3 go openjdk docker dotnet-sdk

# Linux (Debian/Ubuntu)
sudo apt install nodejs python3 golang openjdk-21-jdk docker.io dotnet-sdk-8.0
```

---

## Troubleshooting

### Command Not Found

**Problem**: Installation succeeded but `node`/`python`/`go`/`java` commands not found.

**Solutions**:
1. Restart terminal to reload environment variables
2. Run `source ~/.zshrc` (macOS) or `source ~/.bashrc` (Linux)
3. Manually add to PATH: `export PATH=$PATH:/path/to/bin`

### Permission Errors

**Problem**: Installation fails with permission denied.

**Solutions**:
- **Don't use sudo** with version managers (nvm, pyenv, sdkman)
- Use Homebrew (macOS) which handles permissions correctly
- For Linux system installs, use `sudo` only with apt/dnf
- For Docker on Linux: Add user to docker group to avoid sudo

### Docker Issues

**Problem**: Docker daemon not running or permission denied.

**Solutions**:
- **macOS**: Open Docker Desktop from Applications to start daemon
- **Linux**: Start docker service: `sudo systemctl start docker`
- **Permission denied**: Add user to docker group (automatically done by script)
  - Log out and log back in for group changes to take effect
  - Or run: `newgrp docker` to apply immediately

### .NET Issues

**Problem**: dotnet command not found after installation.

**Solutions**:
1. Restart terminal to reload PATH
2. Run `source ~/.zshrc` (macOS) or `source ~/.bashrc` (Linux)
3. Verify SDK installation: `dotnet --list-sdks`

### SSL/Certificate Errors

**Problem**: Downloads fail with SSL errors.

**Solutions**:
- Install certificates: `pip install certifi` (Python)
- Use alternative download mirrors
- Update CA certificates: `sudo apt update && sudo apt install ca-certificates` (Linux)

### Version Conflicts

**Problem**: Multiple versions installed, wrong one active.

**Solutions**:
- Use version managers to switch: `nvm use 18`, `pyenv global 3.12`
- Check active version: `node --version`, `python --version`
- Set default: `nvm alias default 18`, `pyenv global 3.12`

---

## Reference Documentation

### When to Load References

**MANDATORY - FOR PERSISTENT ISSUES**: If standard troubleshooting fails, you MUST read
[`references/platforms.md`](references/platforms.md) (216 lines) for platform-specific issues and
[`references/environments.md`](references/environments.md) (476 lines) for environment-specific known issues.

**Do NOT load** these references for:
- Successful installations (scripts handle everything)
- Basic version queries (use `--version` commands)
- Quick reference (this SKILL.md contains all essential info)

### Available References

- **[platforms.md](references/platforms.md)**: Platform-specific installation patterns and configuration
- **[environments.md](references/environments.md)**: Detailed environment setup, verification commands, and uninstall procedures

---

## Windows Support

**Fully automated** via `.bat` scripts:

```cmd
REM Install Git
scripts\install_git.bat

REM Install Node.js
scripts\install_nodejs.bat

REM Install Python
scripts\install_python.bat

REM Install Go
scripts\install_golang.bat

REM Install Java
scripts\install_java.bat

REM Install Docker
scripts\install_docker.bat

REM Install .NET
scripts\install_dotnet.bat
```

The Windows scripts use **winget** (built-in package manager) and handle:
- Package installation
- Verification
- PATH configuration reminders

**Alternative**: Use Chocolatey if winget is unavailable:
```powershell
choco install git nodejs python golang jdk21 docker dotnet-sdk
```

---

## Best Practices

1. **Use version managers**: They simplify managing multiple versions
2. **Verify after install**: All scripts include automatic verification
3. **Keep environments updated**: Regularly update for security patches
4. **Use virtual environments**: For Python, use venv to avoid conflicts
5. **Read the output**: Installation scripts provide helpful information

---

## Special Environments

### Corporate Networks / Firewalls
If downloads fail due to corporate proxy:
1. Check if firewall blocks downloads
2. Manual download from official sources:
   - Node.js: https://nodejs.org
   - Python: https://python.org
   - Go: https://go.dev/dl
   - Java: https://adoptium.net
   - Docker: https://docs.docker.com/engine/install/
   - .NET: https://dotnet.microsoft.com/download

### CI/CD Environments
For GitHub Actions/GitLab CI:
- **Don't install** - use pre-built images instead
- GitHub Actions: `actions/setup-node@v4`, `actions/setup-python@v5`
- Docker-based CI: Use `node:18`, `python:3.12`, `golang:latest` images directly

### Rollback on Failure
If installation fails partway through:
1. Check script output for specific failure point
2. Use uninstall procedures in [`references/environments.md`](references/environments.md)
3. Clean partial state before retrying

---

## Limitations

- **Windows**: ALL installations require terminal restart - Windows loads environment variables at process startup
- **Windows**: Administrator privileges required for some installations
- **Windows**: Go may require manual PATH addition if not automatically configured
- **Windows**: Docker Desktop requires manual launch from Start Menu
- **Linux**: Some environments require additional dependencies (e.g., build-essential for Python)
- **Corporate networks**: Proxies/firewalls may block downloads; manual installation may be needed
