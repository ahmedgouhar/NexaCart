from fastapi import FastAPI
from app.routers import auth  # Import your new auth router file

app = FastAPI(title="NexaCart API", docs_url="/docs", openapi_url="/openapi.json")

# Include the registration and login paths
app.include_router(auth.router)

@app.get("/api/v1/health")
def health_check():
    return {"status": "healthy", "service": "nexacart_backend"}