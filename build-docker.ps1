# TYGR Security Platform - Docker Build Script (PowerShell)
# This script builds the Docker image for TYGR Security Platform

param(
    [string]$Tag = "latest",
    [switch]$NoCache,
    [switch]$Verbose
)

Write-Host ""
Write-Host "🐯 TYGR Security Platform - Docker Build" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is available
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    exit 1
}

# Check if Docker daemon is running
Write-Host "Checking Docker daemon..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker daemon is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the right directory
Write-Host "Verifying project structure..." -ForegroundColor Yellow
if (-not (Test-Path "tygr")) {
    Write-Host "❌ Error: tygr/ directory not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run this script from the project root directory:" -ForegroundColor Yellow
    Write-Host "cd C:\Users\Administrator\Projects\strix" -ForegroundColor Cyan
    exit 1
}

if (-not (Test-Path "containers/Dockerfile")) {
    Write-Host "❌ Error: containers/Dockerfile not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green
Write-Host ""

# Build parameters
$ImageName = "tygr-security-platform"
$ImageTag = "${ImageName}:${Tag}"

Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Image Name: $ImageName" -ForegroundColor White
Write-Host "  Image Tag:  $Tag" -ForegroundColor White
Write-Host "  Full Tag:   $ImageTag" -ForegroundColor White
if ($NoCache) {
    Write-Host "  No Cache:   Enabled" -ForegroundColor Yellow
}
Write-Host ""

# Confirm build
$confirmation = Read-Host "Proceed with build? This may take 15-30 minutes on first build (y/n)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Build cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔨 Starting Docker build..." -ForegroundColor Cyan
Write-Host "This may take a while. Please be patient..." -ForegroundColor Yellow
Write-Host ""

# Build command
$buildCmd = "docker build -t $ImageTag -f containers/Dockerfile ."

if ($NoCache) {
    $buildCmd += " --no-cache"
}

if ($Verbose) {
    $buildCmd += " --progress=plain"
}

# Record start time
$startTime = Get-Date

# Execute build
try {
    Invoke-Expression $buildCmd
    $buildSuccess = $LASTEXITCODE -eq 0
} catch {
    $buildSuccess = $false
}

# Record end time
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

if ($buildSuccess) {
    Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Build Time: $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host "Image Tag:  $ImageTag" -ForegroundColor White
    Write-Host ""

    # Verify image
    Write-Host "Verifying image..." -ForegroundColor Yellow
    $imageInfo = docker images $ImageName --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
    Write-Host "✅ Image created: $imageInfo" -ForegroundColor Green
    Write-Host ""

    Write-Host "🧪 Quick Test:" -ForegroundColor Cyan
    Write-Host "Run this command to test the image:" -ForegroundColor White
    Write-Host "  docker run --rm $ImageTag echo '✅ TYGR Container Works!'" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📚 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Test the image with: docker run --rm -it $ImageTag /bin/bash" -ForegroundColor White
    Write-Host "2. Run TYGR Security Platform: poetry run tygr --target https://example.com" -ForegroundColor White
    Write-Host ""

} else {
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Network connectivity problems" -ForegroundColor White
    Write-Host "  - Insufficient disk space" -ForegroundColor White
    Write-Host "  - Docker resource limits" -ForegroundColor White
    Write-Host ""
    Write-Host "For help, see: DOCKER_BUILD_GUIDE.md" -ForegroundColor Cyan
    exit 1
}
