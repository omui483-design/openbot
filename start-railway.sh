#!/bin/bash
# Railway startup script

# Set default port if not provided
export PORT=${PORT:-18789}

# Ensure port is valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: PORT must be a number, got: $PORT"
  export PORT=18789
fi

echo "Starting OpenClaw Gateway on port $PORT"

# Start the gateway
exec node dist/index.js gateway --port "$PORT" --bind 0.0.0.0
