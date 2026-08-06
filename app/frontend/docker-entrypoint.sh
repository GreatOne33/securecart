#!/bin/sh
set -eu

: "${APP_NAME:=SecureCart}"
: "${ENVIRONMENT:=Development}"
: "${VERSION:=0.1.0}"
: "${COMPANY:=GreatOne Labs}"
: "${POD_NAME:=local-container}"

envsubst '${APP_NAME} ${ENVIRONMENT} ${VERSION} ${COMPANY} ${POD_NAME}' \
  < /opt/securecart/index.html.template \
  > /usr/share/nginx/html/index.html

exec nginx -g 'daemon off;'
