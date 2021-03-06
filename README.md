# parkerhemphill/godaddy-dns-updater
## A simple docker image that uses curl, and a simple shell script to monitor a sub-domain or domain and update GoDaddy DNS records
[![Docker Stars](https://img.shields.io/docker/stars/parkerhemphill/godaddy-dns-updater)](https://store.docker.com/community/images/parkerhemphill/godaddy-dns-updater) 
[![Docker Pulls](https://img.shields.io/docker/pulls/parkerhemphill/godaddy-dns-updater)](https://store.docker.com/community/images/parkerhemphill/godaddy-dns-updater)
### Flow of operations:
* 1: Container starts up and sleeps number of seconds specified by **DNS_CHECK** (Defaults to 900 seconds, or 15 minutes if variable not provided)
* 2: Once **DNS_CHECK** time has passed, container waits between 1 and 15 seconds (Randomized each time the loop runs so that you can run multiple containers and not cause an API time-out)
  * Curl makes a call to **https://api.ipify.org** to determine current external IP address of host.
  * Curl then makes a call to GoDaddy DNS API to get current record for sub-domain/domain, if that IP address doesn't match external IP there is a curl POST pushed to update the DNS record
* 3: Container start-up and any changes to DNS record are logged inside container to **/tmp/<DOMAIN_NAME>-log**, this directory can be exported to make the logs available outside container
  
### Notes:
* Added arm and arm64 image support (Docker should pull correct image automagically)
* Required variables have a default set of NULL, the container looks for these and exits with a message of problem in the log file.  An easy way to trouble-shoot container is to map /tmp to an external directory (explained in the docker-compose and docker run example below)
* Only required ENV variables are **DOMAIN** and **API_KEY**, everything else has valid defaults
* ENV variables "PUID" and "PGID" can be passed to set owner of logfile to a specific user, this is useful for mapping an external directory and setting the owner to a normal user
## Docker-compose example
* In this example I will be monitoring and updating **cool-site.example.com**, and checking for a change to DNS every 600 seconds (10 minutes)
  * **volumes** can be omitted or mapped somewhere such as a a folder under your home directory, simply change the *left* side to point to where you'd like to save DNS update logfiles
* Change "TIME_ZONE" to match your desired timezone.  A vaild list can be found at https://www.wikiwand.com/en/List_of_tz_database_time_zones under the "TZ database name" column.  Default is "America/New_York"
```
#docker-compose.yaml
version: "3"
services:
  godaddy-ddns:
    image: parkerhemphill/godaddy-dns-updater
    container_name: godaddy-ddns
    restart: unless-stopped
    environment:
      DOMAIN: 'example.com'
      SUB_DOMAIN: 'cool-site'
      API_KEY: 'GO_DADDY_DNS_API_KEY'
      DNS_CHECK: 600
      TIME_ZONE: America/New_York
    volumes:
      - /tmp:/tmp
```
## Docker run example
```
docker run -d \
  --name=godaddy-dns-updater \
  -e TIME_ZONE=America/New_York \
  -e DOMAIN=example.com \
  -e SUB_DOMAIN=cool-site \
  -e API_KEY='GO_DADDY_DNS_API_KEY' \
  -e DNS_CHECK=600 \
  -v /tmp:/tmp \
  --restart unless-stopped \
  parkerhemphill/godaddy-dns-updater:latest
```
## Support
* Shell access while the container is running:<br>
 `docker exec -it godaddy-dns-updater /bin/bash`
* To see log of DNS updates:<br>
 `docker exec -it godaddy-dns-updater cat /tmp/*-log` 
* Container version number:<br>
 `docker inspect -f '{{ index .Config.Labels "build_version" }}' godaddy-dns-updater`
* Image version number:<br>
 `docker inspect -f '{{ index .Config.Labels "build_version" }}' parkerhemphill/godaddy-dns-updater`
