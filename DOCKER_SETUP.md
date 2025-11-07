# Docker Setup Guide for TYGR Security Platform

This guide will help you pull and test TYGR Security Platform on your secondary PC using Docker.

## Prerequisites

- Docker installed and running
- Git installed
- At least 10GB free disk space (for Docker images and dependencies)
- Internet connection
- An LLM API key (OpenAI, Anthropic, or local LLM)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/aderm97/tygr.git
cd tygr
```

If you want to test the specific branch:
```bash
git clone https://github.com/aderm97/tygr.git
cd tygr
git checkout claude/docker-setup-011CUuK7w7HFpboQDKGaS1Zk
```

### 2. Build the Docker Sandbox Image

TYGR uses a specialized Kali Linux-based Docker container for security testing. Build it with:

```bash
docker build -f containers/Dockerfile -t tygr-sandbox:latest .
```

**Note:** This will take 15-30 minutes on first build as it:
- Downloads Kali Linux base image (~500MB)
- Installs security tools (nmap, nuclei, sqlmap, etc.)
- Sets up Python, Node.js, and Go environments
- Installs Playwright browser automation

### 3. Install TYGR CLI (Two Options)

#### Option A: Using Docker Compose (Recommended for Testing)

```bash
# Start the environment
docker compose up -d

# Run TYGR through Docker
docker compose exec tygr tygr --help
```

#### Option B: Local Installation with pipx

```bash
# Install pipx if not already installed
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Install TYGR
pipx install -e .
```

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```bash
# For OpenAI
export TYGR_LLM="openai/gpt-4o"
export LLM_API_KEY="sk-your-openai-api-key"

# For Anthropic Claude
# export TYGR_LLM="anthropic/claude-sonnet-4"
# export LLM_API_KEY="sk-ant-your-anthropic-key"

# For local LLM (Ollama example)
# export TYGR_LLM="ollama/llama3.1"
# export LLM_API_BASE="http://localhost:11434"

# Optional: For search capabilities
# export PERPLEXITY_API_KEY="your-perplexity-key"
```

Load the environment:
```bash
source .env
```

## Testing the Installation

### Test 1: Verify Docker Image

```bash
# Check the image was built
docker images | grep tygr-sandbox

# Should show something like:
# tygr-sandbox   latest   abc123def456   5 minutes ago   4.5GB
```

### Test 2: Run Container Interactively

```bash
docker run -it --rm tygr-sandbox:latest /bin/bash

# Inside container, test some tools:
nmap --version
nuclei -version
python3 --version
playwright --version
exit
```

### Test 3: Run a Simple Security Scan

Create a test directory with a vulnerable app:

```bash
# Create a simple test case
mkdir -p /tmp/test-app
cat > /tmp/test-app/app.py << 'EOF'
from flask import Flask, request
import os

app = Flask(__name__)

@app.route('/exec')
def exec_command():
    # Vulnerable to command injection
    cmd = request.args.get('cmd', 'echo hello')
    result = os.system(cmd)
    return f"Executed: {cmd}"

if __name__ == '__main__':
    app.run(debug=True)
EOF
```

Run TYGR on it:

```bash
# Make sure Docker is running and env vars are set
tygr --target /tmp/test-app --instruction "Look for command injection vulnerabilities"
```

### Test 4: Test with a GitHub Repository

```bash
# Scan a public repository
tygr --target https://github.com/username/repo-name
```

### Test 5: Test Web Application Scanning

```bash
# Scan a live web application (use only on sites you own!)
tygr --target https://your-test-app.com
```

## Troubleshooting

### Docker Image Build Fails

```bash
# Clean up and rebuild
docker system prune -a
docker build --no-cache -f containers/Dockerfile -t tygr-sandbox:latest .
```

### Poetry Lock Issues

```bash
# If you see poetry dependency issues
poetry lock --no-update
poetry install
```

### Permission Denied Errors

```bash
# On Linux, you may need to add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Playwright Browser Issues

```bash
# If browser automation fails, reinstall playwright
poetry run playwright install chromium
```

## Architecture Overview

TYGR consists of two main components:

1. **TYGR CLI** (runs on host)
   - Python application installed via pipx
   - Orchestrates security testing agents
   - Communicates with LLM providers
   - Manages results and reports

2. **Sandbox Container** (runs in Docker)
   - Isolated Kali Linux environment
   - Pre-installed security tools
   - Executes actual testing code
   - Prevents host system impact

## Performance Tips

1. **First run is slow:** Docker image pull and Playwright setup takes time
2. **Use local LLM:** For faster/cheaper testing, use Ollama with llama3.1
3. **Increase Docker resources:** Allocate 4GB+ RAM in Docker settings
4. **Cache images:** Don't delete tygr-sandbox image between tests

## Security Notes

⚠️ **Important:**
- Only test applications you own or have permission to test
- TYGR performs actual security testing that may trigger alerts
- The sandbox isolates testing but network traffic is real
- Review all generated PoCs before using them

## Next Steps

- Read the full [README.md](README.md) for feature details
- Check [CONTRIBUTING.md](CONTRIBUTING.md) for development setup
- Visit [tygrsecurity.com](https://tygrsecurity.com) for cloud hosting
- Join the community: hi@tygrsecurity.com

## Getting Help

If you encounter issues:

1. Check Docker is running: `docker ps`
2. Verify environment variables: `echo $TYGR_LLM`
3. Check logs: `tygr --help` should show version info
4. Review disk space: `docker system df`
5. Open an issue: https://github.com/aderm97/tygr/issues
