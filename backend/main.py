from fastapi import FastAPI
from app.db.session import engine, Base
from app.api import products
from fastapi.middleware.cors import CORSMiddleware

# Initialize Database Tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="NexaCart API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the Product Routes
app.include_router(products.router, prefix="/api/v1/products", tags=["Products"])

@app.get("/")
def root():
    return {"message": "NexaCart API is Running"}
