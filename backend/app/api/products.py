from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.product import Product as ProductModel
from app.schemas.product import Product, ProductCreate

router = APIRouter()

@router.get("/", response_model=list[Product])
def list_products(db: Session = Depends(get_db)):
    """Fetch all products from the database"""
    return db.query(ProductModel).all()

@router.post("/", response_model=Product)
def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    """Add a new product to the store"""
    new_product = ProductModel(**product.dict())
    db.add(new_product)
    commit_db(db)
    db.refresh(new_product)
    return new_product

def commit_db(db):
    try:
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=400, detail="Database Error")