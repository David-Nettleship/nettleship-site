#!/bin/bash
set -euo pipefail

SITE_BUCKET="nettleship-site"
SITE_DISTRIBUTION_ID="E2KUJ5KSLDKHHZ"
SCRIPT_DIR="$(dirname "$0")"
WEBPAGES_DIR="$SCRIPT_DIR/webpages"

echo "==> Checking Terraform is up to date..."
terraform -chdir="$SCRIPT_DIR/infra" plan -detailed-exitcode -no-color -compact-warnings -lock=false 2>&1 | tail -5
TF_EXIT=${PIPESTATUS[0]}
if [ "$TF_EXIT" -eq 1 ]; then
  echo "    ERROR: terraform plan failed. Fix infra issues before deploying."
  exit 1
elif [ "$TF_EXIT" -eq 2 ]; then
  echo ""
  echo "    WARNING: Terraform has unapplied changes."
  echo "    Run 'cd infra && terraform apply' first, or continue anyway? [y/N]"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "==> Syncing site files to S3..."
aws s3 sync "$WEBPAGES_DIR/" "s3://$SITE_BUCKET/" --delete

echo "==> Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$SITE_DISTRIBUTION_ID" \
  --paths "/*" \
  --query "Invalidation.{ID:Id,Status:Status}" \
  --output table

echo "==> Done. Changes will be live within ~60 seconds."
echo "    Site: https://d30hl2nxoul2at.cloudfront.net"
