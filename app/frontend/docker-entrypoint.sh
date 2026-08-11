#!/bin/sh
set -eu

: "${APP_NAME:=SecureCart}"
: "${ENVIRONMENT:=Development}"
: "${VERSION:=0.1.0}"
: "${COMPANY:=GreatOne Labs}"
: "${POD_NAME:=local-container}"

: "${BACKEND_HOST:=host.docker.internal}"
: "${BACKEND_PORT:=8000}"

envsubst '${APP_NAME} ${ENVIRONMENT} ${VERSION} ${COMPANY} ${POD_NAME}' \
  < /opt/securecart/index.html.template \
  > /usr/share/nginx/html/index.html

envsubst '${BACKEND_HOST} ${BACKEND_PORT}' \
  < /opt/securecart/nginx.conf.template \
  > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
