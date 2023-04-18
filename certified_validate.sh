#!/bin/bash

host="$1"
if [ -z "$2" ]
then
          port=443
  else
            port=$2
fi

notAfter=$(openssl s_client -connect $host:$port < /dev/null 2> /dev/null | openssl x509 -in /dev/stdin -noout -dates | grep notAfter | cut -d'=' -f2)
expire=$(date -d "$notAfter" +%s)
today=$(date --utc +%s)
left_seconds=$((expire - today))
left_days=$((left_seconds/60/60/24))

echo "$left_days"
