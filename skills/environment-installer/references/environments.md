# Development Environments Reference

Complete guide for installing and configuring common development environments.

## Table of Contents

1. [Node.js](#nodejs)
2. [Python](#python)
3. [Go](#go)
4. [Java](#java)
5. [Rust](#rust)
6. [Verification Commands](#verification-commands)

---

## Node.js

### Installation Methods

| Platform | Recommended Method | Command |
|----------|-------------------|---------|
| macOS | Homebrew + nvm | `brew install nvm` |
| Linux | nvm installer | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh \| bash` |
| Windows | nvm-windows | `winget install CoreyButler.NVMforWindows` |

### Common Versions

- **LTS (Long Term Support)**: Recommended for production
- **Current**: Latest features, not recommended for production
- **Specific versions**: `18`, `20`, `22` (major versions)

### Verification

```bash
node --version    # Check Node.js version
npm --version     # Check npm version
nvm ls           # List installed versions (if using nvm)
```

### Common Issues

- **"command not found: node"**: Add to PATH or restart terminal
- **Permission errors**: Don't use sudo with nvm
- **Version conflicts**: Use nvm to manage multiple versions

---

## Python

### Installation Methods

| Platform | Recommended Method | Command |
|----------|-------------------|---------|
| macOS | Homebrew + pyenv | `brew install pyenv` |
| Linux | pyenv installer | `curl https://pyenv.run \| bash` |
| Windows | pyenv-win | `winget install Pyenv-win` |

### Common Versions

- **3.12**: Latest stable (recommended)
- **3.11**: Previous stable
- **3.10**: Older stable (legacy projects)
- **2.7**: Deprecated (avoid)

### Verification

```bash
python --version  # Check Python version
pip --version     # Check pip version
pyenv versions    # List installed versions (if using pyenv)
```

### Virtual Environments

```bash
# Create virtual environment
python -m venv venv

# Activate (macOS/Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

### Common Issues

- **"python command not found"**: Use `python3` or install via pyenv
- **pip install permission errors**: Use virtual environments or `--user` flag
- **SSL certificate errors**: Install certificates via `pip install certifi`

---

## Go

### Installation Methods

| Platform | Recommended Method | Command |
|----------|-------------------|---------|
| macOS | Homebrew | `brew install go` |
| Linux | Official tarball | Download from go.dev/dl |
| Windows | winget | `winget install GoLang.Go` |

### Environment Variables

```bash
# GOPATH: Go workspace (default: $HOME/go)
export GOPATH=$HOME/go

# PATH: Add Go binaries
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Go modules: Enable modules (Go 1.16+)
export GO111MODULE=on
```

### Verification

```bash
go version       # Check Go version
go env           # Check Go environment
echo $GOPATH     # Check GOPATH
```

### Project Structure

```
$GOPATH/
├── bin/         # Compiled binaries
├── pkg/         # Package objects
└── src/         # Source code
```

### Common Issues

- **"go: command not found"**: Add Go bin directory to PATH
- **Permission denied**: Don't install to `/usr/local/go` as non-root
- **Module proxy issues**: Set `GOPROXY` to `direct` or use mirrors

---

## Java

### Installation Methods

| Platform | Recommended Method | Command |
|----------|-------------------|---------|
| macOS | Homebrew (Temurin) | `brew install --cask temurin` |
| Linux | SDKMAN | `curl -s "https://get.sdkman.io" \| bash` |
| Windows | winget (Temurin) | `winget install EclipseAdoptium.Temurin.21.JDK` |

### Distributions

- **Eclipse Temurin** (AdoptOpenJDK): Recommended, open-source
- **Oracle JDK**: Official, commercial license
- **OpenJDK**: Community builds

### Common Versions

- **21**: Latest LTS (recommended)
- **17**: Previous LTS
- **11**: Older LTS (legacy projects)
- **8**: Very old (avoid unless required)

### Environment Variables

```bash
# JAVA_HOME: JDK installation directory
export JAVA_HOME=/usr/libexec/java_home  # macOS
export JAVA_HOME=/usr/lib/jvm/java-21   # Linux

# PATH: Add Java binaries
export PATH=$PATH:$JAVA_HOME/bin
```

### Verification

```bash
java -version       # Check Java version
javac -version      # Check Java compiler version
echo $JAVA_HOME     # Check JAVA_HOME
```

### Build Tools

```bash
# Maven (macOS)
brew install maven

# Maven (Linux)
sudo apt install maven

# Gradle (macOS)
brew install gradle

# Gradle (Linux)
sudo apt install gradle
```

### Common Issues

- **"java: command not found"**: Set JAVA_HOME and add to PATH
- **Version conflicts**: Use SDKMAN or `update-alternatives`
- **Certificate errors**: Import certificates into keystore

---

## Rust

### Installation Methods

| Platform | Recommended Method | Command |
|----------|-------------------|---------|
| All | rustup (official) | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |

### Verification

```bash
rustc --version    # Check Rust compiler version
cargo --version    # Check Cargo version
rustup show        # Show installed toolchains
```

### Common Issues

- **PATH not updated**: Restart terminal or source `~/.cargo/env`
- **Compilation errors**: Ensure C build tools are installed (Xcode on macOS, build-essential on Linux)

---

## Verification Commands

Quick reference for verifying installations:

```bash
# Node.js
node --version && npm --version

# Python
python --version && pip --version

# Go
go version && go env

# Java
java -version && javac -version

# Rust
rustc --version && cargo --version
```

---

## Troubleshooting

### PATH Issues

If commands aren't found after installation:

1. **Check PATH**: `echo $PATH`
2. **Restart terminal**: Environment variables may not be updated
3. **Reload shell config**: `source ~/.zshrc` or `source ~/.bashrc`
4. **Manual PATH addition**: Add to shell config file

### Permission Issues

- **Don't use sudo** with version managers (nvm, pyenv, sdkman)
- **Use virtual environments** for Python dependencies
- **Use user-level installs**: `pip install --user` or `npm install -g`

### Version Conflicts

- **Use version managers**: nvm, pyenv, sdkman
- **Check active versions**: `node --version`, `python --version`
- **Set defaults**: `nvm alias default`, `pyenv global`

---

## Official Resources

- **Node.js**: https://nodejs.org/en/download
- **Python**: https://python.org/downloads
- **Go**: https://go.dev/dl
- **Java (Temurin)**: https://adoptium.net
- **Rust**: https://rustup.rs

---

## Uninstalling Environments

### Node.js

**macOS/Linux (with nvm)**:
```bash
nvm uninstall <version>        # Remove specific version
rm -rf ~/.nvm                   # Remove nvm completely
```

**Windows**:
```powershell
winget uninstall OpenJS.NodeJS.LTS
# Or uninstall nvm-windows and remove %NVM_HOME%
```

### Python

**macOS/Linux (with pyenv)**:
```bash
pyenv uninstall <version>      # Remove specific version
brew uninstall pyenv            # macOS: Remove pyenv
rm -rf ~/.pyenv                 # Remove pyenv data
```

**Windows**:
```powershell
winget uninstall Python.Python.3.12
# Or remove pyenv-win from Control Panel
```

### Go

**macOS**:
```bash
brew uninstall go
```

**Linux**:
```bash
sudo rm -rf /usr/local/go
# Remove from PATH in ~/.bashrc or ~/.zshrc
```

**Windows**:
```powershell
winget uninstall GoLang.Go
# Remove Go from PATH in System Properties
```

### Java

**macOS (Homebrew)**:
```bash
brew uninstall --cask temurin
```

**Linux (SDKMAN)**:
```bash
sdk uninstall java <version>
```

**Windows**:
```powershell
winget uninstall EclipseAdoptium.Temurin.21.JDK
# Remove JAVA_HOME environment variable
```

### Docker

**macOS**:
```bash
brew uninstall --cask docker
# Remove Docker data:
rm -rf ~/Library/Containers/com.docker.docker
```

**Linux**:
```bash
sudo apt remove docker-ce docker-ce-cli containerd.io
sudo apt purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
# Remove user from docker group:
sudo gpasswd -d $USER docker
```

**Windows**:
```powershell
winget uninstall Docker.DockerDesktop
# Remove Docker data:
# %ProgramData%\Docker
# %AppData%\Docker
```

### .NET

**macOS**:
```bash
brew uninstall dotnet-sdk
```

**Linux**:
```bash
sudo apt remove dotnet-sdk-8.0
sudo apt remove dotnet-runtime-8.0
sudo apt remove aspnetcore-runtime-8.0
```

**Windows**:
```powershell
winget uninstall Microsoft.DotNet.SDK.8
# Also uninstall runtimes if installed
winget uninstall Microsoft.DotNet.Runtime.8
winget uninstall Microsoft.AspNetCore.Runtime.8
```

---

## Clean Up Tips

### Remove Configuration Files

After uninstalling, you may want to remove configuration files:

```bash
# Node.js/npm
rm -rf ~/.npm
rm -rf ~/.node_repl_history

# Python
rm -rf ~/.pip
rm -rf ~/.python_history

# Go
rm -rf ~/go

# Docker
rm -rf ~/.docker

# .NET
rm -rf ~/.nuget
rm -rf ~/.dotnet
```

### Remove Environment Variables

Edit your shell configuration file and remove lines related to:
- **Node.js**: `NVM_DIR`, nvm initialization
- **Python**: `PYENV_ROOT`, pyenv initialization
- **Go**: `GOPATH`, Go bin paths
- **Java**: `JAVA_HOME`
- **.NET**: DOTNET-related paths

**Configuration files**:
- macOS: `~/.zshrc` or `~/.bash_profile`
- Linux: `~/.bashrc` or `~/.profile`
- Windows: System Properties > Environment Variables

### Verify Removal

After uninstalling, verify the tool is no longer available:

```bash
which node    # Should return "not found"
which python  # Should return "not found"
which go      # Should return "not found"
which java    # Should return "not found"
which docker  # Should return "not found"
which dotnet  # Should return "not found"
```

---

## Official Uninstall Documentation

For the most up-to-date and comprehensive uninstall instructions:

- **Node.js (nvm)**: https://github.com/nvm-sh/nvm#uninstalling
- **Python (pyenv)**: https://github.com/pyenv/pyenv#uninstalling
- **Go**: https://go.dev/doc/install#uninstall
- **Docker**: https://docs.docker.com/engine/install/
- **.NET**: https://learn.microsoft.com/en-us/dotnet/core/install/uninstall

Always refer to official documentation for complete uninstallation instructions.
