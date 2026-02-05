# ML Integration Guide

## Overview

Neural Aegis uses **real machine learning models** from scikit-learn via a Python REST API service. This provides legitimate ML analysis instead of simulations.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Neural Aegis Game (Godot)                 │
│                                                              │
│  ┌──────────────┐                    ┌──────────────────┐  │
│  │   ML Tools   │                    │  Visualization   │  │
│  │              │                    │     Panel        │  │
│  │ • Lin. Reg.  │                    │                  │  │
│  │ • Iso. Forest│                    │  [Entity View]   │  │
│  │ • Honeypot   │                    │                  │  │
│  │ • Trace      │                    └──────────────────┘  │
│  │ • Snare      │                                           │
│  └──────┬───────┘                                           │
│         │                                                   │
│  ┌──────▼───────────────────────────────────────────┐      │
│  │         MLClient (AutoLoad Singleton)            │      │
│  │         HTTP Request → JSON Response             │      │
│  └──────────────────────┬───────────────────────────┘      │
└─────────────────────────┼───────────────────────────────────┘
                          │ HTTP (localhost:5000)
                          │
┌─────────────────────────▼───────────────────────────────────┐
│              Python ML Service (Flask)                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  REST API Endpoints                                │    │
│  │  • /health                                         │    │
│  │  • /isolation_forest  → sklearn.IsolationForest    │    │
│  │  • /linear_regression → sklearn.LinearRegression   │    │
│  │  • /anomaly_detection → numpy z-scores            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Dependencies: numpy, pandas, scikit-learn, flask           │
└──────────────────────────────────────────────────────────────┘
```

## Setup Options

### Option 1: Automated Setup (Recommended)

The `start.sh` script handles everything:

```bash
./start.sh
```

This will:
1. Check for Python 3
2. Create virtual environment in `venv/`
3. Install all dependencies from `requirements.txt`
4. Start ML service on port 5000
5. Wait for you to start Godot

Then in Godot: Import project → Press F5

### Option 2: Manual Setup

```bash
# Create virtual environment
python3 -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start ML service
python ml_service.py
```

Service will be available at `http://localhost:5000`

### Option 3: Docker

The Dockerfile includes everything:

```dockerfile
# Installs:
# - Python 3
# - Virtual environment
# - All pip packages
# - Godot runtime

# Startup script automatically:
# - Starts ML service in background
# - Launches Godot game
# - Cleans up on exit
```

```bash
docker-compose up --build
```

## Dependencies

### Python Packages (requirements.txt)

```
numpy>=1.24.0          # Numerical computing
pandas>=2.0.0          # Data manipulation
scikit-learn>=1.3.0    # Machine learning models
flask>=3.0.0           # REST API framework
flask-cors>=4.0.0      # CORS support
```

### System Requirements

- **Python 3.8+** - Earlier versions may work but untested
- **pip** - Python package installer
- **venv** - Virtual environment (usually included with Python)

On Ubuntu/Debian:
```bash
sudo apt-get install python3 python3-pip python3-venv
```

On macOS:
```bash
brew install python3
```

