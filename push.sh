#!/bin/bash
clear
scp hardenaudit.sh hardenauditfunctions.sh xmlfunctions.sh root@192.168.100.21:/root/
scp report.xsl root@192.168.100.21:/var/www/html/
ssh root@192.168.100.21 "/root/hardenaudit.sh"
ssh root@192.168.100.21 "cp /root/report.xml /var/www/html/"


