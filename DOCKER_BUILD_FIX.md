# Docker Build Fix - export_presets.cfg Not Found

## Issue Summary

When running `docker-compose up --build`, the build was failing with:
```
Error: export_presets.cfg not found!
Please create export_presets.cfg before building Docker image.
exit code: 1
```

## Root Cause

The `export_presets.cfg` file **existed in the repository and was tracked by git**, but the `.dockerignore` file was excluding it from the Docker build context. This meant when Docker tried to COPY files, it skipped `export_presets.cfg`, causing the validation check to fail.

## The Fix

**Changed:** `.dockerignore` line 35

**Before:**
```dockerignore
export_presets.cfg  ← Excluded from Docker builds
```

**After:**
```dockerignore
# Removed - file is now included in Docker builds
# (Only excluded in .dockerignore.ml for ML-service builds)
```

## How to Use Now

### Option 1: Full Docker Build (Now Works!)

```bash
# For Linux with X11
xhost +local:docker
docker-compose up --build
```

The build will now:
1. ✅ Find `export_presets.cfg`
2. ✅ Pass validation check
3. ✅ Export Godot game successfully
4. ✅ Create `/app/neural-aegis.x86_64` executable
5. ✅ Run both ML service and Godot game

### Option 2: ML Service Only (Recommended)

```bash
# Start ML service in Docker
docker-compose -f docker-compose.ml.yml up -d

# Run Godot natively on your machine
godot --path .
```

**Why recommended:**
- Works on Windows, macOS, and Linux
- No X11 configuration needed
- Better graphics performance
- Easier debugging in Godot editor

## Verification

Check if the fix is applied:

```bash
# 1. Verify file exists
ls export_presets.cfg
# Should show: export_presets.cfg

# 2. Check it's NOT excluded in main .dockerignore
grep export_presets.cfg .dockerignore
# Should return only comments, not an exclusion line

# 3. Verify it IS excluded in ML .dockerignore (correct)
grep export_presets.cfg .dockerignore.ml
# Should return: export_presets.cfg
```

## Technical Details

### Docker Build Context

Docker uses `.dockerignore` to determine which files to include when building:

| Build Type | Dockerfile | Dockerignore | Includes export_presets.cfg? |
|------------|-----------|--------------|------------------------------|
| Full App | `Dockerfile` | `.dockerignore` | ✅ YES (after fix) |
| ML Service | `Dockerfile.ml-service` | `.dockerignore.ml` | ❌ NO (not needed) |

### Why Two .dockerignore Files?

- **`.dockerignore`** - Used by default for `Dockerfile` (full app build)
  - Includes Godot files
  - Includes export_presets.cfg
  - Needed for game export

- **`.dockerignore.ml`** - Used with `-f` flag for ML-service only
  - Excludes all Godot files
  - Excludes export_presets.cfg
  - Lighter image (~200MB vs ~1GB)

### Build Flow Comparison

**Before Fix:**
```
1. docker-compose up --build
2. Dockerfile COPY . . (skips export_presets.cfg due to .dockerignore)
3. RUN validation check
4. ❌ Error: export_presets.cfg not found!
5. Build fails
```

**After Fix:**
```
1. docker-compose up --build
2. Dockerfile COPY . . (includes export_presets.cfg)
3. RUN validation check
4. ✅ File found, validation passes
5. Godot export succeeds
6. Game executable created
7. Build succeeds
```

## Troubleshooting

### "export_presets.cfg not found" (still happening?)

```bash
# Pull latest changes
git pull origin main

# Verify .dockerignore doesn't exclude the file
cat .dockerignore | grep -A 2 "export_presets"

# Should see:
# # Note: export_presets.cfg is INCLUDED for full Docker builds
```

### Build succeeds but game won't start

If the build completes but you get "Cannot open display":

```bash
# You need X11 for full Docker mode (Linux only)
xhost +local:docker
export DISPLAY=:0
docker-compose up
```

**Alternative:** Use ML-service-only mode:
```bash
docker-compose -f docker-compose.ml.yml up -d
# Then run Godot natively
```

## Summary

✅ **Problem:** `export_presets.cfg` was being excluded by `.dockerignore`  
✅ **Fix:** Removed the exclusion from `.dockerignore`  
✅ **Result:** Full Docker builds now work correctly  
✅ **Bonus:** ML-service-only builds still work (using `.dockerignore.ml`)

Both deployment options are now fully functional!
