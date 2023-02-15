#!/bin/bash

zabbix_user="user"
zabbix_pass="pass"
zabbix_api="url"

zabbix_auth_token=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)


itemget=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"item.get\",
    \"params\": {
        \"output\": \"extend\",
        \"hostids\": \"17963\",
        \"search\": {
            \"key_\": \"$1\"
        },
        \"sortfield\": \"name\"
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result[].itemid | sed s'/"//g' > teste.dennis
)

teste=$(cat teste.dennis | head -n1)
if [ -z $teste ];
then
        echo "$1: não encontrado" >> log
        echo "$1: não encontrado"
else

for i in $(cat teste.dennis);
do
    value=$(echo $i);
result=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"item.update\",
    \"params\": {
        \"itemid\": \"${value}\",
        \"status\": 1
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}
)

echo "Interface $1 desabilitada"
done
fi

logout=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.logout\",
    \"params\": [],
    \"id\": 1,
    \"auth\": \"${zabbix_auth_token}\"
}" ${zabbix_api})

echo $result
