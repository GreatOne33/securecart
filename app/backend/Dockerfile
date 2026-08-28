FROM python:3.14-slim

USER root

RUN apt-get update \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd --system securecart \
    && useradd --system \
       --gid securecart \
       --home-dir /app \
       --no-create-home \
       securecart

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    -r requirements.txt \
    && python -m pip uninstall -y pip

COPY --chown=securecart:securecart main.py .
COPY --chown=securecart:securecart seed.py .
COPY --chown=securecart:securecart alembic.ini .
COPY --chown=securecart:securecart migrations ./migrations

USER securecart

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]