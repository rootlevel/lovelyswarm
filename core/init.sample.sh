#!/bin/sh

echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID={YOUR-SUBSCRIPTION-ID}
export ARM_CLIENT_ID={YOUR-CLIENT-ID}
export ARM_CLIENT_SECRET={YOUR-SECRET-ID}
export ARM_TENANT_ID={YOUR-TENANT-ID}

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public