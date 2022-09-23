#!/bin/bash

yum install -y zabbix-java-gateway

sed -i 's/# JavaGatewayPort=10052/JavaGatewayPort=10052/' /etc/zabbix/zabbix_server.conf
sed -i 's/# StartJavaPollers=0/StartJavaPollers=20/' /etc/zabbix/zabbix_server.conf
sed -i 's/# JavaGateway=/JavaGateway=127.0.0.1/' /etc/zabbix/zabbix_server.conf

wget http://www.java2s.com/Code/JarDownload/jmxremote/jmxremote_optional.jar.zip

unzip ~/jmxremote_optional.jar.zip

cp ~/jmxremote_optional.jar /usr/share/zabbix-java-gateway/lib

systemctl enable --now zabbix-java-gateway

pcs resource restart zbx_service
