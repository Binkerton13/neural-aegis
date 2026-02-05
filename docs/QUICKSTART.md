# Quick Start Guide

## Running with Docker (Recommended)

### Prerequisites
- Docker and Docker Compose installed
- X11 server (Linux) or XQuartz (macOS) for display

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/Binkerton13/neural-aegis.git
   cd neural-aegis
   ```

2. Build and run:
   ```bash
   docker-compose up --build
   ```

3. The game window should appear automatically

### Troubleshooting Docker

**Issue: Display not working**
```bash
# Linux: Allow X11 connections
xhost +local:docker

# macOS: Install and start XQuartz
brew install xquartz
open -a XQuartz
# In XQuartz preferences, enable "Allow connections from network clients"
```

**Issue: Build fails**
- Ensure you have adequate disk space (>2GB)
- Try pulling the base image manually: `docker pull barichello/godot-ci:4.2.1`

## Running Natively

### Requirements
- Godot 4.2 or higher - Download from [godotengine.org](https://godotengine.org/download)

### Steps

1. **Download and install Godot:**
   - Visit [godotengine.org/download](https://godotengine.org/download)
   - Download Godot 4.2+ for your platform
   - Extract the archive to a location you can access

2. **Clone the project:**
   ```bash
   git clone https://github.com/Binkerton13/neural-aegis.git
   cd neural-aegis
   ```

3. **Launch Godot:**

   **Option A - Using Godot GUI (Easiest):**
   - Double-click the Godot executable
   - Click "Import"
   - Navigate to the project folder and select `project.godot`
   - Click "Import & Edit"
   - Press **F5** (or click the play button) to run

   **Option B - Command Line (Windows):**
   ```powershell
   # Use the full path to your Godot executable
   & "C:\Path\To\Godot\godot.exe" --path "C:\path\to\neural-aegis"
   
   # Example with Steam installation:
   & "C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --path "C:\path\to\neural-aegis"
   ```

   **Option C - Command Line (Linux/macOS):**
   ```bash
   # If Godot is in your PATH:
   godot --path /path/to/neural-aegis
   
   # Or with full path:
   /path/to/godot --path /path/to/neural-aegis
   ```

## Development Mode

For active development with hot reload:

```bash
# Start development container
docker-compose -f docker-compose.dev.yml up -d

# Enter container
docker exec -it neural-aegis-dev bash

# Run Godot editor (if X11 forwarding is configured)
godot --editor
```

## First Steps

1. **The log viewer will start scrolling automatically** with simulated events
2. **Select a theme** from the dropdown in the top bar:
   - Forest Critters (default)
   - Cyberpunk
   - Wizards & Warriors
3. **Watch for patterns** in the logs:
   - White = Normal activity
   - Yellow = Warnings
   - Red = Alerts/Anomalies
4. **Deploy tools** by clicking the buttons in the left panel
5. **Observe results** in the status bar at the bottom

## Controls

- **Tool Buttons** - Click to deploy an analyst tool
- **Theme Dropdown** - Switch between narrative themes
- **Log Auto-scroll** - Automatically follows new log entries

## Understanding the Tools

### Linear Regression (Cooldown: 8s, Cost: 10)
Analyzes trends in resource collection patterns. Use when you want to predict future behavior.

### Isolation Forest (Cooldown: 10s, Cost: 15)
Detects anomalous entities based on behavior outliers. Use when you see unusual activity.

### Honeypot (Cooldown: 15s, Cost: 20)
Deploys decoy resources to attract threats. Most effective but highest cost.

### Trace (Cooldown: 6s, Cost: 8)
Tracks communication patterns between entities. Use to map threat networks.

### Snare (Cooldown: 12s, Cost: 12)
Sets automated traps for specific threat types. Reactive defense mechanism.

## Tips for New Players

1. **Monitor your resources** - Tools consume resources, shown in the top-right
2. **Watch for ALERT messages** - These indicate high-priority threats
3. **Use tools strategically** - Each has a cooldown period
4. **Switch themes** - Different themes help reinforce the underlying security concepts
5. **Read tool tooltips** - Hover over tools to see their real-world equivalents

## Next Steps

- Read the [Architecture](ARCHITECTURE.md) to understand how the game works
- Check [DEVELOPMENT.md](DEVELOPMENT.md) to learn how to add new tools or themes
- Review [CONTRIBUTING.md](CONTRIBUTING.md) to contribute to the project

## Getting Help

- Check existing [GitHub Issues](https://github.com/Binkerton13/neural-aegis/issues)
- Create a new issue using the [bug report template](../.github/ISSUE_TEMPLATE/bug_report.md)
- Review the [FAQ section](#faq) below

## FAQ

**Q: Can I run this without Docker?**
A: Yes! Just download Godot 4.2+ and open the project.

**Q: "godot is not recognized" on Windows - what do I do?**
A: This means Godot is not in your PATH. You have three options:
   1. Use the full path: `& "C:\Path\To\godot.exe" --path .`
   2. Add Godot to your PATH (see Windows Setup section)
   3. Just double-click the Godot executable and import the project through the GUI

**Q: Where is Godot installed if I got it from Steam?**
A: Common Steam paths:
   - `C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`
   - `C:\Program Files\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

**Q: What if I don't have a GPU?**
A: Godot works fine with CPU rendering. The game is not graphically intensive.

**Q: Can I modify the themes?**
A: Absolutely! Edit `data/themes.json` and restart the game.

**Q: How do I add my own tool?**
A: See [DEVELOPMENT.md](DEVELOPMENT.md#adding-a-new-tool) for a step-by-step guide.

**Q: Is multiplayer supported?**
A: Not yet, but it's on the [roadmap](ROADMAP.md) for Phase 4.

## Windows-Specific Setup

### Finding Your Godot Installation

If you're not sure where Godot is installed:

1. **If installed via Steam:**
   - Open Steam
   - Right-click on Godot in your library
   - Select "Properties" → "Local Files" → "Browse"
   - This opens the installation folder
   - The executable is usually named `godot.windows.opt.tools.64.exe`

2. **If downloaded from godotengine.org:**
   - It's wherever you extracted the .zip file
   - Look for `Godot_v4.2-stable_win64.exe` or similar

### Adding Godot to PATH (Windows)

To use `godot` as a command without the full path:

1. Press `Windows + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find and select "Path"
5. Click "Edit"
6. Click "New"
7. Add the folder path containing `godot.exe` (not the exe itself)
   - Example: `C:\Program Files (x86)\Steam\steamapps\common\Godot Engine`
8. Click "OK" on all windows
9. Restart PowerShell or Command Prompt
10. Now `godot --path .` should work

### PowerShell Script Execution Policy

If you get an error about script execution when activating the Python virtual environment:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try activating again:
```powershell
.\venv\Scripts\Activate.ps1
```
