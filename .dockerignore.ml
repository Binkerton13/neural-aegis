# Dockerignore for ML Service Only
# Use with: docker build -f Dockerfile.ml-service .

# Git
.git/
.gitignore
.github/

# Documentation
docs/
*.md

# IDE
.vscode/
.idea/

# Godot - not needed for ML service
scenes/
scripts/
tools/
assets/
.import/
.godot/
*.tscn
*.gd
project.godot
icon.png
export_presets.cfg
*.translation

# Python virtual environment
venv/
__pycache__/
*.pyc
*.pyo
.Python

# OS
.DS_Store
Thumbs.db

# Temporary files
/tmp/
build/

# Docker files
Dockerfile
docker-compose*.yml
.dockerignore

# Scripts not needed in container
start.sh
setup_python.sh
