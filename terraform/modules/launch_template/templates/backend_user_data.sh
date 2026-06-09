#!/bin/bash
set -e

# Write runtime ecosystem config with correct env vars
cat > /home/ubuntu/wellnest/ecosystem.runtime.config.js << 'ECOEOF'
module.exports = {
  apps: [
    {
      name: 'auth-service',
      script: 'services/auth-service/src/index.js',
      cwd: '/home/ubuntu/wellnest',
      instances: 1,
      autorestart: true,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        DYNAMODB_USERS_TABLE: 'wellnest-users',
        CLINICAL_NOTES_BUCKET: 'wellnest-clinical-notes',
        EXPORTS_BUCKET: 'wellnest-daily-exports',
        AUTH_SERVICE_URL: 'http://localhost:3001',
        ASSESSMENT_SERVICE_URL: 'http://localhost:3002',
        FRONTEND_URL: '*'
      }
    },
    {
      name: 'assessment-service',
      script: 'services/assessment-service/src/index.js',
      cwd: '/home/ubuntu/wellnest',
      instances: 1,
      autorestart: true,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3002,
        DYNAMODB_ASSESSMENTS_TABLE: 'wellnest-assessments',
        DYNAMODB_TEMPLATES_TABLE: 'wellnest-assessment-templates',
        DYNAMODB_MOOD_TABLE: 'wellnest-mood-logs',
        AUTH_SERVICE_URL: 'http://localhost:3001',
        ASSESSMENT_SERVICE_URL: 'http://localhost:3002',
        FRONTEND_URL: '*'
      }
    },
    {
      name: 'therapist-service',
      script: 'services/therapist-service/src/index.js',
      cwd: '/home/ubuntu/wellnest',
      instances: 1,
      autorestart: true,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3003,
        DYNAMODB_SESSIONS_TABLE: 'wellnest-sessions',
        DYNAMODB_THERAPIST_PATIENTS_TABLE: 'wellnest-therapist-patients',
        DYNAMODB_USERS_TABLE: 'wellnest-users',
        CLINICAL_NOTES_BUCKET: 'wellnest-clinical-notes',
        EXPORTS_BUCKET: 'wellnest-daily-exports',
        AUTH_SERVICE_URL: 'http://localhost:3001',
        ASSESSMENT_SERVICE_URL: 'http://localhost:3002',
        FRONTEND_URL: '*'
      }
    }
  ]
};
ECOEOF

chown ubuntu:ubuntu /home/ubuntu/wellnest/ecosystem.runtime.config.js

# Wait for AWS Secrets Manager to be reachable and permissions to propagate
echo "Checking AWS Secrets Manager reachability..."
for i in {1..30}; do
  if (cd /home/ubuntu/wellnest/services/auth-service && node -e "
    const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
    const client = new SecretsManagerClient({ region: 'us-east-1' });
    client.send(new GetSecretValueCommand({ SecretId: 'wellnest/production/jwt-secret' }))
      .then(() => process.exit(0))
      .catch((err) => {
        console.error(err.message);
        process.exit(1);
      });
  ") 2>/dev/null; then
    echo "Secrets Manager is accessible, starting applications."
    break
  fi
  echo "Secrets Manager not accessible yet. Retrying in 5 seconds ($i/30)..."
  sleep 5
done

# Start PM2 as ubuntu user
sudo -u ubuntu bash -c "cd /home/ubuntu/wellnest && pm2 start ecosystem.runtime.config.js && pm2 save"
