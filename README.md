# Neural Aegis

> **SOC/ML Analyst Training Game** - Learn security operations and machine learning through gamified simulation

![Godot Engine](https://img.shields.io/badge/Godot-4.2-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-prototype-yellow.svg)

## 🎮 Overview

Neural Aegis is an innovative gamified training application designed for security operations center (SOC) analysts and machine learning practitioners. It simulates a continuously scrolling log of system events, allowing players to apply drag-and-drop analytical tools to detect and respond to threats in real-time.

### Key Features

- **🔄 Real-time Log Simulation** - Continuously scrolling logs with color-coded events (normal, warnings, alerts)
- **🎨 Dynamic Theming** - Switch between narrative themes (Forest Critters, Cyberpunk, Wizards & Warriors)
- **🔧 Interactive Tools** - Five ML/security tools with real-world equivalents:
  - **Linear Regression** - Trend analysis and forecasting
  - **Isolation Forest** - Anomaly detection
  - **Honeypot** - Deception technology
  - **Trace** - Network traffic analysis
  - **Snare** - Automated threat response
- **📊 Gamification** - Score tracking, threat detection counters, resource management
- **🎓 Educational** - Each tool maps to real-world analyst techniques

## 🚀 Quick Start

### Prerequisites

- **Godot 4.2+** - Download from [godotengine.org](https://godotengine.org/)
- **Python 3.8+** - For real ML capabilities
- **Docker** (optional) - For containerized deployment

### Option 1: Run with ML Service (Recommended)

This enables **real machine learning** using scikit-learn:

```bash
# Clone the repository
git clone https://github.com/Binkerton13/neural-aegis.git
cd neural-aegis

# Setup Python environment and start ML service
./start.sh

# In a separate terminal or after the ML service starts:
# Open Godot and import this project, then press F5
```

The `start.sh` script will:
1. Create a Python virtual environment
2. Install dependencies (numpy, pandas, scikit-learn, flask)
3. Start the ML service on port 5000
4. Keep running until you press Ctrl+C

### Option 2: Using Docker

The Docker image includes both Godot and the Python ML service:

```bash
# Clone the repository
git clone https://github.com/Binkerton13/neural-aegis.git
cd neural-aegis

# Build and run
docker-compose up --build
```

### Option 3: Godot Only (No ML)

Run without the Python backend (tools will show error messages):

```bash
# Download Godot from godotengine.org
# Open Godot and import the project
# Press F5 to run
```

**Note:** Without the ML service, tools like Linear Regression and Isolation Forest will display "ML service not available" messages.

## 🧠 Machine Learning Integration

Neural Aegis uses **real scikit-learn models** via a Python REST API:

- **Linear Regression** - Actual sklearn LinearRegression for trend forecasting
- **Isolation Forest** - Real sklearn IsolationForest for outlier detection
- **Statistical Analysis** - Z-score based anomaly detection using numpy

### ML Service Architecture

```
┌─────────────┐      HTTP API      ┌──────────────┐
│   Godot     │  ◄──────────────►  │   Python     │
│   (GDScript)│                     │   Flask      │
│             │                     │   sklearn    │
└─────────────┘                     └──────────────┘
  ↓ Drag tool onto log               ↓ Real ML analysis
  ↓ Send data to API                 ↓ Return results
  ↓ Display results
```

### Manual ML Service Setup

If `start.sh` doesn't work for your system:

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the service
python ml_service.py
```

The ML service will be available at `http://localhost:5000`.

## 🎯 How to Play

1. **Watch the Logs** - The log viewer displays simulated system activity
2. **Select a Theme** - Use the dropdown to switch between Forest, Cyber, or Fantasy themes
3. **Use Tools** - Click tools in the left palette to deploy them
4. **Detect Threats** - Look for ALERT messages (red text) indicating anomalies
5. **Score Points** - Successfully detect and neutralize threats to increase your score

### Controls

- **Click Tool Button** - Deploy an analyst tool
- **Theme Dropdown** - Switch narrative themes
- **Auto-scroll** - Logs automatically scroll to show latest entries

## 📚 Documentation

- [Quick Start Guide](docs/QUICKSTART.md) - Detailed setup instructions
- [Architecture](docs/ARCHITECTURE.md) - System design and component overview
- [Contributing](docs/CONTRIBUTING.md) - How to contribute to the project
- [Development Guide](docs/DEVELOPMENT.md) - Adding tools, themes, and features
- [Roadmap](docs/ROADMAP.md) - Future plans and phases

## 🛠️ Technology Stack

- **Game Engine**: Godot 4.2
- **Language**: GDScript
- **Containerization**: Docker
- **Theme System**: JSON-based terminology database

## 🎨 Themes

### Forest Critters
Wholesome woodland creatures protecting squirrel eggs from foxes and bears.

### Cyberpunk
High-tech security environment defending servers from botnets and APT groups.

### Wizards & Warriors
Fantasy realm protecting mana crystals from goblins and orcs.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

### Quick Contribution Options

1. **Add a New Tool** - Follow [DEVELOPMENT.md](docs/DEVELOPMENT.md#adding-a-new-tool)
2. **Add a New Theme** - Edit `data/themes.json` and submit a PR
3. **Improve Documentation** - Help make guides clearer
4. **Report Bugs** - Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
5. **Request Features** - Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)

## 📋 Roadmap

**Current Phase: MVP Prototype**
- ✅ Scrolling log system
- ✅ Theme switching (3 themes)
- ✅ 5 drag-and-drop tools
- ✅ Simulated anomaly detection
- ✅ Docker containerization

**Next Phase: Enhanced Gameplay**
- 🔲 Visual map representation
- 🔲 Tutorial/onboarding
- 🔲 Sound effects
- 🔲 Save/load system

See [ROADMAP.md](docs/ROADMAP.md) for complete development plan.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Godot Engine](https://godotengine.org/)
- Inspired by real-world SOC analyst workflows
- Educational resource for ML and security practitioners

## 📞 Contact

- **Repository**: [github.com/Binkerton13/neural-aegis](https://github.com/Binkerton13/neural-aegis)
- **Issues**: [github.com/Binkerton13/neural-aegis/issues](https://github.com/Binkerton13/neural-aegis/issues)

---

**Made with ❤️ for security and ML education**
