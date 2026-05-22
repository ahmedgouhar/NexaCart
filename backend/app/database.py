from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
import os

# Dynamically pulls the database URL we mapped in docker-compose
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://admin:password123@db/nexacart")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# The critical dependency function
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()