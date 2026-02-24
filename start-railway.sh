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

# Create data directory
mkdir -p "$OPENCLAW_STATE_DIR"

echo "Starting OpenClaw Gateway on port $PORT"
echo "Gateway mode: $OPENCLAW_GATEWAY_MODE"
echo "State directory: $OPENCLAW_STATE_DIR"

# Start the gateway with allow-unconfigured flag
exec node dist/index.js gateway \
  --port "$PORT" \
  --bind 0.0.0.0 \
  --allow-unconfigured
