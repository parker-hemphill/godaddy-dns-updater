# Use latest alpine base image
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl bash tzdata bind-tools

# Set version label
LABEL build_version="Godaddy-DNS-Updater, Version: 1.2.2, Build-date: 2024-Mar-24"
LABEL maintainer=parker-hemphill

# Copy convert shell scripts to /opt
COPY godaddy_dns_update /opt/

# Set scripts as executable
RUN chmod +rxxx /opt/godaddy_dns_update

# Set default docker variables
ENV DOMAIN=${DOMAIN:-NULL}
ENV SUB_DOMAIN=${SUB_DOMAIN:-@}
ENV API_KEY=${API_KEY:-NULL}
ENV API_SECRET=${API_SECRET:-NULL}
ENV DNS_CHECK=${DNS_CHECK:-900}
ENV TZ=${TZ:-NULL}
ENV PUID=${PUID:-0}
ENV PGID=${PGID:-0}

CMD /opt/godaddy_dns_update ${DOMAIN} ${SUB_DOMAIN} ${API_KEY} ${API_SECRET} ${DNS_CHECK} ${PUID} ${PGID} ${TZ}
