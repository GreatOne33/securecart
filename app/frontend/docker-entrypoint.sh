#!/bin/sh
set -eu

: "${APP_NAME:=SecureCart}"
: "${ENVIRONMENT:=Development}"
: "${VERSION:=0.1.0}"
: "${COMPANY:=GreatOne Labs}"
: "${POD_NAME:=local-container}"

: "${BACKEND_HOST:=host.docker.internal}"
: "${BACKEND_PORT:=8000}"

export APP_NAME
export ENVIRONMENT
export VERSION
export COMPANY
export POD_NAME
export BACKEND_HOST
export BACKEND_PORT

mkdir -p \
  /tmp/securecart/html \
  /tmp/client_temp \
  /tmp/proxy_temp \
  /tmp/fastcgi_temp \
  /tmp/uwsgi_temp \
  /tmp/scgi_temp

envsubst '${APP_NAME} ${ENVIRONMENT} ${VERSION} ${COMPANY} ${POD_NAME}' \
  < /opt/securecart/index.html.template \
  > /tmp/securecart/html/index.html

envsubst '${BACKEND_HOST} ${BACKEND_PORT}' \
  < /opt/securecart/nginx.conf.template \
  > /tmp/securecart/nginx.conf

exec nginx \
  -c /tmp/securecart/nginx.conf \
  -g 'daemon off;'