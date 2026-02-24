#!/bin/bash
# Google Cloud Run Deployment Script

set -e

# Configuration
PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-your-project-id}"
SERVICE_NAME="${CLOUDRUN_SERVICE_NAME:-openclaw-gateway}"
REGION="${CLOUDRUN_REGION:-us-central1}"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Deploying OpenClaw to Google Cloud Run"
echo "Project: $PROJECT_ID"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI not found"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ Error: Not logged in to gcloud"
    echo "Run: gcloud auth login"
    exit 1
fi

# Set project
echo "📦 Setting project..."
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com

# Build the container
echo "🏗️  Building container image..."
gcloud builds submit \
    --tag "$IMAGE_NAME" \
    --timeout=20m \
    --machine-type=e2-highcpu-8 \
    -f Dockerfile.cloudrun \
    .

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE_NAME" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080 \
    --set-env-vars "NODE_ENV=production,OPENCLAW_GATEWAY_MODE=local,OPENCLAW_STATE_DIR=/app/data" \
    --set-secrets "OPENCLAW_GATEWAY_TOKEN=openclaw-gateway-token:latest,GOOGLE_API_KEY=google-api-key:latest,TELEGRAM_BOT_TOKEN=telegram-bot-token:latest"

# Get the service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format="value(status.url)")

echo ""
echo "✅ Deployment complete!"
echo "🌐 Service URL: $SERVICE_URL"
echo "📊 Dashboard: $SERVICE_URL/"
echo ""
echo "Next steps:"
echo "1. Set up secrets in Google Secret Manager"
echo "2. Configure environment variables"
echo "3. Access your dashboard at: $SERVICE_URL"
