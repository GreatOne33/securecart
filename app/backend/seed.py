import os

import psycopg


DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "securecart")
DB_USER = os.getenv("DB_USER", "securecart_app")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


PRODUCTS = [
    ("SecureCart T-Shirt", 24.99, True),
    ("SecureCart Hoodie", 49.99, True),
    ("SecureCart Sticker Pack", 6.99, False),
]


def seed_products():
    with psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
    ) as connection:
        with connection.cursor() as cursor:
            for name, price, in_stock in PRODUCTS:
                cursor.execute(
                    """
                    SELECT id
                    FROM products
                    WHERE name = %s;
                    """,
                    (name,),
                )

                existing_product = cursor.fetchone()

                if existing_product:
                    print(f"Skipping existing product: {name}")
                    continue

                cursor.execute(
                    """
                    INSERT INTO products (name, price, in_stock)
                    VALUES (%s, %s, %s);
                    """,
                    (name, price, in_stock),
                )

                print(f"Inserted product: {name}")

        connection.commit()


if __name__ == "__main__":
    seed_products()