#!/bin/bash
# Quick start script for Docker ML service

set -e

echo "=== Neural Aegis Docker Quick Start ==="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    echo "Please install Docker from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "Error: docker-compose is not available"
    echo "Please install docker-compose or update Docker to a version with compose plugin"
    exit 1
fi

echo "Using compose command: $COMPOSE_CMD"
echo ""

# Ask user which setup they want
echo "Choose your Docker setup:"
echo "1) ML Service Only (Recommended - run Godot natively)"
echo "2) Full Application (Godot + ML in Docker - Linux only)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "Starting ML Service only..."
        echo "You can run Godot natively on your machine."
        echo ""
        
        # Start ML service
        $COMPOSE_CMD -f docker-compose.ml.yml up -d
        
        echo ""
        echo "✓ ML Service started!"
        echo ""
        echo "Verify it's working:"
        echo "  curl http://localhost:5000/health"
        echo ""
        echo "Next steps:"
        echo "  1. Open Godot 4.2+"
        echo "  2. Import this project"
        echo "  3. Press F5 to run"
        echo ""
        echo "To stop: $COMPOSE_CMD -f docker-compose.ml.yml down"
        ;;
        
    2)
        echo ""
        echo "Starting Full Application..."
        echo "Note: This requires X11 (Linux only)"
        echo ""
        
        # Check if on Linux
        if [[ "$OSTYPE" != "linux-gnu"* ]]; then
            echo "Warning: Full Docker mode typically only works on Linux"
            read -p "Continue anyway? [y/N]: " continue
            if [[ ! "$continue" =~ ^[Yy]$ ]]; then
                echo "Cancelled."
                exit 0
            fi
        fi
        
        # Allow X11 connections
        if command -v xhost &> /dev/null; then
            echo "Allowing Docker to connect to X server..."
            xhost +local:docker
        else
            echo "Warning: xhost not found, X11 forwarding may not work"
        fi
        
        # Start full application
        $COMPOSE_CMD up --build
        ;;
        
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
