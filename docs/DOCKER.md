# Docker Deployment Guide

## Overview

Neural Aegis can be deployed using Docker in several configurations depending on your needs:

1. **ML Service Only** (Recommended) - Run Python ML backend in Docker, Godot natively
2. **Full Application** - Both Godot and ML service in Docker (requires X11 setup)
3. **Development** - ML service in Docker with live code mounting

## Quick Start

### Option 1: ML Service Only (Recommended)

This is the easiest and most common setup for development and testing:

```bash
# Start just the ML service
docker-compose --profile ml-only up -d ml-service

# Or using the dedicated ML compose file
docker-compose -f docker-compose.ml.yml up -d

# Verify it's running
curl http://localhost:5000/health
```

Then run Godot natively:
```bash
# Open Godot and import the project
godot --path . 
# Or press F5 in Godot editor
```

**Advantages:**
- Simple setup
- No X11 forwarding needed
- Native graphics performance
- Easy debugging in Godot editor

### Option 2: Full Application (Godot + ML in Docker)

Run the entire application in Docker (Linux only, requires X11):

**Prerequisites:**
```bash
# Allow Docker to connect to X server
xhost +local:docker

# Set DISPLAY environment variable if not set
export DISPLAY=:0
```

**Build and Run:**
```bash
docker-compose up --build
```

**Note:** This requires `export_presets.cfg` to be present. If the build fails with "Export failed", the preset file is missing or invalid.

### Option 3: Development with Live Reload

For active development where you want code changes reflected immediately:

```bash
# Start ML service with volume mounting
docker-compose -f docker-compose.dev.yml up
```

This mounts your local code directory into the container, so Python changes are picked up without rebuilding.

## Docker Images

### ML Service Image (Dockerfile.ml-service)

**Based on:** `python:3.11-slim`
**Size:** ~200 MB
**Includes:**
- Python 3.11
- Flask web server
- scikit-learn
- numpy, pandas
- Health check endpoint

**Ports:**
- `5000` - ML service REST API

**Build:**
```bash
docker build -f Dockerfile.ml-service -t neural-aegis-ml:latest .
```

**Run:**
```bash
docker run -d -p 5000:5000 --name neural-aegis-ml neural-aegis-ml:latest
```

### Full Application Image (Dockerfile)

**Based on:** `barichello/godot-ci:4.2.1` (builder) + `ubuntu:22.04` (runtime)
**Size:** ~1.5 GB
**Includes:**
- Godot game exported executable
- Python 3 + ML service
- Graphics libraries (OpenGL, X11)

**Ports:**
- `5000` - ML service REST API
- Requires X11 socket for display

**Build:**
```bash
docker build -t neural-aegis:latest .
```

## Troubleshooting

### "No such file or directory: /app/neural-aegis.x86_64"

**Cause:** Godot export failed during Docker build

**Solutions:**

1. **Missing export_presets.cfg:**
   ```bash
   # Check if file exists
   ls export_presets.cfg
   
   # If missing, it should be in the repository
   git status export_presets.cfg
   
   # IMPORTANT: Check if .dockerignore is excluding it
   grep export_presets.cfg .dockerignore
   # Should NOT find it (file should be included in Docker build)
   ```
   
   **Note:** The `.dockerignore` file should NOT exclude `export_presets.cfg` for full Docker builds. Only `.dockerignore.ml` (for ML-service builds) should exclude it.

2. **Invalid export preset:**
   - Open the project in Godot editor
   - Go to Project → Export
   - Ensure "Linux/X11" preset exists and is configured
   - Export manually to verify: Project → Export → Export Project

3. **Use ML service only instead:**
   ```bash
   docker-compose --profile ml-only up ml-service
   ```

### "Connection refused" on localhost:5000

**Cause:** ML service not running or not accessible

**Solutions:**

1. **Check if container is running:**
   ```bash
   docker ps | grep neural-aegis
   ```

2. **Check container logs:**
   ```bash
   docker logs neural-aegis-ml
   ```

3. **Verify port binding:**
   ```bash
   netstat -an | grep 5000
   lsof -i :5000
   ```

4. **Health check:**
   ```bash
   curl http://localhost:5000/health
   # Should return: {"status": "healthy", "service": "neural-aegis-ml"}
   ```

### X11 Connection Issues (Full Docker)

**Symptoms:**
- "Cannot open display"
- Black screen
- Godot crashes

**Solutions:**

1. **Allow X11 connections:**
   ```bash
   xhost +local:docker
   ```

2. **Check DISPLAY variable:**
   ```bash
   echo $DISPLAY
   # Should be something like :0 or :1
   ```

