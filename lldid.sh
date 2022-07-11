#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.142/api_jsonrpc.php"



ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)



GET_HOST_ID=$(curl -s -H 'Content-Type: application/json-rpc' -d "

    {
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.get\",
    \"params\": {
        \"output\": \"extend\",
        \"hostids\": \"$1\"
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}"  ${ZABBIX_API}
)

echo $GET_HOST_ID

RESULT=$(echo $TEMPLATES| jq . | grep -e '"itemid":' | sed 's/"//g' | sed 's/,//g'| sed 's/[[:space:]]//g' | cut -d: -f2)
echo $RESULT |  sed 's/ /\n/g' >> listadelldid.txt

for i in $(cat listadetemplates.txt); do VALOR=$(echo $i | cut -f1); updatelld.sh ${VALOR}; done | jq
