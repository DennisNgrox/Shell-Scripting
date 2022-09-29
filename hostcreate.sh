#!/bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.142/api_jsonrpc.php"
HOSTNAME_ZABBIX=$1
IP_ZABBIX=$2


ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)

curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.create\",
    \"params\": {
        \"host\": \"${HOSTNAME_ZABBIX}\",
        \"interfaces\": [
            {
                \"type\": 2,
                \"main\": 1,
                \"useip\": 0,
                \"ip\": \"\",
                \"dns\": \"${IP_ZABBIX}\",
                \"port\": \"161\",
                \"details\": {
                    \"version\": 2,
                    \"bulk\": 0,
                    \"community\": \"{\$SNMP_COMMUNITY}\"
                }

            }
        ],
        \"groups\": [
            {
                \"groupid\": 18
            }
        ]
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
