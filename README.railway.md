# OpenClaw - Railway Deployment

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/openclaw)

## Quick Deploy to Railway

1. Click the "Deploy on Railway" button above
2. Add your environment variables (see below)
3. Wait for build to complete
4. Access your gateway at the generated Railway URL

## Required Environment Variables

```bash
ANTHROPIC_API_KEY=your_key_here
# or
OPENAI_API_KEY=your_key_here

OPENCLAW_GATEWAY_TOKEN=your_secure_random_token
```

## Optional Environment Variables

```bash
OPENCLAW_LOG_LEVEL=info
TELEGRAM_BOT_TOKEN=your_telegram_token
DISCORD_BOT_TOKEN=your_discord_token
```

## After Deployment

1. Open your Railway app URL
2. Go to Settings in the UI
3. Enter your `OPENCLAW_GATEWAY_TOKEN`
4. Start using OpenClaw!

For detailed instructions, see [RAILWAY_DEPLOY.md](./RAILWAY_DEPLOY.md)

## Local Development

```bash
# Install dependencies
pnpm install

# Build
pnpm build
pnpm ui:build

# Run locally
openclaw gateway
```

## Documentation

- [Full Documentation](https://docs.openclaw.ai)
- [Railway Deployment Guide](./RAILWAY_DEPLOY.md)
- [Original OpenClaw Repo](https://github.com/openclaw/openclaw)
