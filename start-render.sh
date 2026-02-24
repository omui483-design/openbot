#!/bin/bash
# Render.com startup script

# Render automatically sets PORT environment variable
export PORT=${PORT:-10000}

echo "Render deployment starting..."
echo "PORT: $PORT"

# Ensure port is valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: PORT must be a number, got: $PORT"
  export PORT=10000
fi

# Set environment for OpenClaw
export OPENCLAW_STATE_DIR=${OPENCLAW_STATE_DIR:-/opt/render/project/data}
export OPENCLAW_GATEWAY_MODE=${OPENCLAW_GATEWAY_MODE:-local}

# Memory optimization for Render free tier (512MB)
export NODE_OPTIONS="--max-old-space-size=400"

# Create data directory
mkdir -p "$OPENCLAW_STATE_DIR"

echo "Starting OpenClaw Gateway on port $PORT"
echo "Gateway mode: $OPENCLAW_GATEWAY_MODE"
echo "State directory: $OPENCLAW_STATE_DIR"
echo "Node memory limit: 400MB"

# Start the gateway
exec node dist/index.js gateway \
  --port "$PORT" \
  --bind auto \
  --allow-unconfigured
