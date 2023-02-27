#!/bin/bash

# Monitoring OLT Huawei x7

# Ip of OLT
ip=$1

# Port of OLT
port=$2

# Comunidade da OLT
community=$3

# Oid
oid="1.3.6.1.4.1.2011.6.128.1.1.2.46.1.15"


# Request
clientes_total=$(snmpwalk -v2c -c ${community} ${ip}:${port} ${oid} | grep -c ".*")
clientes_online=$(snmpwalk -v2c -c ${community} ${ip}:${port} ${oid} | grep -c "INTEGER: 1")
clientes_offline=$(snmpwalk -v2c -c ${community} ${ip}:${port} ${oid} | grep -c "INTEGER: 2")
clientes_loss=$(snmpwalk -v2c -c ${community} ${ip}:${port} ${oid} | grep -c "INTEGER: 0")

# Send value to Zabbix
zabbix_sender -z 10.61.20.10 -s "$4" -k pontotal -o "${clientes_total}"
zabbix_sender -z 10.61.20.10 -s "$4" -k pononline -o "${clientes_online}"
zabbix_sender -z 10.61.20.10 -s "$4" -k ponoffline -o "${clientes_offline}"
zabbix_sender -z 10.61.20.10 -s "$4" -k ponloss -o "${clientes_loss}"
