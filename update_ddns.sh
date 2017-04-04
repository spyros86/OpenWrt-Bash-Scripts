#!/bin/bash
NET1=$1
NET2=$2

/usr/lib/ddns/dynamic_dns_updater.sh $NET1 0
/usr/lib/ddns/dynamic_dns_updater.sh $NET2 0
exit
