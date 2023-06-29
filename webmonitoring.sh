#!/bin/bash

zabbix_user="API_ZABBIX_PROD"
zabbix_pass="Ageri@2022"
zabbix_api="http://zabbix-web/api_jsonrpc.php"
url=$(echo "$1" | sed s'/http:\/\///g')
host=$(echo "$1" | sed s'/\./_/g' | sed s'/:/_/g' | sed s'/\//_/g' | sed s'/-/_/g')



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
                \"groupid\": \"648\"
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.hostids[] | sed s'/"//g')

echo "Host $1 criado: $hostid"

webscenario=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"httptest.create\",
    \"params\": {
        \"name\": \"monitoring\",
        \"hostid\": \"${hostid}\",
        \"http_proxy\": \"prxwg.portoseguro.brasil:3128\",
        \"steps\": [
            {
                \"name\": \"Check URL\",
                \"url\": \"http://$url\",
                \"status_codes\": \"200\",
                        \"timeout\": \"60s\",
                \"no\": 1
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| jq .result.httptestids[] | sed s'/"//g')

echo "Webscenario com a URL $2 criado: $webscenario"

echo "------------------------------------------------------"

echo $1
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
               \"url\": \"https://$url\",
               \"status_codes\": \"200\",
               \"timeout\": \"60s\"
            }
       ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api})


echo "Webscenario alterado para: monitoring, steps alterado para: Check URL - ${httptestupdate}"


triggercreateseverity4one=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": [
        {
            \"description\": \"[WEB] Falha no webscenario $1\",
            \"expression\": \"{${host}:web.test.rspcode[monitoring,Check URL].last()}<>200\",
            \"priority\": \"4\",
            \"comments\": \"Trigger Description:\",
            \"tags\": [
                {
                    \"tag\": \"monitor_url_incidente\",
                    \"value\": \"value\"
                },
                {
                    \"tag\": \"tag_novo_monitor\",
                    \"value\": \"value\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.triggerids[] | sed s'/"//g')

echo "Criado trigger 1 - severidade 4 - ${triggercreateseverity4one}"

logout=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
        \"method\": \"user.logout\",
            \"params\": [],
                \"id\": 1,
                    \"auth\": \"${zabbix_auth_token}\"
}" ${zabbix_api})