3. **Verify X11 socket:**
   ```bash
   ls -la /tmp/.X11-unix/
   ```

4. **Alternative: Use VNC or remote display:**
   ```bash
   # Install and use xvfb for headless rendering
   docker run -e DISPLAY=:99 ...
   ```

### Build Fails with "godot: command not found"

**Cause:** Wrong base image or Godot not in PATH

**Solution:**
- Verify you're using `barichello/godot-ci:4.2.1` base image
- Check Dockerfile `FROM` line

### Python Dependencies Installation Failed

**Cause:** Network issues or missing system packages

**Solutions:**

1. **Retry build:**
   ```bash
   docker-compose build --no-cache ml-service
   ```

2. **Check requirements.txt:**
   ```bash
   cat requirements.txt
   ```

3. **Build with verbose output:**
   ```bash
   docker build --progress=plain -f Dockerfile.ml-service .
   ```

## Docker Compose Profiles

### Default (no profile)
Starts the full application (Godot + ML service)

```bash
docker-compose up
```

### ml-only Profile
Starts only the ML service

```bash
docker-compose --profile ml-only up ml-service
```

### Available Services

| Service | Description | Ports | Profile |
|---------|-------------|-------|---------|
| `neural-aegis` | Full app (Godot + ML) | 5000 (host network) | default |
| `ml-service` | ML service only | 5000:5000 | ml-only |

## Environment Variables

### Required
- `DISPLAY` - X11 display (for full Docker app) - Default: `:0`

### Optional
- `FLASK_ENV` - Flask environment - Default: `production`
- `ML_SERVICE_PORT` - ML service port - Default: `5000`

Example:
```bash
DISPLAY=:1 docker-compose up
```

## Performance Considerations

### ML Service Container
- **Memory:** ~200 MB base + ~100 MB per concurrent request
- **CPU:** Minimal when idle, spikes during ML analysis
- **Network:** localhost only, negligible latency

### Full Application Container
- **Memory:** ~500 MB base + Godot runtime (~200 MB)
- **CPU:** Depends on game activity and ML usage
- **GPU:** Uses host GPU via X11 (software rendering fallback)

## Production Deployment

⚠️ **The current setup is for development only!**

For production:

1. **Use production WSGI server:**
   ```dockerfile
   # Replace Flask dev server with Gunicorn
   RUN pip install gunicorn
   CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "ml_service:app"]
   ```

2. **Add HTTPS:**
   - Use reverse proxy (nginx, traefik)
   - SSL/TLS certificates

3. **Security hardening:**
   - Non-root user in container
   - Read-only filesystem where possible
   - Security scanning (trivy, clair)

4. **Resource limits:**
   ```yaml
   services:
     ml-service:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 1G
           reservations:
             cpus: '0.5'
             memory: 512M
   ```

5. **Monitoring:**
   - Add Prometheus metrics
   - Health check endpoints
   - Log aggregation

## Advanced Usage

### Build with Custom Tags

```bash
# Build ML service with version tag
docker build -f Dockerfile.ml-service -t neural-aegis-ml:1.0.0 .

# Build full app with commit hash
docker build -t neural-aegis:$(git rev-parse --short HEAD) .
```

### Multi-Architecture Builds

```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  -f Dockerfile.ml-service \
  -t neural-aegis-ml:latest .
```

### Use Docker Hub

```bash
# Tag for Docker Hub
docker tag neural-aegis-ml:latest username/neural-aegis-ml:latest

# Push to registry
docker push username/neural-aegis-ml:latest

# Pull and run
docker run -d -p 5000:5000 username/neural-aegis-ml:latest
```

### Kubernetes Deployment

See `docs/kubernetes/` for Kubernetes manifests (coming soon).

## Cleanup

```bash
# Stop containers
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Remove images
docker rmi neural-aegis neural-aegis-ml

# Full cleanup (all unused Docker resources)
docker system prune -a
```

## Getting Help

If you encounter issues:

1. Check container logs: `docker logs neural-aegis-ml`
2. Inspect container: `docker inspect neural-aegis-ml`
3. Test ML service: `curl http://localhost:5000/health`
4. Open an issue: [GitHub Issues](https://github.com/Binkerton13/neural-aegis/issues)

## Summary of Commands

```bash
# Recommended: ML service only
docker-compose -f docker-compose.ml.yml up -d

# Or with profiles
docker-compose --profile ml-only up -d ml-service

# Full application (Linux + X11 only)
xhost +local:docker
docker-compose up --build

# Check status
docker ps
docker logs neural-aegis-ml
curl http://localhost:5000/health

# Stop everything
docker-compose down
```
