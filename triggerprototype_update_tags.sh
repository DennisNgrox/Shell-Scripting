#!/bin/bash

zabbix_user="Admin"
zabbix_pass="ip"
zabbix_api="http://ip/api_jsonrpc.php"
PRIMEIRO=$1
SEGUNDO=$2


zabbix_auth_token=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)

hostid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {
        \"output\": \"["hostid"]\",
        \"filter\": {
            \"host\": [
                \"${PRIMEIRO}\"
            ]
        }
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}') 

discoveryid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.get\",
    \"params\": {
        \"output\": [\"itemid\"],
        \"hostids\": [\"${hostid}\"]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| jq .result[].itemid | sed s'/"//g' > teste)

for i in $(cat teste)
do 
    value=$(echo $i);
    triggerid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
        {
        \"jsonrpc\": \"2.0\",
        \"method\": \"triggerprototype.get\",
        \"params\": {
            \"output\": [\"triggerid\"],
            \"discoveryids\": \"${value}\"
        },
        \"auth\": \"${zabbix_auth_token}\",
        \"id\": 1
        }" ${zabbix_api} | jq .result[].triggerid | sed s'/"//g' > valor.trigger);

    for a in $(cat valor.trigger);
    do
         trigguer_value=$(echo $a);
         tagupdate=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
        {
            \"jsonrpc\": \"2.0\",
            \"method\": \"triggerprototype.update\",
            \"params\": {
                \"triggerid\": \"${trigger_value}\",
                \"tags\": [
                    {
                        \"tag\": \"integ_itsm_grp\",
                        \"value\": \"${SEGUNDO}\"
                    },
                    {
                        \"tag\": \"integ_itsm_src\",
                        \"value\": \"remota\"
                    },
                    {
                        \"tag\": \"integ_itsm_type\",
                        \"value\": \"cluster\"
                    }
                ]
            },
            \"auth\": \"${zabbix_auth_token}\",
            \"id\": 1
        }" ${zabbix_api}| awk -F\" '{print $10}');

        echo $tagupdate
done
done
