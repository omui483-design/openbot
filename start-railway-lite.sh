#!/bin/bash
# Railway startup script - LITE VERSION (minimal memory)

export PORT=${PORT:-18789}
export OPENCLAW_STATE_DIR=${OPENCLAW_STATE_DIR:-/app/data}
export OPENCLAW_GATEWAY_MODE=${OPENCLAW_GATEWAY_MODE:-local}

# Aggressive memory limits
export NODE_OPTIONS="--max-old-space-size=400 --max-semi-space-size=2 --optimize-for-size"

# Disable heavy features
export OPENCLAW_SKIP_BROWSER=true
export OPENCLAW_SKIP_CANVAS=true
export OPENCLAW_SKIP_VOICE=true
export OPENCLAW_SKIP_SANDBOX=true
export OPENCLAW_SKIP_PLUGINS=true

# Minimal logging
export OPENCLAW_LOG_LEVEL=error

mkdir -p "$OPENCLAW_STATE_DIR"

echo "Starting OpenClaw Gateway (LITE MODE) on port $PORT"
echo "Memory: 400MB limit, features disabled for Railway free tier"

# Start with minimal features
exec node \
  --max-old-space-size=400 \
  --max-semi-space-size=2 \
  --optimize-for-size \
  dist/index.js gateway \
  --port "$PORT" \
  --bind auto \
  --allow-unconfigured \
  --skip-channels-autostart
