#!/bin/bash
# TYGR Security Platform - Docker Setup Test Script
# This script helps verify your TYGR installation is working correctly

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Start tests
print_header "TYGR Security Platform - Setup Verification"

# Test 1: Check Docker is installed and running
print_info "Test 1: Checking Docker installation..."
if command -v docker &> /dev/null; then
    print_success "Docker is installed ($(docker --version))"

    if docker ps &> /dev/null; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running. Please start Docker and try again."
        exit 1
    fi
else
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Test 2: Check if .env file exists
print_info "Test 2: Checking environment configuration..."
if [ -f .env ]; then
    print_success ".env file found"

    # Check if required variables are set
    if grep -q "TYGR_LLM=" .env && grep -q "LLM_API_KEY=" .env; then
        print_success "Required environment variables configured"
    else
        print_warning ".env file exists but may be missing required variables"
        print_info "Please ensure TYGR_LLM and LLM_API_KEY are set"
    fi
else
    print_warning ".env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_info "Please edit .env file with your API keys before continuing"
        exit 1
    else
        print_error ".env.example not found. Please create .env manually."
        exit 1
    fi
fi

# Test 3: Check disk space
print_info "Test 3: Checking available disk space..."
AVAILABLE_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -ge 10 ]; then
    print_success "Sufficient disk space available (${AVAILABLE_SPACE}GB)"
else
    print_warning "Low disk space (${AVAILABLE_SPACE}GB). Recommended: 10GB+"
fi

# Test 4: Check if TYGR sandbox image exists
print_info "Test 4: Checking TYGR sandbox Docker image..."
if docker images | grep -q "tygr-sandbox"; then
    print_success "TYGR sandbox image found"
    IMAGE_SIZE=$(docker images tygr-sandbox --format "{{.Size}}")
    print_info "Image size: $IMAGE_SIZE"
else
    print_warning "TYGR sandbox image not found. Building now..."
    print_info "This will take 15-30 minutes on first build..."

    if docker build -f containers/Dockerfile -t tygr-sandbox:latest .; then
        print_success "TYGR sandbox image built successfully"
    else
        print_error "Failed to build TYGR sandbox image"
        exit 1
    fi
fi

# Test 5: Test running a container
print_info "Test 5: Testing container execution..."
if docker run --rm tygr-sandbox:latest python3 --version &> /dev/null; then
    print_success "Container can execute commands"
else
    print_error "Failed to run container"
    exit 1
fi

# Test 6: Check Python tools in container
print_info "Test 6: Verifying security tools in container..."
TOOLS=("nmap" "nuclei" "sqlmap" "python3" "playwright")
FAILED_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if docker run --rm tygr-sandbox:latest which "$tool" &> /dev/null; then
        print_success "$tool is available"
    else
        print_warning "$tool not found in container"
        FAILED_TOOLS+=("$tool")
    fi
done

if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    print_warning "Some tools are missing: ${FAILED_TOOLS[*]}"
    print_info "Container may still work, but some features might be limited"
fi

# Test 7: Create test workspace
print_info "Test 7: Setting up test workspace..."
mkdir -p test-workspace agent_runs

if [ -d "test-workspace" ] && [ -d "agent_runs" ]; then
    print_success "Test directories created"
else
    print_error "Failed to create test directories"
    exit 1
fi

# Test 8: Check Python/pipx for local installation
print_info "Test 8: Checking Python environment (optional)..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    print_success "Python 3 is installed ($PYTHON_VERSION)"

    if command -v pipx &> /dev/null; then
        print_success "pipx is installed"
    else
        print_warning "pipx not installed. Install with: python3 -m pip install --user pipx"
    fi
else
    print_warning "Python 3 not found. Required for local installation (not needed for Docker-only usage)"
fi

# Test 9: Quick container health check
print_info "Test 9: Running container health check..."
if docker run --rm tygr-sandbox:latest /bin/bash -c "echo 'Container is healthy'" &> /dev/null; then
    print_success "Container health check passed"
else
    print_error "Container health check failed"
    exit 1
fi

# Summary
print_header "Setup Verification Complete"
echo -e "${GREEN}Your TYGR installation is ready!${NC}\n"

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Ensure your .env file has valid API keys"
echo "2. Start the environment: docker compose up -d"
echo "3. Run a test scan: docker compose exec tygr-sandbox tygr --help"
echo "   Or install locally: pipx install -e ."
echo ""
echo -e "${BLUE}Quick Test Command:${NC}"
echo "  tygr --target ./test-workspace --instruction 'Quick security check'"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  - Setup guide: DOCKER_SETUP.md"
echo "  - Main README: README.md"
echo "  - Contributing: CONTRIBUTING.md"
echo ""
echo -e "${GREEN}Happy security testing! 🐯${NC}\n"
