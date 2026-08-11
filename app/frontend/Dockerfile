FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="SecureCart Frontend"
LABEL org.opencontainers.image.description="Containerized frontend for the SecureCart cloud-native application"
LABEL org.opencontainers.image.version="0.2.0"
LABEL org.opencontainers.image.source="https://github.com/GreatOne33/securecart"
LABEL org.opencontainers.image.authors="Angel Sepulveda"

RUN rm -f /usr/share/nginx/html/index.html

COPY index.html.template /opt/securecart/index.html.template
COPY nginx.conf.template /opt/securecart/nginx.conf.template
COPY docker-entrypoint.sh /usr/local/bin/securecart-entrypoint

RUN chmod +x /usr/local/bin/securecart-entrypoint

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/securecart-entrypoint"]
