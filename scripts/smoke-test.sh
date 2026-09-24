#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "=== SecureCart post-deployment smoke tests ==="

echo "1. Frontend"
FRONTEND_HTML="$(curl --fail --silent --show-error \
  "${BASE_URL}/")"

if [[ "${FRONTEND_HTML}" != *"<html"* &&
      "${FRONTEND_HTML}" != *"<HTML"* ]]; then
  echo "FAIL: Frontend did not return HTML" >&2
  exit 1
fi
echo "PASS: Frontend serves HTML"

echo "2. Backend status"
STATUS="$(curl --fail --silent --show-error \
  "${BASE_URL}/api/status")"

echo "${STATUS}" | jq -e \
  '.status == "running"' > /dev/null

echo "PASS: Backend is running"

echo "3. PostgreSQL connectivity"
DB_STATUS="$(curl --fail --silent --show-error \
  "${BASE_URL}/api/db-status")"

echo "${DB_STATUS}" | jq -e \
  '.database == "PostgreSQL" and
   .status == "connected" and
   .test_query == 1' > /dev/null

echo "PASS: PostgreSQL connection and test query"

echo "4. Seeded product catalog"
PRODUCTS="$(curl --fail --silent --show-error \
  "${BASE_URL}/api/products")"

echo "${PRODUCTS}" | jq -e \
  '.products | type == "array" and length > 0' > /dev/null

echo "PASS: Product catalog contains database records"

echo "=== All smoke tests passed ==="