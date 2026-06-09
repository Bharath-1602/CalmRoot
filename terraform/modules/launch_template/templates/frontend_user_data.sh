#!/bin/bash
set -e

INTERNAL_ALB_DNS="${internal_alb_dns}"

# Wait for the internal ALB DNS to become resolvable
echo "Waiting for internal ALB DNS ($${INTERNAL_ALB_DNS}) to become resolvable..."
until getent hosts "$${INTERNAL_ALB_DNS}" > /dev/null; do
  echo "Still waiting for DNS resolution..."
  sleep 5
done
echo "Internal ALB DNS is resolvable!"

# Copy the template nginx config to active config
cp /etc/nginx/sites-available/wellnest /etc/nginx/sites-available/wellnest-active

# Replace placeholder or old ALB DNS with actual Internal ALB DNS
sed -i "s|INTERNAL_ALB_PLACEHOLDER|$${INTERNAL_ALB_DNS}|g" /etc/nginx/sites-available/wellnest-active
sed -i "s|internal-wellnest-[^/]*\.amazonaws\.com|$${INTERNAL_ALB_DNS}|g" /etc/nginx/sites-available/wellnest-active


# Enable the active config
ln -sf /etc/nginx/sites-available/wellnest-active /etc/nginx/sites-enabled/wellnest-active

# Remove any default or temp configs
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/wellnest-temp
rm -f /etc/nginx/sites-enabled/wellnest

# Test and restart nginx
nginx -t
systemctl restart nginx
systemctl enable nginx
