# Contributing to TYGR Security Platform

Thank you for your interest in contributing to TYGR Security Platform! This guide will help you get started with development and contributions.

## 🚀 Development Setup

### Prerequisites

- Python 3.12+
- Docker (running)
- Poetry (for dependency management)
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/aderm97/tygr.git
   cd tygr
   ```

2. **Install development dependencies**
   ```bash
   make setup-dev

   # or manually:
   poetry install --with=dev
   poetry run pre-commit install
   ```

3. **Configure your LLM provider**
   ```bash
   export TYGR_LLM="openai/gpt-5"
   export LLM_API_KEY="your-api-key"
   ```

4. **Run TYGR in development mode**
   ```bash
   poetry run tygr --target https://example.com
   ```

## 📚 Contributing Prompt Modules

Prompt modules are specialized knowledge packages that enhance agent capabilities. See [tygr/prompts/README.md](tygr/prompts/README.md) for detailed guidelines.

### Quick Guide

1. **Choose the right category** (`/vulnerabilities`, `/frameworks`, `/technologies`, etc.)
2. **Create a** `.jinja` file with your prompts
3. **Include practical examples** - Working payloads, commands, or test cases
4. **Provide validation methods** - How to confirm findings and avoid false positives
5. **Submit via PR** with clear description

## 🔧 Contributing Code

### Pull Request Process

1. **Create an issue first** - Describe the problem or feature
2. **Fork and branch** - Work from the `main` branch
3. **Make your changes** - Follow existing code style
4. **Write/update tests** - Ensure coverage for new features
5. **Run quality checks** - `make check-all` should pass
6. **Submit PR** - Link to issue and provide context

### PR Guidelines

- **Clear description** - Explain what and why
- **Small, focused changes** - One feature/fix per PR
- **Include examples** - Show before/after behavior
- **Update documentation** - If adding features
- **Pass all checks** - Tests, linting, type checking

### Code Style

- Follow PEP 8 with 100-character line limit
- Use type hints for all functions
- Write docstrings for public methods
- Keep functions focused and small
- Use meaningful variable names

## 🐛 Reporting Issues

When reporting bugs, please include:

- Python version and OS
- TYGR Security Platform version
- LLMs being used
- Full error traceback
- Steps to reproduce
- Expected vs actual behavior

## 💡 Feature Requests

We welcome feature ideas! Please:

- Check existing issues first
- Describe the use case clearly
- Explain why it would benefit users
- Consider implementation approach
- Be open to discussion

## 🤝 Community

- **Email**: [hi@tygrsecurity.com](mailto:hi@tygrsecurity.com)
- **Issues**: [GitHub Issues](https://github.com/aderm97/tygr/issues)

## ✨ Recognition

We value all contributions! Contributors will be:
- Listed in release notes
- Thanked in our community
- Added to contributors list (coming soon)

---

**Questions?** Reach out at [hi@tygrsecurity.com](mailto:hi@tygrsecurity.com) or create an issue. We're here to help!
