#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.142/api_jsonrpc.php"



ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)



UPDATE=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.update\",
    \"params\": {
        \"itemid\": \"50655\",
        \"lifetime\": \"0d\"
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
)


for i in $(cat listadelldid.txt); do VALOR1=$(echo $i | cut -f1); updatelld.sh ${VALOR1}; done | jq
