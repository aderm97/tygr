# TYGR Security Platform - Docker Build Guide

This guide will help you build the TYGR Security Platform Docker image.

---

## 🐳 Prerequisites

### Required
- **Docker Desktop** installed and running
  - Windows: [Download Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
  - Mac: [Download Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
  - Linux: `sudo apt-get install docker.io` or equivalent

### Verify Docker is Running

**Windows PowerShell / Command Prompt:**
```powershell
docker --version
docker info
```

**Linux / Mac / Git Bash:**
```bash
docker --version
docker info
```

You should see version information and Docker daemon details.

---

## 🛠️ Build Instructions

### Option 1: Using PowerShell Script (Windows - Recommended)

```powershell
# Navigate to project root
cd C:\Users\Administrator\Projects\strix

# Run the build script
.\build-docker.ps1
```

### Option 2: Using Bash Script (Linux/Mac/Git Bash)

```bash
# Navigate to project root
cd /c/Users/Administrator/Projects/strix

# Make script executable (if needed)
chmod +x build-docker.sh

# Run the build script
./build-docker.sh
```

### Option 3: Manual Build (All Platforms)

```bash
# Navigate to project root
cd C:\Users\Administrator\Projects\strix

# Build the image
docker build -t tygr-security-platform:latest -f containers/Dockerfile .

# Note: The dot (.) at the end is important!
# It tells Docker to use the current directory as build context
```

---

## 📋 Build Process Details

### What Happens During Build

1. **Base Image**: Pulls Kali Linux rolling release
2. **Security Tools**: Installs penetration testing tools (nmap, sqlmap, nuclei, etc.)
3. **Python Environment**: Sets up Python 3.12+ with Poetry
4. **Browser Tools**: Installs Playwright for browser automation
5. **TYGR Package**: Copies tygr/ code into container
6. **Dependencies**: Installs all Python dependencies

### Expected Build Time

- **First Build**: 15-30 minutes (downloads base image and tools)
- **Subsequent Builds**: 5-10 minutes (uses cache)

### Build Output

You should see output like:
```
[+] Building 1234.5s (25/25) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/kali...
 => ...
 => => naming to tygr-security-platform:latest
```

---

## ✅ Verification

### 1. Check Image Exists

```bash
docker images | grep tygr-security-platform
```

**Expected Output:**
```
tygr-security-platform   latest    abc123def456   2 minutes ago   4.5GB
```

### 2. Test Image Works

```bash
# Run a simple test
docker run --rm tygr-security-platform:latest echo "✅ TYGR Container Works!"
```

**Expected Output:**
```
✅ TYGR Container Works!
```

### 3. Check TYGR Environment

```bash
# Check Python and TYGR package
docker run --rm tygr-security-platform:latest python -c "from tygr.agents import TygrAgent; print('✅ TYGR Package Loaded')"
```

### 4. Verify Tools Installed

```bash
# Check security tools
docker run --rm tygr-security-platform:latest nmap --version
docker run --rm tygr-security-platform:latest nuclei -version
```

---

## 🐛 Troubleshooting

### Issue: "docker: command not found"

**Solution**: Docker is not installed or not in PATH
- **Windows**: Restart Docker Desktop
- **Linux/Mac**: Install Docker: `sudo apt-get install docker.io`

### Issue: "Cannot connect to Docker daemon"

**Solution**: Docker daemon is not running
- **Windows**: Start Docker Desktop application
- **Linux**: `sudo systemctl start docker`
- **Mac**: Start Docker Desktop application

### Issue: "denied: requested access to the resource is denied"

**Solution**: Permission issue
- **Linux**: Add your user to docker group: `sudo usermod -aG docker $USER`
- Then log out and log back in

### Issue: Build fails with "COPY failed"

**Solution**: Ensure you're running from project root
```bash
# Check you're in the right directory
pwd
# Should show: /c/Users/Administrator/Projects/strix (or similar)

# List files to verify tygr/ exists
ls -la
# Should see: tygr/ directory
```

### Issue: "no space left on device"

**Solution**: Clean up Docker
```bash
# Remove unused containers, images, networks
docker system prune -a

# Check disk space
docker system df
```

### Issue: Build is very slow

**Solution**:
- Ensure good internet connection (downloads ~2GB)
- Docker Desktop may need more resources (Settings → Resources)
- On Windows: Increase WSL2 memory allocation

---

## 🔧 Advanced Options

### Build with Custom Tag

```bash
docker build -t tygr-security-platform:v0.3.2 -f containers/Dockerfile .
```

### Build without Cache (Clean Build)

```bash
docker build --no-cache -t tygr-security-platform:latest -f containers/Dockerfile .
```

### Build with Progress Output

```bash
docker build --progress=plain -t tygr-security-platform:latest -f containers/Dockerfile .
```

### Build for Different Platform (ARM/AMD64)

```bash
# For ARM (Apple Silicon)
docker build --platform linux/arm64 -t tygr-security-platform:latest -f containers/Dockerfile .

# For AMD64 (Intel/AMD)
docker build --platform linux/amd64 -t tygr-security-platform:latest -f containers/Dockerfile .
```

---

## 📦 After Building

### Tag for Registry (Optional)

```bash
# Tag for Docker Hub
docker tag tygr-security-platform:latest your-username/tygr-security-platform:latest

# Push to Docker Hub
docker push your-username/tygr-security-platform:latest
```

### Save Image to File (Optional)

```bash
# Save image to tar file
docker save -o tygr-security-platform.tar tygr-security-platform:latest

# Load image from tar file (on another machine)
docker load -i tygr-security-platform.tar
```

---

## 🧪 Testing the Image

### Interactive Shell

```bash
docker run -it --rm tygr-security-platform:latest /bin/bash
```

Inside the container:
```bash
# Check environment
echo $TYGR_SANDBOX_MODE  # Should show: true

# Check Python
python --version

# Check TYGR package
python -c "import tygr; print('TYGR loaded')"

# Check security tools
nmap --version
nuclei -version
sqlmap --version

# Exit
exit
```

### Run Security Scan (Requires Full Setup)

```bash
# This requires the full TYGR CLI to be set up
poetry run tygr --target https://example.com
```

---

## 📊 Image Information

### Expected Size
- **Compressed**: ~1.5-2GB
- **Uncompressed**: ~4-5GB

### Included Tools
- Network: nmap, ncat, netcat
- Web: nuclei, sqlmap, ffuf, dirsearch
- Recon: subfinder, httpx, katana
- Code Analysis: semgrep, bandit, trufflehog
- Browsers: Chromium (via Playwright)
- Languages: Python 3.12+, Node.js, Go

### Environment Variables
- `TYGR_SANDBOX_MODE=true`
- `PYTHONPATH=/app`
- `PATH` includes: Go bin, npm global, local bin

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Docker logs**: `docker logs <container-id>`
2. **Review build output**: Look for error messages during build
3. **Clean and retry**: `docker system prune -a` then rebuild
4. **GitHub Issues**: https://github.com/aderm97/tygr/issues
5. **Email**: hi@tygrsecurity.com

---

## ✅ Success Checklist

After building, you should be able to:

- [ ] See image in `docker images` list
- [ ] Run simple container: `docker run --rm tygr-security-platform:latest echo "test"`
- [ ] Import TYGR package in container
- [ ] Access security tools (nmap, nuclei, etc.)
- [ ] Start interactive shell

---

**Next Steps**: Once image is built, you can run the TYGR Security Platform CLI:
```bash
poetry run tygr --target https://example.com
```

The platform will automatically use the `tygr-security-platform:latest` image for security scanning.

---

**Build Guide Version**: 1.0
**Last Updated**: 2025-11-07
**Platform**: TYGR Security Platform v0.3.2
