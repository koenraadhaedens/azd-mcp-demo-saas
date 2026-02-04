#!/bin/bash

# Fake SaaS Demo - Deployment Script
# This script helps deploy the application with common configurations

set -e

echo "🚀 Fake SaaS Demo - Azure Container Apps Deployment"
echo "=================================================="

# Check prerequisites
echo "✅ Checking prerequisites..."

if ! command -v azd &> /dev/null; then
    echo "❌ Azure Developer CLI (azd) is not installed"
    echo "Please install from: https://docs.microsoft.com/azure/developer/azure-developer-cli/"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed"
    echo "Please install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo "✅ All prerequisites are installed (No Docker Desktop needed!)"

# Set default environment variables
echo "🔧 Setting up environment..."

# Prompt for API key if not set
if [ -z "$(azd env get-value DEMO_API_KEY 2>/dev/null)" ]; then
    echo "Enter a custom API key (or press Enter for default 'demo-key-12345'):"
    read -r api_key
    if [ -z "$api_key" ]; then
        api_key="demo-key-12345"
    fi
    azd env set DEMO_API_KEY "$api_key"
    echo "✅ Set DEMO_API_KEY"
fi

# Set other defaults if not set
if [ -z "$(azd env get-value AZURE_LOCATION 2>/dev/null)" ]; then
    azd env set AZURE_LOCATION "eastus2"
    echo "✅ Set AZURE_LOCATION to eastus2"
fi

if [ -z "$(azd env get-value API_NAME_PREFIX 2>/dev/null)" ]; then
    azd env set API_NAME_PREFIX "fake-saas"
    echo "✅ Set API_NAME_PREFIX to fake-saas"
fi

if [ -z "$(azd env get-value DEPLOY_KEY_VAULT 2>/dev/null)" ]; then
    azd env set DEPLOY_KEY_VAULT "false"
    echo "✅ Set DEPLOY_KEY_VAULT to false"
fi

echo ""
echo "🚀 Starting deployment..."
echo "This will provision Azure resources and deploy the application."
echo "Estimated time: 5-10 minutes"
echo ""

# Deploy
azd up

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "Your API is now available at:"
azd env get-values | grep API_URL

echo ""
echo "Test your API with:"
echo "curl -H \"Authorization: Bearer $(azd env get-value DEMO_API_KEY)\" https://\$(azd env get-value API_URL)/status"
echo ""
echo "View API documentation at:"
echo "https://\$(azd env get-value API_URL)/docs"
echo ""
echo "Happy coding! 🎉"