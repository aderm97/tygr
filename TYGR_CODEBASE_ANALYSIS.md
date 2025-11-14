# TYGR Security Platform - Codebase Analysis

**Analysis Date**: 2025-11-14
**Purpose**: Foundation for building TYGR Security Agent Web UI

---

## 📋 Executive Summary

TYGR Security Platform is an AI-powered autonomous security testing tool that uses multi-agent collaboration to perform comprehensive vulnerability assessments. The platform operates through a CLI that orchestrates Docker-based security testing agents with various specialized tools.

---

## 🏗️ Architecture Overview

### Core Components

1. **CLI Interface** (`tygr/interface/`)
   - Entry point: `tygr.interface.main:main`
   - Two modes: Interactive TUI (`tui.py`) and Non-interactive CLI (`cli.py`)
   - Argument parsing, validation, and environment setup

2. **Agent System** (`tygr/agents/`)
   - `TygrAgent`: Main orchestrating agent
   - `base_agent.py`: Base agent functionality
   - `state.py`: Agent state management
   - Multi-agent collaboration and workflow distribution

3. **Runtime Environment** (`tygr/runtime/`)
   - `docker_runtime.py`: Docker container orchestration
   - `runtime.py`: Core runtime logic
   - `tool_server.py`: FastAPI-based tool server
   - Sandboxed execution environment

4. **LLM Integration** (`tygr/llm/`)
   - LiteLLM-based model interaction
   - Support for multiple providers (OpenAI, Anthropic, local models)
   - Configuration via `LLMConfig`

5. **Tools** (`tygr/tools/`)
   - HTTP Proxy
   - Browser automation
   - Terminal environments
   - Python runtime
   - Web search
   - File editing
   - Reconnaissance

6. **Telemetry & Reporting** (`tygr/telemetry/`)
   - `tracer.py`: Scan tracking and reporting
   - Real-time vulnerability callbacks
   - Structured output generation

---

## 🎯 CLI Interface Analysis

### Command Structure

```bash
tygr [OPTIONS]
```

### Required Arguments

| Argument | Type | Description |
|----------|------|-------------|
| `-t, --target` | String (multi) | Target URL, repository, local path, or domain. Can be specified multiple times |

### Optional Arguments

| Argument | Type | Description |
|----------|------|-------------|
| `--instruction` | String | Custom testing instructions (focus areas, credentials, specific vulnerabilities) |
| `--run-name` | String | Custom name for the scan run |
| `-n, --non-interactive` | Flag | Run in headless mode (exits on completion) |

### Environment Variables

#### Required
- `TYGR_LLM`: Model name (e.g., `openai/gpt-5`, `anthropic/claude-3-5-sonnet`)
- `LLM_API_KEY`: API key for cloud LLM providers (optional for local models)

#### Optional
- `LLM_API_BASE`: Custom API base URL (for Ollama, LMStudio, etc.)
- `OPENAI_API_BASE`: OpenAI-specific base URL
- `LITELLM_BASE_URL`: LiteLLM proxy URL
- `OLLAMA_API_BASE`: Ollama-specific base URL
- `PERPLEXITY_API_KEY`: For web search capabilities

### Target Types

The CLI automatically infers target types:

1. **URL** (`https://example.com`)
2. **Repository** (`https://github.com/user/repo`, `git@github.com:user/repo.git`)
3. **Local Directory** (`./path/to/code`)
4. **Domain** (`example.com`)

### Multi-Target Support

Users can specify multiple targets for comprehensive testing:
```bash
tygr -t https://github.com/org/app -t https://staging.app.com -t https://prod.app.com
```

---

## 📊 Scan Lifecycle

### 1. Initialization Phase
```python
# Parse arguments
args = parse_arguments()

# Validate environment
validate_environment()  # Check TYGR_LLM, LLM_API_KEY

# Check Docker
check_docker_installed()
check_docker_connection()
pull_docker_image()  # First run only

# Warm up LLM
warm_up_llm()  # Test connection
```

### 2. Preparation Phase
```python
# Generate run name
run_name = generate_run_name()  # e.g., "festive-owl-2024-11-14"

# Clone repositories (if needed)
for target in targets:
    if target_type == "repository":
        cloned_path = clone_repository(url, run_name, dest)

# Collect local sources
local_sources = collect_local_sources(targets_info)
```

### 3. Execution Phase
```python
scan_config = {
    "scan_id": run_name,
    "targets": targets_info,
    "user_instructions": instruction,
    "run_name": run_name
}

agent_config = {
    "llm_config": LLMConfig(),
    "max_iterations": 300,
    "non_interactive": is_headless,
    "local_sources": local_sources
}

# Create tracer for telemetry
tracer = Tracer(run_name)

# Execute scan
agent = TygrAgent(agent_config)
result = await agent.execute_scan(scan_config)
```

### 4. Output Phase
```python
# Results saved to:
results_path = Path("agent_runs") / run_name

# Directory structure:
# agent_runs/
#   └── festive-owl-2024-11-14/
#       ├── vulnerabilities/
#       ├── logs/
#       ├── artifacts/
#       └── final_report.md
```

---

## 🔍 Real-Time Event Streaming

### Vulnerability Callbacks

The tracer supports real-time vulnerability detection:

```python
def display_vulnerability(report_id, title, content, severity):
    # Called when vulnerability found
    pass

tracer.vulnerability_found_callback = display_vulnerability
```

### Available Events

1. **Vulnerability Found**: New security issue detected
2. **Agent State Change**: Agent status updates
3. **Tool Execution**: Individual tool usage
4. **LLM Calls**: Model interactions and token usage
5. **Scan Progress**: Overall scan completion percentage

---

## 🛠️ Agent Tools

### Available Tools (from `tygr/tools/`)

