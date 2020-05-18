# Use latest alpine base image
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl
RUN apk add --no-cache bash

# Set version label
LABEL build_version="Godaddy-DNS-Updater, Version: 1.0.5, Build-date: 18-May-2020"
LABEL maintainer=parker-hemphill

# Copy convert shell scripts to /opt
RUN echo "**** copy shell scripts to /opt ****"
COPY godaddy_dns_update.sh /opt/

# Set scripts as executable
RUN echo "**** set shell scripts as executable ****"
RUN chmod +rxxx /opt/godaddy_dns_update.sh

# Set default docker variables
RUN echo "**** setup default variables****"
ENV DOMAIN=${DOMAIN:-NULL}
ENV SUB_DOMAIN=${SUB_DOMAIN:-@}
ENV API_KEY=${API_KEY:-NULL}
ENV DNS_CHECK=${DNS_CHECK:-900}
ENV TZ=${TZ:-America/New_York}

ENTRYPOINT ["/usr/bin/bash /opt/godaddy_dns_update.sh ${DOMAIN} ${SUB_DOMAIN} ${API_KEY} ${DNS_CHECK} ${TZ}"]
