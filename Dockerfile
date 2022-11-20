#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
readonly domain="${1}"
readonly subdomain="${2}"
readonly api_key="${3}"
readonly api_secret="${4}"
readonly dns_check="${5}"
readonly puid="${6}"
readonly pgid="${7}"
readonly tz="${8}"
if [[ "${tz}" == 'UNSET' ]]; then
  echo "tz variable not set, defaulting to UTC"
  cp /usr/share/zoneinfo/UTC /etc/localtime
else
  if ! ls "/usr/share/zoneinfo/${tz}" >/dev/null 2>&1; then
    echo "INVALID tz variable set, defaulting to UTC"
    cp /usr/share/zoneinfo/UTC /etc/localtime
  else
    echo "Setting tz to ${tz}"
    cp /usr/share/zoneinfo/${tz} /etc/localtime
  fi
fi

# Setup main logfile
setup_logger(){
  readonly logdest='/tmp/godaddy_dns_update.log'
  touch "${logdest}" && chown ${puid}:${pgid} "${logdest}"
  chmod a+r "${logdest}"
}

# Check if domain variable is set and exit if not
validate_domain(){
  if [[ "${domain}" == 'NULL' ]]; then
    echo "[$(date +%D" "%H:%M" "%Z)] domain not set, exiting container"|tee -a ${logdest}
    exit 1
  fi
}

# Check if api_key variable is set and exit if not
validate_api_key(){
  if [[ "${api_key}" == 'NULL' ]]; then
    echo "[$(date +%D" "%H:%M" "%Z)] api_key not set, exiting container"|tee -a ${logdest}
    exit 1
  else
    echo "[$(date +%D" "%H:%M" "%Z)] api_key set"|tee -a ${logdest}
  fi
}

# Check if api_secret variable is set and exit if not
validate_api_secret(){
  if [[ "${api_secret}" == 'NULL' ]]; then
    echo "[$(date +%D" "%H:%M" "%Z)] api_secret not set, either add variable to docker or append to \"api_key\" with \":\""|tee -a ${logdest}
  else
    echo "[$(date +%D" "%H:%M" "%Z)] api_secret set"|tee -a ${logdest}
  fi
}

validate_subdomain(){
  if [[ "${subdomain}" == '*' ]]; then
    echo "[$(date +%D" "%H:%M" "%Z)] Error: subdomain should be omitted for wildcard updates.  Point subdomains to '@' in godaddy DNS and update domain with this container"|tee -a ${logdest}
    sleep 30
    exit 1
  fi
}

monitor_and_update_domain(){
  if [[ "${subdomain}" == '@' ]]; then
    local -ra domain_array+=("${domain}")
  else
    IFS='|' read -ra subdomain_array <<< "${subdomain}"
    for sub_domain in ${subdomain_array[@]}; do
      domain_array+=("${sub_domain}")
    done
  fi
  if [[ "${api_secret}" == 'NULL' ]]; then
    local -r api_auth_string="${api_key}"
  else
    local -r api_auth_string="${api_key}:${api_secret}"
  fi
  while :; do
    for domain_to_update in "${domain_array[@]}"; do
      domain_dns_ip=$(dig +short "${domain_to_update}")
      if ! external_ip=$(curl -s https://api.ipify.org); then
        echo "Unable to get external ip address"
        exit 1
      fi
      if [[ "${domain_dns_ip}" != "${external_ip}" ]]; then
        domain_ip_raw="$(curl -s -X GET -H "Authorization: sso-key ${api_auth_string}" "https://api.godaddy.com/v1/domains/${domain}/records/A/${domain_to_update}")"
        domain_ip="$(echo "${domain_ip_raw}" | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2)"
        if [[ "${domain_ip}" != "${external_ip}" ]]; then
          update_status=$(curl -o /dev/null -w "%{http_code}\n" -s -X PUT "https://api.godaddy.com/v1/domains/${domain}/records/A/${domain_to_update}" -H "Authorization: sso-key ${api_auth_string}" -H "Content-Type: application/json" -d "[{\"data\": \"${external_ip}\"}]")
          if [[ ${update_status} -eq 200 ]]; then
            echo "[$(date +%D" "%H:%M" "%Z)] Changed IP on ${domain_to_update} from ${domain_ip} to ${external_ip}"|tee -a "${logdest}"
          else
            echo "[$(date +%D" "%H:%M" "%Z)] GoDaddy API returned ${update_status} status,  update FAILED"|tee -a "${logdest}"
          fi
        else
          echo "[$(date +%D" "%H:%M" "%Z)] External DNS for ${domain_to_update} resolves to ${external_ip}, no update needed"|tee -a "${logdest}"
        fi
      else
        echo "[$(date +%D" "%H:%M" "%Z)] External DNS for ${domain_to_update} resolves to ${external_ip}, no update needed"|tee -a "${logdest}"
      fi
      sleep 5
    done
    sleep ${dns_check}
  done
}

main(){
  setup_logger
  validate_domain
  validate_api_key
  validate_subdomain
  monitor_and_update_domain
}

main
