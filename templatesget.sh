#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.142/api_jsonrpc.php"



ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)



TEMPLATES=$(curl -s -H 'Content-Type: application/json-rpc' -d "

 {
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {
        \"output\": \"extend\",
         \"groupids\": \"20\",
        \"filter\": {
            \"groupids\": [
                \"20\"
            ]
        }
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}"  ${ZABBIX_API}
)

RESULT=$(echo $TEMPLATES| jq . | grep "templateid" | sed 's/"//g' | sed 's/,//g'| sed 's/[[:space:]]//g' | cut -d: -f2)
echo $RESULT |  sed 's/ /\n/g' >> listadetemplates.txt
