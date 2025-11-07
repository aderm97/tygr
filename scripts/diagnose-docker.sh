#!/bin/bash
# Docker Troubleshooting and Startup Script

echo "Diagnosing Docker installation..."
echo ""

# Check if Docker is installed
echo "1. Docker binary location:"
which docker
echo ""

# Check Docker installation method
echo "2. Checking Docker installation method..."
if command -v snap &> /dev/null && snap list 2>/dev/null | grep -q docker; then
    echo "   Docker installed via: SNAP"
    DOCKER_METHOD="snap"
elif dpkg -l | grep -q docker-desktop; then
    echo "   Docker installed via: Docker Desktop"
    DOCKER_METHOD="desktop"
elif command -v docker.io &> /dev/null; then
    echo "   Docker installed via: docker.io package"
    DOCKER_METHOD="docker.io"
else
    echo "   Docker installed via: Unknown/Manual"
    DOCKER_METHOD="unknown"
fi
echo ""

# Check if dockerd is running
echo "3. Checking if Docker daemon is running..."
if pgrep -x dockerd > /dev/null; then
    echo "   ✓ Docker daemon (dockerd) IS running"
    DOCKERD_RUNNING=true
else
    echo "   ✗ Docker daemon (dockerd) is NOT running"
    DOCKERD_RUNNING=false
fi
echo ""

# Check Docker socket
echo "4. Checking Docker socket..."
if [ -S /var/run/docker.sock ]; then
    echo "   ✓ Docker socket exists at /var/run/docker.sock"
    ls -la /var/run/docker.sock
else
    echo "   ✗ Docker socket not found at /var/run/docker.sock"
fi
echo ""

# Try to connect to Docker
echo "5. Testing Docker connection..."
if sudo docker ps &> /dev/null; then
    echo "   ✓ Docker is working with sudo"
    DOCKER_WORKS_SUDO=true
else
    echo "   ✗ Docker not responding even with sudo"
    DOCKER_WORKS_SUDO=false
fi
echo ""

# Provide solution based on diagnosis
echo "========================================"
echo "RECOMMENDED ACTION:"
echo "========================================"

if [ "$DOCKER_METHOD" = "snap" ]; then
    echo "Docker is installed via Snap. Try:"
    echo "  sudo snap start docker"
    echo ""
elif [ "$DOCKER_METHOD" = "desktop" ]; then
    echo "Docker Desktop detected. Try:"
    echo "  systemctl --user start docker-desktop"
    echo "  Or launch Docker Desktop application"
    echo ""
elif [ "$DOCKERD_RUNNING" = false ]; then
    echo "Starting Docker daemon manually..."
    echo ""
    echo "Option 1: Start dockerd directly (requires root)"
    echo "  sudo dockerd > /tmp/dockerd.log 2>&1 &"
    echo ""
    echo "Option 2: Install Docker properly as a service"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install docker.io"
    echo "  sudo systemctl start docker"
    echo ""
    echo "Option 3: Use rootless Docker"
    echo "  dockerd-rootless-setuptool.sh install"
    echo ""

    # Offer to start dockerd
    echo "Would you like me to try starting dockerd now? (requires sudo)"
    echo "Run: sudo dockerd > /tmp/dockerd.log 2>&1 &"
else
    echo "Docker daemon appears to be running but not responding."
    echo "Try checking permissions or reinstalling Docker."
fi
echo ""

# Additional checks
echo "========================================"
echo "SYSTEM INFO:"
echo "========================================"
echo "Kernel: $(uname -r)"
echo "User: $(whoami)"
echo "Groups: $(groups)"
echo ""

if groups | grep -q docker; then
    echo "✓ You are in the 'docker' group"
else
    echo "✗ You are NOT in the 'docker' group"
    echo "  Add yourself with: sudo usermod -aG docker $USER"
    echo "  Then logout and login again"
fi
