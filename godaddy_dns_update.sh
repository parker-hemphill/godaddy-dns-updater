#!/bin/bash

# Set domain or subdomain names for log
if [[ ${2} == '@' ]]
then
  domain=${1}
else
  domain=${2}.${1}
fi

logdest="/tmp/${domain}-log"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TZ_DATA=${5}

# Check if variables are set and exit if not
if [[ ${1} == 'NULL' ]]
then
  echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] DOMAIN not set, exiting container"
  echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] DOMAIN not set, exiting container" >> ${logdest}
  exit 1
fi
if [[ ${3} == 'NULL' ]]
then
  echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] API_KEY not set, exiting container"
  echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] API_KEY not set, exiting container" >> ${logdest}
  exit 1
fi

echo -e "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] Monitoring records for ${domain}, checks every ${4} seconds\nCurrent external IP is $(curl -s "https://api.ipify.org")"
echo -e "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] Monitoring records for ${domain}, checks every ${4} seconds\nCurrent external IP is $(curl -s "https://api.ipify.org")" >> ${logdest}

while :;
do
  sleep ${4}
  #Random sleep so multiple site updates doesn't cause API to timeout
  sleep $((RANDOM % 15 + 1))
  myip=`curl -s "https://api.ipify.org"`
  dnsdata=`curl -s -X GET -H "Authorization: sso-key ${3}" "https://api.godaddy.com/v1/domains/${1}/records/A/${2}"`
  gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
  if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
    curl -s -X PUT "https://api.godaddy.com/v1/domains/${1}/records/A/${2}" -H "Authorization: sso-key ${3}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
    echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] Changed IP on ${domain} from ${gdip} to ${myip}"
    echo "[$(TZ=${TZ_DATA} date +%D" "%H:%M" "%Z)] Changed IP on ${domain} from ${gdip} to ${myip}" >> ${logdest}
  fi
done
