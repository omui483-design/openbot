# OpenClaw Google Cloud Run Deployment Guide

Deploy OpenClaw to Google Cloud Run with 1GB RAM free tier.

## Prerequisites

1. **Google Cloud Account** (Free tier includes $300 credit)
2. **gcloud CLI** installed
3. **Docker** (optional, Cloud Build handles it)
4. **API Keys** (Gemini, Telegram, etc.)

## Free Tier Limits

- **Memory**: 1GB RAM (better than Railway's 512MB)
- **CPU**: 1 vCPU
- **Requests**: 2 million requests/month free
- **Build time**: 120 build-minutes/day free
- **Storage**: 0.5GB free

## Step-by-Step Deployment

### 1. Install gcloud CLI

**Windows:**
```powershell
# Download from: https://cloud.google.com/sdk/docs/install
# Or use PowerShell:
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
```

**Linux/Mac:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 2. Initialize gcloud

```bash
# Login to Google Cloud
gcloud auth login

# Create a new project (or use existing)
gcloud projects create openclaw-project --name="OpenClaw"

# Set the project
gcloud config set project openclaw-project

# Enable billing (required for Cloud Run)
# Go to: https://console.cloud.google.com/billing
```

### 3. Set Up Secrets (Recommended)

Store sensitive data in Google Secret Manager:

```bash
# Enable Secret Manager API
gcloud services enable secretmanager.googleapis.com

# Create secrets
echo -n "your_secure_random_token" | gcloud secrets create openclaw-gateway-token --data-file=-
echo -n "your_gemini_api_key" | gcloud secrets create google-api-key --data-file=-
echo -n "your_telegram_bot_token" | gcloud secrets create telegram-bot-token --data-file=-
echo -n "your_bot_username" | gcloud secrets create telegram-bot-username --data-file=-

# Optional: Other model API keys
echo -n "your_claude_key" | gcloud secrets create anthropic-api-key --data-file=-
echo -n "your_openai_key" | gcloud secrets create openai-api-key --data-file=-
```

### 4. Deploy Using Script (Easy Way)

```bash
# Set your project ID
export GOOGLE_CLOUD_PROJECT=openclaw-project

# Make script executable
chmod +x deploy-cloudrun.sh

# Deploy
./deploy-cloudrun.sh
```

### 5. Deploy Manually (Alternative)

```bash
# Set variables
PROJECT_ID="openclaw-project"
SERVICE_NAME="openclaw-gateway"
REGION="us-central1"

# Build and push image
gcloud builds submit \
  --tag gcr.io/$PROJECT_ID/$SERVICE_NAME \
  -f Dockerfile.cloudrun

# Deploy to Cloud Run
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --port 8080 \
  --set-env-vars "NODE_ENV=production,OPENCLAW_GATEWAY_MODE=local" \
  --set-secrets "OPENCLAW_GATEWAY_TOKEN=openclaw-gateway-token:latest,GOOGLE_API_KEY=google-api-key:latest,TELEGRAM_BOT_TOKEN=telegram-bot-token:latest,TELEGRAM_BOT_USERNAME=telegram-bot-username:latest"
```

### 6. Configure Environment Variables

If not using secrets, set environment variables directly:

```bash
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --set-env-vars "\
OPENCLAW_GATEWAY_TOKEN=your_token,\
GOOGLE_API_KEY=your_gemini_key,\
TELEGRAM_BOT_TOKEN=your_telegram_token,\
TELEGRAM_BOT_USERNAME=your_bot_username,\
OPENCLAW_GATEWAY_MODE=local,\
NODE_ENV=production"
```

### 7. Get Service URL

```bash
gcloud run services describe openclaw-gateway \
  --region us-central1 \
  --format="value(status.url)"
```

Your service will be available at: `https://openclaw-gateway-xxxxx.run.app`

## Configuration Options

### Memory and CPU

```bash
# Update memory (512MB to 4GB)
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --memory 2Gi

# Update CPU (1 to 4)
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --cpu 2
```

### Scaling

```bash
# Set min/max instances
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --min-instances 0 \
  --max-instances 10
```

### Timeout

```bash
# Set request timeout (max 3600s = 1 hour)
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --timeout 300
```

## Using the Dashboard

1. Get your service URL:
   ```bash
   gcloud run services describe openclaw-gateway --region us-central1 --format="value(status.url)"
   ```

2. Open in browser: `https://your-service-url.run.app`

3. Go to Settings and enter your `OPENCLAW_GATEWAY_TOKEN`

4. Start chatting!

## Using Telegram Bot

1. Open your Telegram bot
2. Send `/start`
3. Bot should respond immediately

## Monitoring and Logs

### View Logs

```bash
# Real-time logs
gcloud run services logs tail openclaw-gateway --region us-central1

# Recent logs
gcloud run services logs read openclaw-gateway --region us-central1 --limit 50
```

### Metrics

View in Cloud Console:
```
https://console.cloud.google.com/run/detail/us-central1/openclaw-gateway/metrics
```

## Cost Optimization

### Free Tier Usage

- **Always free**: 2M requests/month
- **CPU**: Only charged when processing requests
- **Memory**: Only charged during request processing
- **Idle**: No charges when not in use

### Tips to Stay Free

1. Use `--min-instances 0` (scale to zero when idle)
2. Set reasonable `--max-instances` (e.g., 5-10)
3. Use `--memory 1Gi` (sufficient for most use cases)
4. Monitor usage in billing dashboard

### Estimated Costs (if exceeding free tier)

- **Memory**: ~$0.0000025/GB-second
- **CPU**: ~$0.00002400/vCPU-second
- **Requests**: ~$0.40/million requests

Example: 1M requests/month with 1GB RAM = ~$5-10/month

## Troubleshooting

### Build Fails

**Error**: Out of memory during build
**Solution**: Use larger machine type:
```bash
gcloud builds submit --machine-type=e2-highcpu-8 ...
```

### Service Won't Start

**Check logs**:
```bash
gcloud run services logs read openclaw-gateway --region us-central1 --limit 100
```

**Common issues**:
- Missing environment variables
- Invalid secrets
- Port not set to 8080

### Can't Connect to Dashboard

1. Check service is running:
   ```bash
   gcloud run services describe openclaw-gateway --region us-central1
   ```

2. Verify URL is accessible:
   ```bash
   curl https://your-service-url.run.app/health
   ```

3. Check gateway token is set correctly

### Out of Memory

Increase memory allocation:
```bash
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --memory 2Gi
```

## Updating Your Deployment

### Rebuild and Redeploy

```bash
# Quick update
./deploy-cloudrun.sh

# Or manually
gcloud builds submit --tag gcr.io/$PROJECT_ID/openclaw-gateway -f Dockerfile.cloudrun
gcloud run deploy openclaw-gateway --image gcr.io/$PROJECT_ID/openclaw-gateway --region us-central1
```

### Update Environment Variables Only

```bash
gcloud run services update openclaw-gateway \
  --region us-central1 \
  --set-env-vars "NEW_VAR=value"
```

## CI/CD with GitHub Actions

Create `.github/workflows/deploy-cloudrun.yml`:

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - uses: google-github-actions/setup-gcloud@v1
      
      - name: Build and Deploy
        run: |
          gcloud builds submit --tag gcr.io/${{ secrets.GCP_PROJECT_ID }}/openclaw-gateway -f Dockerfile.cloudrun
          gcloud run deploy openclaw-gateway \
            --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/openclaw-gateway \
            --region us-central1 \
            --platform managed
```

## Comparison: Cloud Run vs Railway

| Feature | Cloud Run Free | Railway Free |
|---------|---------------|--------------|
| RAM | 1GB | 512MB |
| CPU | 1 vCPU | Shared |
| Requests | 2M/month | Unlimited |
| Build Time | 120 min/day | Unlimited |
| Scale to Zero | ✅ Yes | ❌ No |
| Custom Domain | ✅ Free | ✅ Free |
| Best For | Production | Development |

## Support

- **Cloud Run Docs**: https://cloud.google.com/run/docs
- **Pricing**: https://cloud.google.com/run/pricing
- **OpenClaw Issues**: https://github.com/ahosan-soev/open_bot/issues

## Quick Commands Reference

```bash
# Deploy
./deploy-cloudrun.sh

# View logs
gcloud run services logs tail openclaw-gateway --region us-central1

# Update env vars
gcloud run services update openclaw-gateway --region us-central1 --set-env-vars "KEY=value"

# Get URL
gcloud run services describe openclaw-gateway --region us-central1 --format="value(status.url)"

# Delete service
gcloud run services delete openclaw-gateway --region us-central1
```

---

**Ready to deploy?** Run `./deploy-cloudrun.sh` and you're live in minutes! 🚀
