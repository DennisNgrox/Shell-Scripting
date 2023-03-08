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
               \"name\": \"Check URL\"
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
            \"description\": \"name trigger\",
            \"expression\": \"{${host}:web.test.rspcode[monitoring,Check URL].count(10m,200,ne)}=10\",
            \"priority\": \"4\",
            \"comments\": \"URL: https://${url}\",
            \"tags\": [
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                },
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api} | jq .result.triggerids[] | sed s'/"//g')



triggercreateseverity4two=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
        \"jsonrpc\": \"2.0\",
        \"method\": \"trigger.create\",
        \"params\": [
        {
           \"description\": \"Name trigger\",
            \"expression\": \"{${host}:web.test.time[monitoring,Check URL,resp].last()}>=10\",
            \"priority\": \"4\",
            \"comments\": \"URL: https://${url}\",
            \"tags\": [
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                },
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                }
            ]
        }
        ],
        \"auth\": \"${zabbix_auth_token}\",
        \"id\": 1
}" ${zabbix_api} | jq .result.triggerids[] | sed s'/"//g')

triggercreateseverity2one=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
        \"jsonrpc\": \"2.0\",
        \"method\": \"trigger.create\",
        \"params\": [
        {
            \"description\": \"Name triggers\",
            \"expression\": \"{${host}:web.test.rspcode[monitoring,Check URL].count(10m,200,ne)}>=5\",
            \"priority\": \"2\",
            \"comments\": \"URL: https://${url}\",
            \"dependencies\": [
                {
                    \"triggerid\": \"${triggercreateseverity4one}\"
                }
            ],
            \"tags\": [
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                },
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api})


triggercreateseverity2two=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
        \"jsonrpc\": \"2.0\",
        \"method\": \"trigger.create\",
        \"params\": [
        {
            \"description\": \"Name Trigger\",
            \"expression\": \"{${host}:web.test.time[monitoring,Check URL,resp].last()}>=5\",
            \"priority\": \"2\",
            \"comments\": \"URL: https://${url}\",
            \"dependencies\": [
                {
                    \"triggerid\": \"${triggercreateseverity4two}\"
                }
            ],
            \"tags\": [
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                },
                {
                    \"tag\": \"teste\",
                    \"value\": \"teste\"
                }
            ]
        }
    ],
    \"auth\": \"${zabbix_auth_token}\",
    \"id\": 1
}" ${zabbix_api})

logout=$(curl -s -k -H  'Content-Type: application/json-rpc' -d "
{
        \"jsonrpc\": \"2.0\",
        \"method\": \"user.logout\",
        \"params\": [],
        \"id\": 1,
        \"auth\": \"${zabbix_auth_token}\"
}" ${zabbix_api})

echo $logout
