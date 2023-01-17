#!/bin/bash


#5 ° Preciso da Triggerid para update de tags
#4 ° Preciso do DiscoveryID para get da trigger // FEITO
#3 ° Preciso do Hostids para get do discoveryID // FEITO
#2 ° Lista com nome dos templates. // FEITO COM $1 --- Realiza utilizando: sed 
#1 ° Fazer template.get // FEITO


zabbix_user="Admin"
zabbix_pass="Sales@2022"
zabbix_api="http://ip/api_jsonrpc.php"


zabbix_auth_token=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)

hostid=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {
        \"output\": \"["hostid"]\",
        \"filter\": {
            \"host\": [
                \"$1\"
            ]
        }
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}') 

discoveryid=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.get\",
    \"params\": {
        \"output\": [\"itemid\"],
        \"hostids\": [\"${hostid}\"]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}')


triggerid=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"triggerprototype.get\",
    \"params\": {
        \"output\": [\"triggerid\"],
        \"discoveryids\": \"${discoveryid}\"
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | awk -F\" '{print $10}')


tagupdate=$(curl -s -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"triggerprototype.update\",
    \"params\": {
        \"triggerid\": \"${triggerid}\",
        \"tags\": [
            {
                \"tag\": \"dennis\",
                \"value\": \"dennis\"
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}')

echo $tagupdate
