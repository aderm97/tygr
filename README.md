<p align="center">
  <a href="https://tygrsecurity.com/">
    <img src=".github/logo.png" width="150" alt="TYGR Security Platform Logo">
  </a>
</p>

<h1 align="center">
TYGR Security Platform
</h1>

<h2 align="center">AI-Powered Security Testing & Vulnerability Assessment</h2>

<div align="center">

[![Python](https://img.shields.io/pypi/pyversions/tygr-agent?color=3776AB)](https://pypi.org/project/tygr-agent/)
[![PyPI](https://img.shields.io/pypi/v/tygr-agent?color=10b981)](https://pypi.org/project/tygr-agent/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

[![GitHub Stars](https://img.shields.io/github/stars/aderm97/tygr)](https://github.com/aderm97/tygr)
[![Website](https://img.shields.io/badge/Website-tygrsecurity.com-2d3748.svg)](https://tygrsecurity.com)

</div>

:star: _Love TYGR? Give us a star to help other developers discover it!_

<br />

<div align="center">
<img src=".github/screenshot.png" alt="TYGR Security Platform Demo" width="800" style="border-radius: 16px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3), 0 0 0 1px rgba(255, 255, 255, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.2); transform: perspective(1000px) rotateX(2deg); transition: transform 0.3s ease;">
</div>

> [!TIP]
> **New!** TYGR Security Platform now integrates seamlessly with GitHub Actions and CI/CD pipelines. Automatically scan for vulnerabilities on every pull request and block insecure code before it reaches production!

---

## 🐯 TYGR Security Platform Overview

TYGR Security Platform features autonomous AI agents that act just like real security professionals - they run your code dynamically, find vulnerabilities, and validate them through actual proof-of-concepts. Built for developers and security teams who need fast, accurate security testing without the overhead of manual pentesting or the false positives of static analysis tools.

- **Full security toolkit** out of the box
- **Teams of AI agents** that collaborate and scale
- **Real validation** with PoCs, not false positives
- **Developer‑first** CLI with actionable reports
- **Auto‑fix & reporting** to accelerate remediation

---

### 🎯 Use Cases

- Detect and validate critical vulnerabilities in your applications.
- Get penetration tests done in hours, not weeks, with compliance reports.
- Automate security research and generate PoCs for faster reporting.
- Run tests in CI/CD to block vulnerabilities before reaching production.

---

### 🚀 Quick Start

Prerequisites:
- Docker (running)
- Python 3.12+
- An LLM provider key (or a local LLM)

```bash
# Install
pipx install tygr-agent

# Configure AI provider (OpenAI or Anthropic/Claude)
export TYGR_LLM="openai/gpt-5"  # or "anthropic/claude-sonnet-4-5"
export LLM_API_KEY="your-api-key"

# Run security assessment
tygr --target ./app-directory
```

First run pulls the sandbox Docker image. Results are saved under `agent_runs/<run-name>`.

### ☁️ Cloud Hosted

Want to skip the setup? Try our cloud-hosted version: **[tygrsecurity.com](https://tygrsecurity.com)**

## ✨ Features

### 🛠️ Agentic Security Tools

- **🔌 Full HTTP Proxy** - Full request/response manipulation and analysis
- **🌐 Browser Automation** - Multi-tab browser for testing of XSS, CSRF, auth flows
- **💻 Terminal Environments** - Interactive shells for command execution and testing
- **🐍 Python Runtime** - Custom exploit development and validation
- **🔍 Reconnaissance** - Automated OSINT and attack surface mapping
- **📁 Code Analysis** - Static and dynamic analysis capabilities
- **📝 Knowledge Management** - Structured findings and attack documentation

### 🎯 Comprehensive Vulnerability Detection

- **Access Control** - IDOR, privilege escalation, auth bypass
- **Injection Attacks** - SQL, NoSQL, command injection
- **Server-Side** - SSRF, XXE, deserialization flaws
- **Client-Side** - XSS, prototype pollution, DOM vulnerabilities
- **Business Logic** - Race conditions, workflow manipulation
- **Authentication** - JWT vulnerabilities, session management
- **Infrastructure** - Misconfigurations, exposed services

### 🕸️ Graph of Agents

- **Distributed Workflows** - Specialized agents for different attacks and assets
- **Scalable Testing** - Parallel execution for fast comprehensive coverage
- **Dynamic Coordination** - Agents collaborate and share discoveries


## 💻 Usage Examples

```bash
# Local codebase analysis
tygr --target ./app-directory

# Repository security review
tygr --target https://github.com/org/repo

# Web application assessment
tygr --target https://your-app.com

# Multi-target white-box testing (source code + deployed app)
tygr -t https://github.com/org/app -t https://your-app.com

# Test multiple environments simultaneously
tygr -t https://dev.your-app.com -t https://staging.your-app.com -t https://prod.your-app.com

# Focused testing with instructions
tygr --target api.your-app.com --instruction "Prioritize authentication and authorization testing"

# Testing with credentials
tygr --target https://your-app.com --instruction "Test with credentials: testuser/testpass. Focus on privilege escalation and access control bypasses."
```

### ⚙️ Configuration

#### OpenAI (Default)
```bash
export TYGR_LLM="openai/gpt-5"
export LLM_API_KEY="your-openai-api-key"
```

#### Anthropic Claude (Recommended)
```bash
export TYGR_LLM="anthropic/claude-sonnet-4-5"
export LLM_API_KEY="your-anthropic-api-key"
```

**Supported Claude models:**
- `anthropic/claude-sonnet-4-5` - Latest Sonnet 4.5 (best performance)
- `anthropic/claude-3-5-sonnet-20241022` - Specific version
- `anthropic/claude-3-opus-20240229` - Most capable model
- `anthropic/claude-3-haiku-20240307` - Fastest & most cost-effective

**Claude Features:**
- ✅ Automatic prompt caching for reduced costs
- ✅ Optimized for security testing workloads
- ✅ Get your API key: [console.anthropic.com](https://console.anthropic.com/)

#### Local Models (Ollama, LMStudio)
```bash
export TYGR_LLM="openai/gpt-5"  # or any model identifier
export LLM_API_KEY="dummy-key"  # required but not used
export LLM_API_BASE="http://localhost:11434"  # Ollama default
```

#### Optional Settings
```bash
export PERPLEXITY_API_KEY="your-api-key"  # for enhanced search capabilities
```

[📚 View all supported AI models](https://docs.litellm.ai/docs/providers)

### 🤖 Headless Mode

Run TYGR programmatically without interactive UI using the `-n/--non-interactive` flag—perfect for servers and automated jobs. The CLI prints real-time vulnerability findings and the final report before exiting. Exits with non-zero code when vulnerabilities are found.

```bash
tygr -n --target https://your-app.com --instruction "Focus on authentication and authorization vulnerabilities"
```

### 🔄 CI/CD (GitHub Actions)

TYGR Security Platform can be added to your pipeline to run a security test on pull requests with a lightweight GitHub Actions workflow:

```yaml
name: tygr-security-scan

on:
  pull_request:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install TYGR
        run: pipx install tygr-agent

      - name: Run TYGR Security Scan
        env:
          TYGR_LLM: ${{ secrets.TYGR_LLM }}
          LLM_API_KEY: ${{ secrets.LLM_API_KEY }}

        run: tygr -n -t ./
```

## 🏆 Enterprise Platform

Our managed platform provides:

- **📈 Executive Dashboards**
- **🧠 Custom Fine-Tuned Models**
- **⚙️ CI/CD Integration**
- **🔍 Large-Scale Scanning**
- **🔌 Third-Party Integrations**
- **🎯 Enterprise Support**

[**Get Enterprise Demo →**](https://tygrsecurity.com)

## 🔒 Security Architecture

- **Container Isolation** - All testing in sandboxed Docker environments
- **Local Processing** - Testing runs locally, no data sent to external services

> [!WARNING]
> Only test systems you own or have permission to test. You are responsible for using TYGR Security Platform ethically and legally.

## 🤝 Contributing

We welcome contributions from the community! There are several ways to contribute:

### Code Contributions
See our [Contributing Guide](CONTRIBUTING.md) for details on:
- Setting up your development environment
- Running tests and quality checks
- Submitting pull requests
- Code style guidelines

### Prompt Modules Collection
Help expand our collection of specialized prompt modules for AI agents:
- Advanced testing techniques for vulnerabilities, frameworks, and technologies
- See [Prompt Modules Documentation](tygr/prompts/README.md) for guidelines
- Submit via [pull requests](https://github.com/aderm97/tygr/pulls) or [issues](https://github.com/aderm97/tygr/issues)

## 🌟 Support the Project

**Love TYGR Security Platform?** Give us a ⭐ on GitHub!

## 👥 Join Our Community

Have questions? Found a bug? Want to contribute? **Contact us at [hi@tygrsecurity.com](mailto:hi@tygrsecurity.com)**

</div>
