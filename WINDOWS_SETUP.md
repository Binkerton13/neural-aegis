# Windows Setup Guide for Neural Aegis

This guide provides step-by-step instructions specifically for Windows users.

## Prerequisites

- **Windows 10 or 11**
- **Docker Desktop for Windows** (optional, for ML service)
- **Python 3.8+** (optional, for ML service)
- **Godot 4.2+** (required to run the game)

## Quick Start (Recommended Path)

### Step 1: Install Docker Desktop (Optional but Recommended)

1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/)
2. Install and restart your computer if prompted
3. Start Docker Desktop
4. Wait for it to fully start (whale icon in system tray should be steady)

### Step 2: Install Godot

**Option A: Download from Official Site**

1. Visit [godotengine.org/download](https://godotengine.org/download)
2. Click "Download" for Windows
3. Extract the `.zip` file to a permanent location like:
   - `C:\Godot\`
   - `C:\Program Files\Godot\`
   - Or anywhere you prefer
4. The executable will be named something like `Godot_v4.2-stable_win64.exe`

**Option B: Install via Steam**

1. Open Steam
2. Search for "Godot Engine"
3. Install it (it's free)
4. Default location: `C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\`
5. Executable: `godot.windows.opt.tools.64.exe`

### Step 3: Clone the Repository

Open PowerShell and run:

```powershell
# Navigate to where you want the project
cd C:\path\to\your\projects

# Clone the repository
git clone https://github.com/Binkerton13/neural-aegis.git
cd neural-aegis
```

### Step 4: Start the ML Service (Optional but Recommended)

Open PowerShell in the project directory:

```powershell
# Start the ML service in Docker
docker-compose -f docker-compose.ml.yml up -d

# Verify it's running
Invoke-WebRequest http://localhost:5000/health
```

You should see: `{"service":"neural-aegis-ml","status":"healthy"}`

### Step 5: Run Godot

**Option A: Using the GUI (Easiest)**

1. Double-click your Godot executable
2. Click "Import"
3. Click "Browse" and navigate to the `neural-aegis` folder
4. Select the `project.godot` file
5. Click "Import & Edit"
6. Press **F5** to run the game

**Option B: Using PowerShell**

```powershell
# Navigate to the project directory
cd C:\path\to\neural-aegis

# Run with full path to Godot
& "C:\Path\To\Godot\Godot_v4.2-stable_win64.exe" --path .

# Example with Steam installation:
& "C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --path .
```

## Alternative: Run ML Service Without Docker

If you prefer not to use Docker:

### 1. Install Python

1. Download Python 3.8+ from [python.org](https://www.python.org/downloads/)
2. **Important**: Check "Add Python to PATH" during installation
3. Verify installation:
   ```powershell
   python --version
   ```

### 2. Set Up Virtual Environment

```powershell
# Navigate to project directory
cd neural-aegis

# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\Activate.ps1

# If you get a script execution error, run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then try activating again
```

### 3. Install Dependencies and Start ML Service

```powershell
# Install requirements
pip install -r requirements.txt

# Start the ML service
python ml_service.py
```

The service will run on `http://localhost:5000`

### 4. Run Godot (in a separate PowerShell window)

Follow Step 5 from the Quick Start above.

## Common Issues and Solutions

### Issue: "godot is not recognized as a command"

**Cause:** Godot is not in your PATH.

**Solutions:**

1. **Use the full path (Quick Fix):**
   ```powershell
   & "C:\Full\Path\To\godot.exe" --path .
   ```

2. **Add Godot to PATH (Permanent Fix):**
   - Press `Windows + X`, select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New"
   - Add the folder containing `godot.exe` (e.g., `C:\Godot\`)
   - Click OK on all windows
   - **Restart PowerShell**
   - Now `godot --path .` should work

3. **Just use the GUI (Easiest):**
   - Double-click `godot.exe` and import the project

### Issue: "docker-compose: command not found"

**Cause:** Docker Desktop is not installed or not running.

**Solution:**
1. Install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/)
2. Start Docker Desktop
3. Wait for the whale icon in the system tray to be steady (not animating)
4. Try the command again

### Issue: "Cannot connect to the Docker daemon"

**Cause:** Docker Desktop is not running.

**Solution:**
1. Start Docker Desktop
2. Wait for it to fully initialize
3. Try again

### Issue: "Found orphan containers" warning

**Cause:** Previous containers from an old configuration exist.

**Solution:**
```powershell
# This is just a warning, but you can clean it up:
docker-compose -f docker-compose.ml.yml up -d --remove-orphans
```

### Issue: Port 5000 already in use

**Cause:** Another application is using port 5000.

**Solution:**

1. Find what's using the port:
   ```powershell
   netstat -ano | findstr :5000
   ```

2. Stop that application, or modify `docker-compose.ml.yml` to use a different port:
   ```yaml
   ports:
     - "5001:5000"  # Use port 5001 instead
   ```

### Issue: Python virtual environment activation error

**Error Message:**
```
cannot be loaded because running scripts is disabled on this system
```

**Solution:**
```powershell
# Run as Administrator or with your user account:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then try activating again:
.\venv\Scripts\Activate.ps1
```

### Issue: Git clone fails with "Failed to connect to github.com"

**Cause:** Network connectivity issues, firewall, or proxy.

**Solutions:**

1. **Check your internet connection**

2. **Try using SSH instead:**
   ```powershell
   git clone git@github.com:Binkerton13/neural-aegis.git
   ```

3. **Configure proxy if needed:**
   ```powershell
   git config --global http.proxy http://proxy.example.com:8080
   ```

4. **Download ZIP as fallback:**
   - Visit https://github.com/Binkerton13/neural-aegis
   - Click "Code" → "Download ZIP"
   - Extract to your desired location

## Testing Your Setup

Once everything is set up:

1. **Test ML Service:**
   ```powershell
   Invoke-WebRequest http://localhost:5000/health
   ```
   Should return: `{"service":"neural-aegis-ml","status":"healthy"}`

2. **Run the game:**
   - Launch Godot with the project
   - Press F5
   - You should see the game window with scrolling logs
   - Try clicking the tool buttons on the left

3. **Verify ML integration:**
   - Click the "Linear Regression" or "Isolation Forest" buttons
   - If working, you'll see analysis results in the status bar
   - If not connected, you'll see "ML service not available" messages

## Performance Tips

- **Close unnecessary applications** while running to free up RAM
- **Docker Desktop** can be memory-intensive; allocate at least 2GB in Docker settings
- **Godot** runs well on modest hardware; no GPU required
- If performance is poor, try closing Docker Desktop and running just Godot without the ML service

## Getting Help

If you're still having issues:

1. Check the main [README.md](README.md)
2. Review [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md)
3. Search existing [GitHub Issues](https://github.com/Binkerton13/neural-aegis/issues)
4. Create a new issue with:
   - Your Windows version
   - Godot version
   - Docker version (if using)
   - Complete error messages
   - Steps you've already tried

## Next Steps

Once you have the game running:

- Read [docs/QUICKSTART.md](docs/QUICKSTART.md) to learn how to play
- Explore [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) to understand the design
- Check out [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) to add your own features

---

**Note:** This guide assumes you're using PowerShell (recommended). If you're using Command Prompt (cmd.exe), some commands may differ slightly:
- Replace `.\venv\Scripts\Activate.ps1` with `venv\Scripts\activate.bat`
- Replace `&` with nothing when running executables
- Example: `"C:\Path\To\godot.exe" --path .`
