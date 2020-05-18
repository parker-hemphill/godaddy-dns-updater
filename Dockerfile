# Use latest alpine base image
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl

# Set version label
LABEL build_version="Godaddy-DNS-Updater, Version: 1.0.1, Build-date: 18-May-2020"
LABEL maintainer=parker-hemphill

# Copy convert shell scripts to /opt
RUN echo "**** copy shell scripts to /opt ****"
COPY godaddy_dns_update.sh /opt

# Set scripts as executable
RUN echo "**** set shell scripts as executable ****"
RUN chmod +rxxx /opt/godaddy_dns_update.sh

# Set default docker variables
RUN echo "**** setup default variables****"
ENV TZ=${TZ:-America/New_York}
ENV DOMAIN=${DOMAIN:-@}
ENV HOSTNAME=${HOSTNAME:-NULL}
ENV API=${API:-NULL}
ENV CHECK=${CHECK:-900}


ENTRYPOINT ["/usr/bin/bash /opt/godaddy_dns_update.sh"]
