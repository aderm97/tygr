# TYGR Security Platform - Docker Quick Start

## ⚡ Quick Build Commands

### Windows (PowerShell)
```powershell
.\build-docker.ps1
```

### Linux / Mac / Git Bash
```bash
./build-docker.sh
```

### Manual (All Platforms)
```bash
docker build -t tygr-security-platform:latest -f containers/Dockerfile .
```

---

## ✅ Verify Build

```bash
# Check image exists
docker images | grep tygr-security-platform

# Test image
docker run --rm tygr-security-platform:latest echo "✅ Works!"

# Interactive shell
docker run --rm -it tygr-security-platform:latest /bin/bash
```

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker not found | Install Docker Desktop |
| Daemon not running | Start Docker Desktop |
| Build fails | Check internet connection |
| No space left | Run `docker system prune -a` |
| Wrong directory | Navigate to project root |

---

## 📚 Full Documentation

See **DOCKER_BUILD_GUIDE.md** for:
- Detailed build instructions
- Troubleshooting guide
- Advanced options
- Testing procedures

---

## 🐯 After Building

Once the image is built, run TYGR:
```bash
poetry run tygr --target https://example.com
```

The platform will automatically use the `tygr-security-platform:latest` image.
