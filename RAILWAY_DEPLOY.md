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
# ===== AI Models (Add all you want to use) =====
# You can add multiple and switch between them anytime

# Gemini (Free tier available)
GOOGLE_API_KEY=your_gemini_key
GOOGLE_GENERATIVE_AI_API_KEY=your_gemini_key

# Claude (Best quality)
ANTHROPIC_API_KEY=sk-ant-your_claude_key

# OpenAI (GPT models)
OPENAI_API_KEY=sk-your_openai_key

# Moonshot/Kimi (Long context, cheap)
MOONSHOT_API_KEY=your_kimi_key

# DeepSeek (Very cheap)
DEEPSEEK_API_KEY=your_deepseek_key

# Groq (Super fast, free)
GROQ_API_KEY=your_groq_key

# Default model (optional)
OPENCLAW_DEFAULT_MODEL=gemini-2.0-flash-exp

# ===== Gateway Configuration =====
OPENCLAW_GATEWAY_TOKEN=generate_a_secure_random_token_here
NODE_ENV=production
OPENCLAW_GATEWAY_BIND=0.0.0.0

# ===== Telegram Bot (Optional) =====
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_BOT_USERNAME=your_bot_username

# ===== WhatsApp (Optional - requires volume) =====
WHATSAPP_SESSION_PATH=/app/data/whatsapp
OPENCLAW_STATE_DIR=/app/data

# ===== Logging =====
OPENCLAW_LOG_LEVEL=info
```

#### Getting API Keys:

See [MODELS_GUIDE.md](./MODELS_GUIDE.md) for detailed instructions on getting API keys for all providers.

**Quick Links:**
- **Gemini**: https://makersuite.google.com/app/apikey (Free tier)
- **Claude**: https://console.anthropic.com/ (Paid)
- **OpenAI**: https://platform.openai.com/api-keys (Paid)
- **DeepSeek**: https://platform.deepseek.com/ (Very cheap)
- **Groq**: https://console.groq.com/ (Free tier)

**Telegram Bot Token:**
1. Open Telegram and message @BotFather
2. Send `/newbot` command
3. Follow instructions to create bot
4. Copy the token provided
5. Also note your bot username

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

### WhatsApp Setup on Railway

WhatsApp requires QR code scanning, which is tricky on Railway. Here are your options:

#### Option 1: View QR in Logs (Recommended)
1. Deploy with `WHATSAPP_SESSION_PATH=/app/data/whatsapp`
2. Add a volume at `/app/data` (Settings → Volumes)
3. After deployment, check Logs tab
4. Look for ASCII QR code in logs
5. Scan with WhatsApp mobile app (Link Device)

#### Option 2: Setup Locally First
1. Run OpenClaw locally: `openclaw channels login whatsapp`
2. Scan QR code
3. Copy session files from `~/.openclaw/channels/whatsapp/`
4. Upload to Railway volume or cloud storage
5. Point `WHATSAPP_SESSION_PATH` to that location

#### Option 3: Skip WhatsApp
- Use only Telegram for now
- Set up WhatsApp later from a VPS with GUI access

### Telegram Not Responding

1. Verify `TELEGRAM_BOT_TOKEN` is correct
2. Check bot username matches
3. Send `/start` to your bot
4. Check Railway logs for connection errors
5. Ensure bot is not already connected elsewhere

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
