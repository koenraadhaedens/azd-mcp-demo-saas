@echo off
REM Fake SaaS Demo - Deployment Script for Windows
REM This script helps deploy the application with common configurations

echo.
echo 🚀 Fake SaaS Demo - Azure Container Apps Deployment
echo ==================================================
echo.

REM Check prerequisites
echo ✅ Checking prerequisites...

where azd >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure Developer CLI ^(azd^) is not installed
    echo Please install from: https://docs.microsoft.com/azure/developer/azure-developer-cli/
    exit /b 1
)

where az >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure CLI is not installed
    echo Please install from: https://docs.microsoft.com/cli/azure/install-azure-cli
    exit /b 1
)

echo ✅ All prerequisites are installed ^(No Docker Desktop needed!^)
echo.

REM Set default environment variables
echo 🔧 Setting up environment...

REM Set API key
for /f "tokens=*" %%i in ('azd env get-value DEMO_API_KEY 2^>nul') do set current_api_key=%%i
if "%current_api_key%"=="" (
    set /p api_key=Enter a custom API key ^(or press Enter for default 'demo-key-12345'^): 
    if "!api_key!"=="" set api_key=demo-key-12345
    azd env set DEMO_API_KEY "!api_key!"
    echo ✅ Set DEMO_API_KEY
)

REM Set other defaults
for /f "tokens=*" %%i in ('azd env get-value AZURE_LOCATION 2^>nul') do set current_location=%%i
if "%current_location%"=="" (
    azd env set AZURE_LOCATION "eastus2"
    echo ✅ Set AZURE_LOCATION to eastus2
)

for /f "tokens=*" %%i in ('azd env get-value API_NAME_PREFIX 2^>nul') do set current_prefix=%%i
if "%current_prefix%"=="" (
    azd env set API_NAME_PREFIX "fake-saas"
    echo ✅ Set API_NAME_PREFIX to fake-saas
)

for /f "tokens=*" %%i in ('azd env get-value DEPLOY_KEY_VAULT 2^>nul') do set current_kv=%%i
if "%current_kv%"=="" (
    azd env set DEPLOY_KEY_VAULT "false"
    echo ✅ Set DEPLOY_KEY_VAULT to false
)

echo.
echo 🚀 Starting deployment...
echo This will provision Azure resources and deploy the application.
echo Estimated time: 5-10 minutes
echo.

REM Deploy
azd up

echo.
echo 🎉 Deployment completed!
echo.
echo Your API is now available at:
azd env get-values | findstr API_URL

echo.
echo Test your API with PowerShell:
for /f "tokens=*" %%i in ('azd env get-value DEMO_API_KEY') do set demo_key=%%i
for /f "tokens=*" %%i in ('azd env get-value API_URL') do set api_url=%%i
echo curl -H "Authorization: Bearer %demo_key%" https://%api_url%/status

echo.
echo View API documentation at:
echo https://%api_url%/docs
echo.
echo Happy coding! 🎉