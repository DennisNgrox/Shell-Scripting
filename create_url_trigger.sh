#!/bin/bash

zabbix_user="admin"
zabbix_pass="zabbix"
zabbix_api="http://ip/api_jsonrpc.php"
host="$1"
url="$2"



zabbix_auth_token=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)

hostid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.create\",
    \"params\": {
        \"host\": \"${host}\",
        \"interfaces\": [
            {
                \"type\": 1,
                \"main\": 1,
                \"useip\": 1,
                \"ip\": \"127.0.0.1\",
                \"dns\": \"\",
                \"port\": \"10050\"
            }
        ],
        \"groups\": [
            {
                \"groupid\": \"1049\"
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.hostids[] | sed s'/"//g')

echo "Host \"$1\" criado, id: $hostid"

webscenario=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"httptest.create\",
    \"params\": {
        \"name\": \"monitoring\",
        \"hostid\": \"${hostid}\",
        \"http_proxy\": \"proxy.br\",
        \"steps\": [
            {
                \"name\": \"Check URL\",
                \"url\": \"https://$url\",
                \"status_codes\": \"200\",
       \"timeout\": \"60s\",
                \"no\": 1
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| jq .result.httptestids[] | sed s'/"//g')

echo "Webscenario com a URL \"$2\" criado, id: $webscenario"

echo "--------------------------------------------------------------------------"

zabbix_auth_token=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${zabbix_user}"\",\"password\":\""${zabbix_pass}"\"},\"auth\": null,\"id\":0}" $zabbix_api |  jq -r .result)


hostid=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"output\": \"["hostid"]\",
        \"filter\": {
            \"host\": [
                \"${host}\"
            ]
        }
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| awk -F\" '{print $10}')

httpget=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"httptest.get\",
    \"params\": {
        \"hostids\": \"${hostid}\",
        \"output\": \"extend\",
        \"selectSteps\": \"extend\"
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api})

httptestid=$(echo ${httpget} | jq .result[].httptestid | sed s'/"//g')
httpstepid=$(echo ${httpget} | jq .result[].steps[].httpstepid | sed s'/"//g')

sleep 3

httptestupdate=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"httptest.update\",
    \"params\": {
        \"httptestid\": \"${httptestid}\",
        \"name\": \"monitoring\",
        \"steps\": [
            {
               \"name\": \"Check URL\",
      \"url\": \"http://$url\",
      \"status_codes\": \"200\",
      \"timeout\": \"60s\"
            }
       ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.httptestids[])

echo=${httptestupdate}

echo "Webscenario alterado para: monitoring, steps alterado para: Check URL -- id: ${httptestupdate}"


triggercreateseverity4one=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": [
        {
            \"description\": \"[MONITOR URL(teste)] 5 status code diferente 200 no periodo de 5 minutos - URL\",
            \"expression\": \"{${host}:web.test.rspcode[monitoring,Check URL].count(5m,200,ne)}=5\",
            \"priority\": \"3\",
            \"comments\": \"Trigger Description: teste\",
            \"tags\": [
                {
                    \"tag\": \"ticket_action\",
                    \"value\": \"CA-SDM\"
                },
                {
                    \"tag\": \"tag_novo_monitor\",
                    \"value\": \"alerta_incidente\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.triggerids[] | sed s'/"//g')

echo "Criado trigger 1 - severidade 3 - id: ${triggercreateseverity4one}"
triggercreateseverity4two=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": [
        {
            \"description\": \"[MONITOR URL(teste)] 8 status code diferente 200 no periodo de 10 minutos - URL\",
            \"expression\": \"{${host}:web.test.rspcode[monitoring,Check URL].count(10m,200,ne)}=8\",
            \"priority\": \"3\",
            \"comments\": \"Trigger Description: teste\",
            \"tags\": [
                {
                    \"tag\": \"ticket_action\",
                    \"value\": \"teste\"
                },
                {
                    \"tag\": \"teste\",
                    \"value\": \"alerta\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.triggerids[] | sed s'/"//g')

echo "Criado trigger 2 - severidade 3 - id: ${triggercreateseverity4two}"


logout=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
        \"method\": \"user.logout\",
   \"params\": [],
       \"id\": 1,
   \"auth\": \"${zabbix_auth_token}\"
}" ${zabbix_api})
