FROM barichello/godot-ci:4.2.1 AS builder

WORKDIR /app

# Copy project files
COPY . .

# Export the project for Linux
RUN mkdir -p /app/build
RUN godot --headless --export-release "Linux/X11" /app/build/neural-aegis.x86_64 || \
    echo "Export may fail without export preset, but continuing..."

# Runtime stage
FROM ubuntu:22.04

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    libgl1 \
    libglu1-mesa \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libpulse0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Godot build
COPY --from=builder /app/build /app

# Copy Python ML service and requirements
COPY ml_service.py /app/
COPY requirements.txt /app/
COPY setup_python.sh /app/

# Create virtual environment and install Python dependencies
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install -r /app/requirements.txt

# Create startup script
RUN echo '#!/bin/bash\n\
# Start ML service in background\n\
/app/venv/bin/python /app/ml_service.py &\n\
ML_PID=$!\n\
\n\
# Wait for ML service to be ready\n\
sleep 3\n\
\n\
# Start Godot game\n\
/app/neural-aegis.x86_64\n\
\n\
# Clean up\n\
kill $ML_PID 2>/dev/null || true\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
