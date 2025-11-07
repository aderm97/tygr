#!/usr/bin/env bash
# TYGR Security Platform - Docker Build Script (Bash)
# This script builds the Docker image for TYGR Security Platform

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
TAG="latest"
NO_CACHE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --tag TAG       Docker image tag (default: latest)"
            echo "  --no-cache      Build without using cache"
            echo "  --verbose       Show detailed build output"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo ""
echo -e "${CYAN}🐯 TYGR Security Platform - Docker Build${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check if Docker is available
echo -e "${YELLOW}Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Error: Docker is not installed or not in PATH${NC}"
    echo ""
    echo -e "${YELLOW}Please install Docker:${NC}"
    echo -e "${CYAN}  Linux: sudo apt-get install docker.io${NC}"
    echo -e "${CYAN}  Mac: https://www.docker.com/products/docker-desktop/${NC}"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
echo -e "${GREEN}✅ Docker found: $DOCKER_VERSION${NC}"

# Check if Docker daemon is running
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Error: Docker daemon is not running${NC}"
    echo ""
    echo -e "${YELLOW}Please start Docker and try again:${NC}"
    echo -e "${CYAN}  Linux: sudo systemctl start docker${NC}"
    echo -e "${CYAN}  Mac: Start Docker Desktop${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker daemon is running${NC}"

# Check if we're in the right directory
echo -e "${YELLOW}Verifying project structure...${NC}"
if [ ! -d "tygr" ]; then
    echo -e "${RED}❌ Error: tygr/ directory not found${NC}"
    echo ""
    echo -e "${YELLOW}Please run this script from the project root directory${NC}"
    exit 1
fi

if [ ! -f "containers/Dockerfile" ]; then
    echo -e "${RED}❌ Error: containers/Dockerfile not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project structure verified${NC}"
echo ""

# Build parameters
IMAGE_NAME="tygr-security-platform"
IMAGE_TAG="${IMAGE_NAME}:${TAG}"

echo -e "${CYAN}Build Configuration:${NC}"
echo -e "  Image Name: ${IMAGE_NAME}"
echo -e "  Image Tag:  ${TAG}"
echo -e "  Full Tag:   ${IMAGE_TAG}"
if [ "$NO_CACHE" = true ]; then
    echo -e "  No Cache:   ${YELLOW}Enabled${NC}"
fi
echo ""

# Confirm build
read -p "Proceed with build? This may take 15-30 minutes on first build (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Build cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}🔨 Starting Docker build...${NC}"
echo -e "${YELLOW}This may take a while. Please be patient...${NC}"
echo ""

# Build command
BUILD_CMD="docker build -t ${IMAGE_TAG} -f containers/Dockerfile ."

if [ "$NO_CACHE" = true ]; then
    BUILD_CMD="$BUILD_CMD --no-cache"
fi

if [ "$VERBOSE" = true ]; then
    BUILD_CMD="$BUILD_CMD --progress=plain"
fi

# Record start time
START_TIME=$(date +%s)

# Execute build
set +e
eval $BUILD_CMD
BUILD_EXIT_CODE=$?
set -e

# Record end time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

echo ""
echo -e "${CYAN}=========================================${NC}"

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo ""
    echo -e "Build Time: ${DURATION_MIN}m ${DURATION_SEC}s"
    echo -e "Image Tag:  ${IMAGE_TAG}"
    echo ""

    # Verify image
    echo -e "${YELLOW}Verifying image...${NC}"
    IMAGE_INFO=$(docker images ${IMAGE_NAME} --format "{{.Repository}}:{{.Tag}} - {{.Size}}" | head -1)
    echo -e "${GREEN}✅ Image created: ${IMAGE_INFO}${NC}"
    echo ""

    echo -e "${CYAN}🧪 Quick Test:${NC}"
    echo -e "Run this command to test the image:"
    echo -e "${YELLOW}  docker run --rm ${IMAGE_TAG} echo '✅ TYGR Container Works!'${NC}"
    echo ""

    echo -e "${CYAN}📚 Next Steps:${NC}"
    echo -e "1. Test the image with: ${YELLOW}docker run --rm -it ${IMAGE_TAG} /bin/bash${NC}"
    echo -e "2. Run TYGR Security Platform: ${YELLOW}poetry run tygr --target https://example.com${NC}"
    echo ""

    exit 0
else
    echo -e "${RED}❌ BUILD FAILED!${NC}"
    echo ""
    echo -e "${YELLOW}Please check the error messages above.${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "  - Network connectivity problems"
    echo -e "  - Insufficient disk space"
    echo -e "  - Docker resource limits"
    echo ""
    echo -e "${CYAN}For help, see: DOCKER_BUILD_GUIDE.md${NC}"
    exit 1
fi
