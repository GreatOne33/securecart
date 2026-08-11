import os

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

class Product(BaseModel):
    id: int
    name: str
    price: float
    in_stock: bool

class ProductList(BaseModel):
    products: list[Product]

app = FastAPI(
    title="SecureCart API",
    version="0.1.0",
)

APP_NAME = os.getenv("APP_NAME", "SecureCart API")
API_VERSION = os.getenv("API_VERSION", "0.1.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "Development")
POD_NAME = os.getenv("POD_NAME", "local-development")

@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }

@app.get("/api/status")
def application_status():
    return {
        "application": APP_NAME,
        "version": API_VERSION,
        "environment": ENVIRONMENT,
        "pod": POD_NAME,
        "status": "running"
    }

products = [
    Product(
        id=1,
        name="SecureCart T-Shirt",
        price=24.99,
        in_stock=True
    ),
    Product(
        id=2,
        name="SecureCart Hoodie",
        price=49.99,
        in_stock=True
    ),
    Product(
        id=3,
        name="SecureCart Sticker Pack",
        price=6.99,
        in_stock=False
    )
]

@app.get("/api/products", response_model=ProductList)
def get_products():
    return {
        "products": products
    }

@app.get("/api/products/{product_id}", response_model=Product)
def get_product(product_id: int):
    for product in products:
        if product.id == product_id:
            return product

    raise HTTPException(
        status_code=404,
        detail="Product not found"
    )




