# OpenClaw Railway Deployment Guide

## Prerequisites
- Railway account (https://railway.app)
- GitHub repository with your OpenClaw code
- API keys for AI models (Anthropic, OpenAI, etc.)

## Deployment Steps

### 1. Create New Railway Project

1. Go to https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your `open_bot` repository

### 2. Configure Environment Variables

Go to your Railway project → Variables tab and add:

```bash
# Required
NODE_ENV=production
PORT=18789
OPENCLAW_GATEWAY_BIND=0.0.0.0

# AI Model Keys (at least one required)
ANTHROPIC_API_KEY=your_anthropic_key
# or
OPENAI_API_KEY=your_openai_key

# Gateway Security
OPENCLAW_GATEWAY_TOKEN=generate_a_secure_random_token_here

# Optional
OPENCLAW_LOG_LEVEL=info
```

### 3. Configure Build Settings

Railway should auto-detect the configuration from `nixpacks.toml`, but verify:

- **Build Command**: `pnpm install --frozen-lockfile && pnpm build && pnpm ui:build`
- **Start Command**: `node dist/index.js gateway --port $PORT --bind 0.0.0.0`
- **Node Version**: 22.x

### 4. Add Volume (Optional, for persistent data)

1. Go to your service → Settings → Volumes
2. Add a volume mounted at `/app/data`
3. This will persist your configuration and session data

### 5. Deploy

1. Click "Deploy" or push to your GitHub repo
2. Railway will automatically build and deploy
3. Wait for deployment to complete (5-10 minutes first time)

### 6. Access Your Gateway

After deployment:

1. Go to Settings → Networking
2. Click "Generate Domain" to get a public URL
3. Your gateway will be available at: `https://your-app.railway.app`
4. Dashboard: `https://your-app.railway.app/`

### 7. Connect to Dashboard

1. Open the dashboard URL
2. Go to Settings
3. Enter your `OPENCLAW_GATEWAY_TOKEN`
4. Start chatting!

## Troubleshooting

### Build Fails

- Check logs in Railway dashboard
- Verify all dependencies are in `package.json`
- Ensure Node version is 22.x or higher

### Gateway Won't Start

- Check environment variables are set correctly
- Verify `PORT` variable is set
- Check logs for specific errors

### Can't Connect to Dashboard

- Ensure `OPENCLAW_GATEWAY_BIND=0.0.0.0` is set
- Verify domain is generated and active
- Check that gateway token matches in UI settings

### Memory Issues

- Railway free tier has 512MB RAM limit
- Consider upgrading plan if needed
- Monitor memory usage in Railway dashboard

## Cost Estimation

- **Free Tier**: $5 credit/month (limited resources)
- **Hobby Plan**: $5/month (better for production)
- **Pro Plan**: $20/month (recommended for heavy usage)

## Security Notes

1. **Never commit** `.env` files with real credentials
2. Use Railway's environment variables for secrets
3. Generate a strong random token for `OPENCLAW_GATEWAY_TOKEN`
4. Consider enabling Railway's built-in authentication
5. Use HTTPS only (Railway provides this automatically)

## Updating Your Deployment

1. Push changes to your GitHub repository
2. Railway will automatically rebuild and redeploy
3. Or manually trigger deployment from Railway dashboard

## Support

- Railway Docs: https://docs.railway.app
- OpenClaw Docs: https://docs.openclaw.ai
- Issues: https://github.com/ahosan-soev/open_bot/issues