On Windows:
Download from [python.org](https://www.python.org/)

## ML Service API

### Health Check

```http
GET /health
```

Response:
```json
{
  "status": "healthy",
  "service": "neural-aegis-ml"
}
```

### Isolation Forest (Outlier Detection)

**Endpoint:** `POST /isolation_forest`

**Request:**
```json
{
  "data": [15.2, 18.5, 19.1, 45.7, 20.3, 17.8],
  "contamination": 0.1
}
```

**Response:**
```json
{
  "outliers": [3],
  "scores": [-0.12, -0.08, -0.09, -0.45, -0.10, -0.07],
  "predictions": [1, 1, 1, -1, 1, 1],
  "model_params": {
    "contamination": 0.1,
    "n_estimators": 100
  }
}
```

**Fields:**
- `outliers`: Indices of detected outliers
- `scores`: Anomaly scores (more negative = more anomalous)
- `predictions`: 1 for inliers, -1 for outliers
- `model_params`: Model configuration

### Linear Regression (Trend Forecasting)

**Endpoint:** `POST /linear_regression`

**Request:**
```json
{
  "data": [10, 12, 14, 15, 17, 19, 21],
  "forecast_steps": 3
}
```

**Response:**
```json
{
  "predictions": [22.8, 24.6, 26.4],
  "trend": "increasing",
  "slope": 1.82,
  "intercept": 9.14,
  "r_squared": 0.98
}
```

**Fields:**
- `predictions`: Forecasted values for next N steps
- `trend`: "increasing", "decreasing", or "stable"
- `slope`: Rate of change
- `r_squared`: Model quality (0-1, higher is better)

### Anomaly Detection (Statistical)

**Endpoint:** `POST /anomaly_detection`

**Request:**
```json
{
  "data": [10, 11, 12, 50, 11, 10],
  "threshold": 3.0
}
```

**Response:**
```json
{
  "anomalies": [3],
  "z_scores": [0.92, 0.78, 0.64, 3.85, 0.78, 0.92],
  "mean": 17.33,
  "std": 15.47,
  "threshold": 3.0
}
```

**Fields:**
- `anomalies`: Indices of values exceeding threshold
- `z_scores`: Z-scores for each value
- `mean`: Dataset mean
- `std`: Standard deviation

## Using ML in Godot

### MLClient Singleton

Automatically loaded in every scene:

```gdscript
# Check if service is available
if MLClient.is_available():
    print("ML service ready!")

# Call Isolation Forest
MLClient.isolation_forest([15, 20, 45, 18], 0.15)

# Call Linear Regression
MLClient.linear_regression([10, 12, 14, 16], 5)

# Listen for responses
MLClient.ml_response_received.connect(_on_ml_result)
MLClient.ml_error.connect(_on_ml_error)

func _on_ml_result(endpoint: String, result: Dictionary):
    print("ML Result: ", result)

func _on_ml_error(endpoint: String, error: String):
    print("ML Error: ", error)
```

### Tool Integration Example

```gdscript
extends Tool

var pending_request: bool = false

func _ready():
    super._ready()
    MLClient.ml_response_received.connect(_on_ml_response)

func use_tool(target_data: Dictionary) -> Dictionary:
    if not MLClient.is_available():
        return {"success": false, "message": "ML service unavailable"}
    
    # Extract data from target
    var values = extract_values(target_data)
    
    # Call ML service
    pending_request = true
    MLClient.isolation_forest(values, 0.1)
    
    return {"success": true, "message": "Analyzing with sklearn..."}

func _on_ml_response(endpoint: String, result: Dictionary):
    if not pending_request:
        return
    
    pending_request = false
    
    # Process results
    var outliers = result.get("outliers", [])
    print("Found ", outliers.size(), " outliers")
```

## Troubleshooting

### "ML service not available"

**Cause:** Python ML service is not running

**Solution:**
```bash
# Check if service is running
curl http://localhost:5000/health

# If not, start it:
./start.sh
# or
source venv/bin/activate && python ml_service.py
```

### "Connection refused"

**Cause:** ML service failed to start or port 5000 is busy

**Solution:**
```bash
# Check what's on port 5000
lsof -i :5000  # Linux/Mac
netstat -an | grep 5000  # Windows

# Kill process if needed
kill <PID>

# Restart ML service
python ml_service.py
```

### "ModuleNotFoundError: No module named 'sklearn'"

**Cause:** Dependencies not installed or wrong Python environment

**Solution:**
```bash
# Make sure you're in the venv
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### Virtual environment not activating

**Cause:** `python3-venv` not installed

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install python3-venv

# Then recreate venv
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Performance Considerations

### Model Training Time

- **Isolation Forest**: ~10-100ms for 20-100 samples
- **Linear Regression**: ~5-20ms for 10-50 samples
- **Anomaly Detection**: ~1-5ms (pure numpy)

### Optimization Tips

1. **Batch requests**: Send multiple analyses together
2. **Cache results**: Store recent predictions
3. **Limit data size**: Send only necessary samples
4. **Async requests**: Don't block game while waiting

### Resource Usage

- **Memory**: ~100-200 MB (Flask + sklearn)
- **CPU**: Minimal when idle, spikes during analysis
- **Network**: localhost only, negligible latency

## Production Deployment

### Security Considerations

⚠️ **Current setup is for local development only!**

For production:

1. **Add authentication**: Require API keys
2. **Use HTTPS**: Encrypt communication
3. **Rate limiting**: Prevent abuse
4. **Input validation**: Sanitize all inputs
5. **CORS restrictions**: Limit allowed origins

### Scaling

For multiple users:

1. **Gunicorn/uWSGI**: Production WSGI server
2. **Redis caching**: Store frequent results
3. **Load balancer**: Distribute requests
4. **Separate services**: Multiple ML service instances

## Future Enhancements

### Planned Features

- [ ] Model persistence (save/load trained models)
- [ ] More ML algorithms (Random Forest, SVM, Neural Networks)
- [ ] Real-time training (update models during gameplay)
- [ ] Model performance metrics dashboard
- [ ] GPU acceleration for larger datasets
- [ ] WebSocket for streaming predictions

### Contributing

To add a new ML model:

1. Add endpoint to `ml_service.py`
2. Add method to `MLClient.gd`
3. Create or update tool in `tools/`
4. Update this documentation

See `docs/CONTRIBUTING.md` for guidelines.
