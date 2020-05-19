# Use latest alpine base image
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl bash

# Set version label
LABEL build_version="Godaddy-DNS-Updater, Version: 1.0.8, Build-date: 18-May-2020"
LABEL maintainer=parker-hemphill

# Copy convert shell scripts to /opt
COPY godaddy_dns_update.sh /opt/

# Set scripts as executable
RUN chmod +rxxx /opt/godaddy_dns_update.sh

# Set default docker variables
ENV DOMAIN=${DOMAIN:-NULL}
ENV SUB_DOMAIN=${SUB_DOMAIN:-@}
ENV API_KEY=${API_KEY:-NULL}
ENV DNS_CHECK=${DNS_CHECK:-900}
ENV TIME_ZONE=${TIME_ZONE:-America/New_York}

CMD /opt/godaddy_dns_update.sh "${DOMAIN}" "${SUB_DOMAIN}" "${API_KEY}" "${DNS_CHECK}" "${TIME_ZONE}"
