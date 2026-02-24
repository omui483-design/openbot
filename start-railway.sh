#!/bin/bash
# Railway startup script

# Set default port if not provided
export PORT=${PORT:-18789}

# Ensure port is valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: PORT must be a number, got: $PORT"
  export PORT=18789
fi

# Set environment for OpenClaw
export OPENCLAW_STATE_DIR=${OPENCLAW_STATE_DIR:-/app/data}
export OPENCLAW_GATEWAY_MODE=${OPENCLAW_GATEWAY_MODE:-local}

# Set Node.js memory limit (Railway has 512MB, use 450MB to be safe)
export NODE_OPTIONS="--max-old-space-size=450"

# Create data directory
mkdir -p "$OPENCLAW_STATE_DIR"

echo "Starting OpenClaw Gateway on port $PORT"
echo "Gateway mode: $OPENCLAW_GATEWAY_MODE"
echo "State directory: $OPENCLAW_STATE_DIR"
echo "Node memory limit: 450MB"

# Start the gateway with auto bind (Railway compatible)
exec node dist/index.js gateway \
  --port "$PORT" \
  --bind auto \
  --allow-unconfigured
