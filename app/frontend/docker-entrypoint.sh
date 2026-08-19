#!/bin/sh
set -eu

: "${APP_NAME:=SecureCart}"
: "${ENVIRONMENT:=Development}"
: "${VERSION:=0.1.0}"
: "${COMPANY:=GreatOne Labs}"
: "${POD_NAME:=local-container}"
: "${POD_NAMESPACE:=default}"

: "${BACKEND_HOST:=host.docker.internal}"
: "${BACKEND_PORT:=8000}"
: "${BACKEND_UPSTREAM_HOST:=$BACKEND_HOST}"

DNS_RESOLVER="${DNS_RESOLVER:-$(awk '/^nameserver[[:space:]]+/ {print $2; exit}' /etc/resolv.conf)}"

if [ -z "$DNS_RESOLVER" ]; then
  echo "ERROR: Unable to determine DNS resolver from /etc/resolv.conf" >&2
  exit 1
fi

export APP_NAME
export ENVIRONMENT
export VERSION
export COMPANY
export POD_NAME
export POD_NAMESPACE
export BACKEND_HOST
export BACKEND_UPSTREAM_HOST
export BACKEND_PORT
export DNS_RESOLVER

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

envsubst '${BACKEND_UPSTREAM_HOST} ${BACKEND_PORT} ${DNS_RESOLVER}' \
  < /opt/securecart/nginx.conf.template \
  > /tmp/securecart/nginx.conf

exec nginx \
  -c /tmp/securecart/nginx.conf \
  -g 'daemon off;'