#!/bin/bash

zabbix_user="user"
zabbix_pass="pass"
zabbix_api="http://ip/api_jsonrpc.php"
host=$1
url=$2



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
                \"groupid\": \"50\"
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| jq .result.hostids[] | sed s'/"//g')

echo $hostid

webscenario=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"httptest.create\",
    \"params\": {
        \"name\": \"monitoring\",
        \"hostid\": \"${hostid}\",
        \"steps\": [
            {
                \"name\": \"Check URL\",
                \"url\": \"https://${url}\",
                \"status_codes\": \"200\",
                \"no\": 1
            }
        ]
    },
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api}| jq .result.httptestids[] | sed s'/"//g')

echo $w ebscenario
