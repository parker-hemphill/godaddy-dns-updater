#!/usr/bin/bash

domain="$1"
subdomain="$2"
apikey="$3"
dns_check="${4}"
logdest="/dev/shm/godaddy_update.log"

# Set timezone for container
export TZ="${5}"

# Check if variables are set and exit if not
if [[ ${1} == 'NULL' ]]
then
  echo "DOMAIN not set, exiting container"
  echo "DOMAIN not set, exiting container" >> ${logdest}
  exit 1
fi
if [[ ${3} == 'NULL' ]]
then
  echo "API_KEY not set, exiting container"
  echo "API_KEY not set, exiting container" >> ${logdest}
  exit 1
fi

echo "Monitoring records for ${subdomain}.${domain}, checks every ${dns_check} seconds"
echo "Monitoring records for ${subdomain}.${domain}, checks every ${dns_check} seconds" >> ${logdest}

while :;
do
  sleep ${dns_check}
  #Random sleep so multiple site updates doesn't cause API to timeout
  sleep $((RANDOM % 15 + 1))
  myip=`curl -s "https://api.ipify.org"`
  dnsdata=`curl -s -X GET -H "Authorization: sso-key ${apikey}" "https://api.godaddy.com/v1/domains/${domain}/records/A/${subdomain}"`
  gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
  if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
    curl -s -X PUT "https://api.godaddy.com/v1/domains/${domain}/records/A/${subdomain}" -H "Authorization: sso-key ${apikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
    echo "Changed IP on ${subdomain}.${domain} from ${gdip} to ${myip}"
    echo "Changed IP on ${subdomain}.${domain} from ${gdip} to ${myip}" >> ${logdest}
  fi
done
