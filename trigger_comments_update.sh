#!/bin/bash


zabbix_user="Admin"
zabbix_pass="pass"
zabbix_api="http://192.168.32.128/zabbix/api_jsonrpc.php"
primeiro=$1


zabbix_auth_token=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)

hostid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\", #Se for a nível de host, alterar para host.get
    \"params\": {
        \"output\": \"["hostid"]\",
        \"filter\": {
            \"host\": [
                \"${primeiro}\"
            ]
        }
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}')

triggerid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.get\",
    \"params\": {
        \"hostids\": \"${hostid}\",
        \"output\": [\"triggerid\"]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result[].triggerid | sed s'/"//g' >> file.triggers)

for i in $(cat file.triggers);
do
  value=$(echo $i);
    comment=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
   {
        \"jsonrpc\": \"2.0\",
        \"method\": \"trigger.update\",
        \"params\": {
            \"triggerid\": \"${value}\",
            \"comments\": \"[Zabbix] Monitoracao de cluster, Monitor: Disponibilidade do Cluster, Intervalo: 5 minutos\" #Alterar para o que deseja
        },
        \"auth\": \"${zabbix_auth_token}\",
        \"id\": 1
    }" ${zabbix_api})



echo $comment

done

logout=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
        \"jsonrpc\": \"2.0\",
        \"method\": \"user.logout\",
        \"params\": [],
        \"id\": 1,
        \"auth\": \"${zabbix_auth_token}\"
}" ${zabbix_api})
