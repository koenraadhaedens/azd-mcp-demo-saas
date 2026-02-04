# Fake SaaS Demo - Azure Developer CLI Template

A complete Azure Developer CLI (azd) template for deploying a Python FastAPI "Fake SaaS" backend to Azure Container Apps with full automation.

## 🚀 Quick Start

1. **Prerequisites**
   - [Azure Developer CLI (azd)](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
   - [Docker Desktop](https://docs.docker.com/desktop/)
   - [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

2. **Deploy the Application**
   ```bash
   # Clone or download this template
   azd init
   
   # Deploy everything to Azure
   azd up
   ```

3. **Access Your API**
   After deployment, azd will output your API URL. Test it with:
   ```bash
   # Get the API URL from azd output
   azd env get-values API_URL
   
   # Test the API (replace with your actual URL and API key)
   curl -H "Authorization: Bearer demo-key-12345" https://your-app.azurecontainerapps.io/status
   ```

## 📋 What Gets Deployed

- **Azure Container Registry** - Stores your container images
- **Azure Container Apps Environment** - Hosting environment with logging
- **Azure Container App** - Your FastAPI application
- **Log Analytics Workspace** - Application logs and monitoring
- **Optional: Azure Key Vault** - Secure secret storage

## 🔧 Configuration

### Environment Variables

The template uses these environment variables (set via `azd env set`):

- `AZURE_ENV_NAME` - Name of your environment (auto-generated)
- `AZURE_LOCATION` - Azure region (default: eastus2)
- `DEMO_API_KEY` - API authentication key (default: demo-key-12345)
- `API_NAME_PREFIX` - Prefix for resource names (default: fake-saas)
- `DEPLOY_KEY_VAULT` - Deploy Key Vault for secrets (default: false)

### Customize Settings

```bash
# Set custom API key
azd env set DEMO_API_KEY "my-secure-api-key-123"

# Deploy to different region
azd env set AZURE_LOCATION "westus3"

# Enable Key Vault for secure secret storage
azd env set DEPLOY_KEY_VAULT true

# Deploy updates
azd deploy
```

## 📝 API Endpoints

The FastAPI service exposes these endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information |
| `/status` | GET | Health check |
| `/devices` | GET | List devices |
| `/devices/{id}` | GET | Get specific device |
| `/users` | GET | List users |
| `/users/{id}` | GET | Get specific user |
| `/tickets` | GET | List support tickets |
| `/tickets/{id}` | GET | Get specific ticket |
| `/policies` | GET | List policies |
| `/policies/{id}` | GET | Get specific policy |
| `/docs` | GET | Interactive API docs |

All endpoints (except `/` and `/status`) require authentication:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-app.azurecontainerapps.io/devices
```

## 🏗 Project Structure

```
├── azure.yaml                 # azd configuration
├── Dockerfile                 # Container image definition
├── .env.template              # Environment variables template
├── src/
│   ├── main.py               # FastAPI application
│   └── requirements.txt      # Python dependencies
└── infra/                    # Bicep infrastructure
    ├── main.bicep           # Main infrastructure template
    ├── main.parameters.json # Parameters file
    ├── abbreviations.json   # Azure resource abbreviations
    └── modules/
        ├── acr.bicep        # Azure Container Registry
        ├── env.bicep        # Container Apps Environment
        ├── containerapp.bicep # Container App
        └── kv.bicep         # Key Vault (optional)
```

## 🚢 Deployment Process

When you run `azd up`, here's what happens:

1. **Pre-provision Hook**: Sets default DEMO_API_KEY if not provided
2. **Infrastructure Provision**: Deploys all Azure resources using Bicep
3. **Pre-deploy Hook**: Builds and pushes container image to ACR
4. **Application Deploy**: Updates Container App with new image

---

**Happy coding! 🎉**