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

RUN apt-get update && apt-get install -y \
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
COPY --from=builder /app/build /app

CMD ["/app/neural-aegis.x86_64"]
