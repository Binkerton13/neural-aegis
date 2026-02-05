#!/bin/bash
# Start script for Neural Aegis with ML service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Neural Aegis Startup ==="

# Check if setup has been run
if [ ! -d "venv" ]; then
    echo "Python virtual environment not found. Running setup..."
    ./setup_python.sh
fi

# Activate virtual environment
echo "Activating Python virtual environment..."
source venv/bin/activate

# Start ML service in background
echo "Starting ML service on port 5000..."
python ml_service.py &
ML_PID=$!

# Give ML service time to start
sleep 2

echo ""
echo "ML service started (PID: $ML_PID)"
echo "Ready to launch Godot!"
echo ""
echo "To run the game:"
echo "  1. Open Godot 4.2+"
echo "  2. Import this project"
echo "  3. Press F5 to run"
echo ""
echo "Press Ctrl+C to stop the ML service"
echo ""

# Wait for interrupt
trap "echo 'Stopping ML service...'; kill $ML_PID 2>/dev/null; exit" INT TERM

# Keep script running
wait $ML_PID