1. **HTTP Proxy** - Request/response manipulation
2. **Browser** - Multi-tab browser automation
3. **Terminal** - Interactive shell execution
4. **Python** - Custom exploit development
5. **Web Search** - OSINT and reconnaissance
6. **File Edit** - Code analysis and modification
7. **Notes** - Knowledge management
8. **Reporting** - Structured finding documentation

---

## 📦 Docker Runtime

### Image
- **Name**: `ghcr.io/aderm97/tygr-sandbox:latest`
- **Purpose**: Isolated security testing environment
- **Features**: Full security toolkit, networking, browser support

### Container Lifecycle
1. Pull image (first run)
2. Create container with mounted volumes
3. Execute agent within sandbox
4. Collect results
5. Cleanup on completion

---

## 🎨 TUI Components

The existing TUI (`tui.py`) provides:
- Real-time log display with ANSI colors
- Vulnerability panels as they're found
- Agent activity visualization
- Progress indicators

**UI Components to adapt for web**:
- `tool_components/`: Renderers for each tool type
- Live streaming logs
- Vulnerability cards
- Agent collaboration graph

---

## 💾 Output Structure

### agent_runs/<run-name>/

```
agent_runs/festive-owl-2024-11-14/
├── config.json              # Scan configuration
├── vulnerabilities/         # Individual vulnerability reports
│   ├── sqli-001.md
│   ├── xss-002.md
│   └── ...
├── logs/                    # Execution logs
│   ├── agent.log
│   ├── llm.log
│   └── tools.log
├── artifacts/               # PoCs, screenshots, payloads
│   ├── poc_sqli_001.py
│   ├── screenshot_xss.png
│   └── ...
├── telemetry.json           # Metrics and statistics
└── final_report.md          # Comprehensive summary
```

---

## 🔧 Configuration System

### Current Configuration
- Environment variables only
- No persistent configuration
- Validated at startup

### Requirements for Web UI
- Persistent configuration storage
- Multiple LLM provider profiles
- Target presets and templates
- Credential management
- Scan history database

---

## 🌐 API Integration Points for Web UI

### 1. Process Management
```typescript
POST /api/scans/start
GET  /api/scans/:id/status
GET  /api/scans/:id/logs (SSE)
POST /api/scans/:id/cancel
```

### 2. Configuration
```typescript
GET  /api/config
POST /api/config
GET  /api/config/validate
```

### 3. Results
```typescript
GET  /api/scans
GET  /api/scans/:id
GET  /api/scans/:id/vulnerabilities
GET  /api/scans/:id/export
```

### 4. Real-Time Events
```typescript
GET /api/scans/:id/stream (SSE)
Events:
  - vulnerability_found
  - agent_state_change
  - tool_execution
  - scan_progress
  - scan_complete
```

---

## 🎯 Key Insights for Web UI

### 1. **Process Spawning**
The web UI will spawn TYGR CLI as a subprocess:
```typescript
import { spawn } from 'child_process'

const process = spawn('tygr', [
  '-n',  // non-interactive
  '--target', target,
  '--instruction', instruction,
  '--run-name', runName
], {
  env: {
    ...process.env,
    TYGR_LLM: config.llm,
    LLM_API_KEY: config.apiKey,
    LLM_API_BASE: config.apiBase
  }
})
```

### 2. **Real-Time Streaming**
Parse stdout for structured events:
- JSON-formatted vulnerability reports
- Progress indicators
- Agent state changes

### 3. **Results Parsing**
Read from `agent_runs/<run-name>/`:
- Parse markdown reports
- Extract vulnerability data
- Display artifacts (PoCs, screenshots)

### 4. **Multi-Scan Management**
Support concurrent scans with:
- Job queue (BullMQ)
- Resource limits
- Scan prioritization

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation ✅
- [x] Analyze codebase architecture
- [x] Document CLI interface
- [x] Map data flows

### Phase 2: Core Infrastructure
- [ ] Next.js project setup
- [ ] API routes for process management
- [ ] Database schema for scan history
- [ ] Configuration management system

### Phase 3: Mission Control Dashboard
- [ ] Scan overview grid
- [ ] Real-time log streaming
- [ ] Quick action buttons
- [ ] Metrics visualization

### Phase 4: Hunt Configuration
- [ ] Multi-step wizard
- [ ] Target validation
- [ ] Profile presets
- [ ] Credential management

### Phase 5: Live Monitor
- [ ] Agent activity graph
- [ ] Terminal emulator
- [ ] Vulnerability feed
- [ ] Resource monitoring

### Phase 6: Intelligence Center
- [ ] Vulnerability table
- [ ] Attack graph visualization
- [ ] Code diff viewer
- [ ] Export capabilities

### Phase 7: Settings & Knowledge Base
- [ ] Provider configuration
- [ ] Scan history browser
- [ ] Vulnerability library
- [ ] Documentation

---

## 📝 Notes

- **Exit Codes**: Non-zero (2) when vulnerabilities found in headless mode
- **Docker Required**: All scans require Docker daemon
- **First Run**: Image pull can take several minutes
- **Credentials**: Support injection via `--instruction` parameter
- **Multi-Target**: White-box testing (source + deployed app)

---

## 🎨 Branding Guidelines

### TYGR Brand Identity
- **Primary Colors**: Tiger orange (#FF6B35), Black (#000000)
- **Secondary**: Deep gray (#2d3748), White (#ffffff)
- **Accent**: Cyan (#00d9ff), Green (#10b981), Red (#ef4444)
- **Emoji**: 🐯 (tiger), 🛡️ (shield), 🔍 (magnifying glass)
- **Typography**: Modern, security-focused (Inter, JetBrains Mono for code)
- **Voice**: Professional, powerful, precise

---

**End of Analysis**
