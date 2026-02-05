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
- Godot 4.2 or higher

### Steps

1. Download Godot from [godotengine.org](https://godotengine.org/)
2. Extract and run the Godot executable
3. Click "Import" and select the `project.godot` file
4. Click "Import & Edit"
5. Press **F5** (or click the play button) to run

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

**Q: What if I don't have a GPU?**
A: Godot works fine with CPU rendering. The game is not graphically intensive.

**Q: Can I modify the themes?**
A: Absolutely! Edit `data/themes.json` and restart the game.

**Q: How do I add my own tool?**
A: See [DEVELOPMENT.md](DEVELOPMENT.md#adding-a-new-tool) for a step-by-step guide.

**Q: Is multiplayer supported?**
A: Not yet, but it's on the [roadmap](ROADMAP.md) for Phase 4.
