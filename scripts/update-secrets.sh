#!/usr/bin/env bash
# update-secrets.sh
# Utility helper to manually update Secrets Manager credentials for the production environment.
# Update the variables inside this file and run it to configure your real production keys.

set -euo pipefail

AWS_REGION="us-east-1"

# Real values to replace (Change these before running)
JWT_SECRET="calmroot-production-jwt-secret-2025-eks"

# SMTP Settings (Gmail SMTP)
SES_SENDER_EMAIL="bharath70135@gmail.com"
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="bharath70135@gmail.com"
SMTP_PASS="zdzbvnwrspyzhhps"
SMTP_FROM="bharath70135@gmail.com"

echo "Updating CalmRoot secrets in AWS Secrets Manager..."

# 1. Update JWT Secret
echo "Setting calmroot/prod/jwt..."
aws secretsmanager put-secret-value \
    --secret-id "calmroot/prod/jwt" \
    --secret-string "{\"JWT_SECRET\":\"$JWT_SECRET\"}" \
    --region "$AWS_REGION"

# 2. Update SES & SMTP Credentials
echo "Setting calmroot/prod/ses..."
aws secretsmanager put-secret-value \
    --secret-id "calmroot/prod/ses" \
    --secret-string "{\"SES_SENDER_EMAIL\":\"$SES_SENDER_EMAIL\",\"SMTP_HOST\":\"$SMTP_HOST\",\"SMTP_PORT\":\"$SMTP_PORT\",\"SMTP_USER\":\"$SMTP_USER\",\"SMTP_PASS\":\"$SMTP_PASS\",\"SMTP_FROM\":\"$SMTP_FROM\"}" \
    --region "$AWS_REGION"

echo "All secrets updated successfully!"
