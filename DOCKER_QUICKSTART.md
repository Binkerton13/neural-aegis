# Docker Launch Guide - Quick Reference

## The Problem You Had

```bash
docker-compose up --build
```

Result:
```
neural-aegis  | /app/start.sh: line 7: /app/neural-aegis.x86_64: No such file or directory
neural-aegis exited with code 0
```

**Why?** Godot couldn't export the game because `export_presets.cfg` was missing, but the build continued anyway.

## The Solution

### ✅ Recommended: ML Service Only

Run the Python ML backend in Docker, Godot on your machine:

```bash
# Start ML service
docker-compose -f docker-compose.ml.yml up -d

# Verify it's working
curl http://localhost:5000/health
# {"service":"neural-aegis-ml","status":"healthy"}

# Run Godot natively
godot --path .
# Or open in Godot editor and press F5
```

**Why this is better:**
- Works on Windows, macOS, and Linux
- No X11 configuration needed  
- Native graphics performance
- Easier debugging
- Faster Docker builds

### Alternative: Full Docker (Linux Only)

Run everything in Docker (requires X11):

```bash
# Allow Docker to use X server
xhost +local:docker

# Start everything
docker-compose up --build
```

**Requirements:**
- Linux with X11
- `export_presets.cfg` in repository (✅ now included)
- Display server access

## Interactive Setup

Use the helper script:

```bash
./docker-start.sh
```

It will guide you through the options.

## Quick Commands

### ML Service Commands

```bash
# Start
docker-compose -f docker-compose.ml.yml up -d

# Check logs
docker-compose -f docker-compose.ml.yml logs -f

# Stop
docker-compose -f docker-compose.ml.yml down

# Rebuild
docker-compose -f docker-compose.ml.yml up -d --build
```

### Health Checks

```bash
# Check if ML service is running
curl http://localhost:5000/health

# Test isolation forest
curl -X POST http://localhost:5000/isolation_forest \
  -H "Content-Type: application/json" \
  -d '{"data": [15, 20, 18, 45, 19, 22], "contamination": 0.15}'

# Test linear regression
curl -X POST http://localhost:5000/linear_regression \
  -H "Content-Type: application/json" \
  -d '{"data": [10, 12, 14, 16, 18], "forecast_steps": 3}'
```

## Troubleshooting

### "Cannot connect to Docker daemon"

```bash
# Start Docker service
sudo systemctl start docker

# Or on Mac
open -a Docker
```

### Port 5000 already in use

```bash
# Find what's using port 5000
lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use a different port
docker run -p 5001:5000 ...
```

### Container exits immediately

```bash
# Check logs
docker logs neural-aegis-ml

# Run interactively to see errors
docker run -it neural-aegis-ml:latest /bin/bash
```

### "export_presets.cfg not found" during Docker build

This means the file is being excluded from the Docker build context.

```bash
# Verify the file exists
ls export_presets.cfg

# Check if .dockerignore is excluding it (should NOT be excluded)
grep export_presets.cfg .dockerignore

# If found in .dockerignore, remove that line
# The file is needed for full Docker builds
```

**Solution:** Ensure `export_presets.cfg` is NOT listed in `.dockerignore` (it should only be in `.dockerignore.ml` for ML-only builds).

## Files Explanation

| File | Purpose |
|------|---------|
| `Dockerfile` | Full app (Godot + ML) - Linux only |
| `Dockerfile.ml-service` | ML service only - All platforms |
| `docker-compose.yml` | Main compose with both options |
| `docker-compose.ml.yml` | Dedicated ML service compose |
| `export_presets.cfg` | Godot export configuration (needed for full Docker) |
| `docker-start.sh` | Interactive setup script |

## Development Workflow

**Recommended setup:**

1. Start ML service in Docker:
   ```bash
   docker-compose -f docker-compose.ml.yml up -d
   ```

2. Develop in Godot natively:
   - Open Godot editor
   - Make changes to GDScript files
   - Press F5 to test immediately
   - ML service runs consistently in background

3. When done:
   ```bash
   docker-compose -f docker-compose.ml.yml down
   ```

## Full Documentation

See `docs/DOCKER.md` for:
- Complete troubleshooting guide
- Production deployment instructions
- Performance tuning
- Security considerations
- Advanced Docker usage

## Summary

| What You Want | Command |
|---------------|---------|
| **Just play the game** | `docker-compose -f docker-compose.ml.yml up -d` then run Godot |
| **Full Docker (Linux)** | `xhost +local:docker && docker-compose up --build` |
| **Development** | ML service in Docker + Godot natively |
| **Production ML API** | `docker run -d -p 5000:5000 neural-aegis-ml:latest` |

The key insight: **You don't need to run Godot in Docker.** The ML service is the component that benefits most from containerization. Run it in Docker and enjoy native Godot performance on your machine!
