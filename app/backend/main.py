import os

import psycopg
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from psycopg.rows import dict_row


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

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "securecart")
DB_USER = os.getenv("DB_USER", "securecart_app")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def get_database_connection():
    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
        row_factory=dict_row,
    )


@app.get("/health")
def health_check():
    return {
        "status": "degraded"
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


@app.get("/api/products", response_model=ProductList)
def get_products():
    try:
        with get_database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        id,
                        name,
                        price::float AS price,
                        in_stock
                    FROM products
                    ORDER BY id;
                    """
                )

                products = cursor.fetchall()

        return {
            "products": products
        }

    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Database unavailable: {exc}"
        )


@app.get("/api/products/{product_id}", response_model=Product)
def get_product(product_id: int):
    try:
        with get_database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        id,
                        name,
                        price::float AS price,
                        in_stock
                    FROM products
                    WHERE id = %s;
                    """,
                    (product_id,)
                )

                product = cursor.fetchone()

        if product is None:
            raise HTTPException(
                status_code=404,
                detail="Product not found"
            )

        return product

    except HTTPException:
        raise

    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Database unavailable: {exc}"
        )


@app.get("/api/db-status")
def database_status():
    try:
        with get_database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1 AS test_query;")
                result = cursor.fetchone()

        return {
            "database": "PostgreSQL",
            "status": "connected",
            "test_query": result["test_query"]
        }

    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Database unavailable: {exc}"
        )