#!/bin/bash

mydomain=${DOMAIN}
myhostname=${HOSTNAME}
gdapikey=${API}
logdest="/tmp/godaddy_update.log"

ENV CHECK=${CHECK:-900}

# Check if variables are set and exit if not
if [[ ${DOMAIN} == 'NULL' ]]
then
  echo "DOMAIN not set, exiting container"
  exit 1
fi
if [[ ${API} == 'NULL' ]]
then
  echo "API not set, exiting container"
  exit 1
fi

# Loop to check DNS record for update, based on ${CHECK} variable (in seconds)
while :; do
sleep ${CHECK}
  # Random sleep so multiple site updates doesn't cause API to timeout
  sleep $((RANDOM % 15 + 1))
  # DNS checks
  myip=`curl -s "https://api.ipify.org"`
  dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}"`
  gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
  if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
    curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
    echo "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${myip}" >> $logdest
    echo "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${myip}"
  fi
done
