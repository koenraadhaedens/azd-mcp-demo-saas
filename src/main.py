"""
Fake SaaS Demo API
A simple FastAPI application demonstrating SaaS endpoints
"""

import os
import logging
from typing import Dict, List, Optional
from datetime import datetime
from fastapi import FastAPI, HTTPException, Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Fake SaaS Demo API",
    description="A demonstration SaaS API with typical endpoints",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Security
security = HTTPBearer()
DEMO_API_KEY = os.getenv("DEMO_API_KEY", "demo-key-12345")

# Data models
class Device(BaseModel):
    id: str
    name: str
    type: str
    status: str = Field(default="active")
    last_seen: datetime = Field(default_factory=datetime.now)

class User(BaseModel):
    id: str
    name: str
    email: str
    role: str = Field(default="user")
    created_at: datetime = Field(default_factory=datetime.now)

class Ticket(BaseModel):
    id: str
    title: str
    description: str
    status: str = Field(default="open")
    priority: str = Field(default="medium")
    created_at: datetime = Field(default_factory=datetime.now)

class Policy(BaseModel):
    id: str
    name: str
    description: str
    rules: List[str]
    enabled: bool = Field(default=True)

# Mock data
DEVICES = [
    Device(id="dev-001", name="Production Server", type="server"),
    Device(id="dev-002", name="Database Instance", type="database"),
    Device(id="dev-003", name="Load Balancer", type="network")
]

USERS = [
    User(id="user-001", name="John Doe", email="john@example.com", role="admin"),
    User(id="user-002", name="Jane Smith", email="jane@example.com", role="user"),
    User(id="user-003", name="Bob Johnson", email="bob@example.com", role="user")
]

TICKETS = [
    Ticket(id="ticket-001", title="Server downtime", description="Production server is not responding"),
    Ticket(id="ticket-002", title="Database slow query", description="Query performance degraded"),
    Ticket(id="ticket-003", title="Network connectivity", description="Intermittent connection issues")
]

POLICIES = [
    Policy(id="pol-001", name="Security Policy", description="Basic security rules", 
           rules=["Require MFA", "Password complexity", "Session timeout"]),
    Policy(id="pol-002", name="Data Retention", description="Data lifecycle management",
           rules=["Backup daily", "Archive after 1 year", "Delete after 7 years"]),
]

# Auth dependency
def verify_api_key(credentials: HTTPAuthorizationCredentials = Security(security)) -> str:
    """Verify API key from Authorization header"""
    if credentials.credentials != DEMO_API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid API key"
        )
    return credentials.credentials

# Health check endpoint
@app.get("/status")
async def get_status():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "environment": os.getenv("AZURE_ENV_NAME", "local")
    }

# Device endpoints
@app.get("/devices", response_model=List[Device])
async def get_devices(api_key: str = Depends(verify_api_key)):
    """Get all devices"""
    logger.info(f"Fetching devices for API key: {api_key[:8]}...")
    return DEVICES

@app.get("/devices/{device_id}", response_model=Device)
async def get_device(device_id: str, api_key: str = Depends(verify_api_key)):
    """Get a specific device by ID"""
    device = next((d for d in DEVICES if d.id == device_id), None)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    return device

# User endpoints
@app.get("/users", response_model=List[User])
async def get_users(api_key: str = Depends(verify_api_key)):
    """Get all users"""
    logger.info(f"Fetching users for API key: {api_key[:8]}...")
    return USERS

@app.get("/users/{user_id}", response_model=User)
async def get_user(user_id: str, api_key: str = Depends(verify_api_key)):
    """Get a specific user by ID"""
    user = next((u for u in USERS if u.id == user_id), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Ticket endpoints
@app.get("/tickets", response_model=List[Ticket])
async def get_tickets(status: Optional[str] = None, api_key: str = Depends(verify_api_key)):
    """Get all tickets, optionally filtered by status"""
    logger.info(f"Fetching tickets for API key: {api_key[:8]}...")
    if status:
        return [t for t in TICKETS if t.status == status]
    return TICKETS

@app.get("/tickets/{ticket_id}", response_model=Ticket)
async def get_ticket(ticket_id: str, api_key: str = Depends(verify_api_key)):
    """Get a specific ticket by ID"""
    ticket = next((t for t in TICKETS if t.id == ticket_id), None)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket

# Policy endpoints
@app.get("/policies", response_model=List[Policy])
async def get_policies(api_key: str = Depends(verify_api_key)):
    """Get all policies"""
    logger.info(f"Fetching policies for API key: {api_key[:8]}...")
    return POLICIES

@app.get("/policies/{policy_id}", response_model=Policy)
async def get_policy(policy_id: str, api_key: str = Depends(verify_api_key)):
    """Get a specific policy by ID"""
    policy = next((p for p in POLICIES if p.id == policy_id), None)
    if not policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    return policy

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "name": "Fake SaaS Demo API",
        "version": "1.0.0",
        "description": "A demonstration SaaS API with typical endpoints",
        "endpoints": {
            "status": "/status",
            "devices": "/devices",
            "users": "/users", 
            "tickets": "/tickets",
            "policies": "/policies",
            "docs": "/docs"
        },
        "authentication": "Bearer token required (set DEMO_API_KEY)",
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)