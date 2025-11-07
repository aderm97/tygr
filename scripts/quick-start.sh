#!/bin/bash
# TYGR Security Platform - Quick Start Script
# Automates the initial setup and runs a test scan

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
  _____ __   __ ____  ____
 |_   _| \ \ / // ___||  _ \
   | |  \ V / | |  _ | |_) |
   | |   | |  | |_| ||  _ <
   |_|   |_|   \____||_| \_\

 TYGR Security Platform
 Quick Start Setup
EOF
echo -e "${NC}"

# Step 1: Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
command -v docker >/dev/null 2>&1 || { echo "Docker not found. Please install Docker first."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "Git not found. Please install Git first."; exit 1; }

# Step 2: Setup environment
if [ ! -f .env ]; then
    echo -e "${BLUE}Setting up environment configuration...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Created .env file. Please edit it with your API keys:"
        echo "  nano .env"
        echo ""
        echo "Required variables:"
        echo "  - TYGR_LLM (e.g., openai/gpt-4o)"
        echo "  - LLM_API_KEY (your API key)"
        echo ""
        echo "Run this script again after configuring .env"
        exit 0
    fi
fi

# Step 3: Build Docker image
echo -e "${BLUE}Building TYGR sandbox Docker image...${NC}"
echo "This may take 15-30 minutes on first build..."
docker build -f containers/Dockerfile -t tygr-sandbox:latest .

# Step 4: Create test directories
echo -e "${BLUE}Creating test workspace...${NC}"
mkdir -p test-workspace agent_runs

# Step 5: Create a simple test case
echo -e "${BLUE}Creating test application...${NC}"
cat > test-workspace/vulnerable-app.py << 'EOF'
"""
Simple vulnerable web application for testing TYGR
WARNING: This is intentionally vulnerable - do not deploy to production!
"""
from flask import Flask, request, render_template_string
import sqlite3

app = Flask(__name__)

@app.route('/')
def index():
    return """
    <h1>Test Application</h1>
    <p><a href="/search?q=test">Search</a></p>
    <p><a href="/user?id=1">User Profile</a></p>
    """

@app.route('/search')
def search():
    query = request.args.get('q', '')
    # Vulnerable to XSS
    return render_template_string(f'<h1>Search Results for: {query}</h1>')

@app.route('/user')
def user():
    user_id = request.args.get('id', '1')
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    # Vulnerable to SQL injection
    cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
    return "User data retrieved"

if __name__ == '__main__':
    app.run(debug=True, port=5000)
EOF

# Step 6: Success message
echo -e "${GREEN}"
echo "========================================="
echo "Setup Complete! 🎉"
echo "========================================="
echo -e "${NC}"
echo ""
echo "To run TYGR:"
echo "  1. Start with Docker Compose: docker compose up -d"
echo "  2. Or install locally: pipx install -e ."
echo ""
echo "Test the setup:"
echo "  ./scripts/test-setup.sh"
echo ""
echo "Run a security scan:"
echo "  tygr --target ./test-workspace"
echo ""
echo "For more information, see DOCKER_SETUP.md"
