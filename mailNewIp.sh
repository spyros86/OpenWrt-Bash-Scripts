#!/bin/bash

#Hastily written script that senses an IP change and notifies via email.
#You must have bash installed among other packages. 
#OpenWrt has none of them by default.
#Install with opkg

DDNSUSER=$1;
DDNSPASS=$2;
EMAILTO=$3;


echo "Starting IP CHECK"
ping -c 1  www.google.gr > /dev/null 2>&1
if [ $? != 0 ]
then 
	exit 1
fi

#get ip
echo "curl start:"
ip="`curl http://icanhazip.com`"
echo ":curl end"

#do the first check
while read line
do
  if [ "$line" != "" ] && [ $line == $ip ]
  then
    printf "Nothing to send!\nEXITING!\nNew ip is: $ip\nOld ip is: $line\n"
    exit 1
  fi
done < "/www/ip.html"

echo "Going to send new ip: $ip"

#if the ip is not the same create the data and send the mail

#get date
dat=`date`

#get uptime
upt="`uptime`"

dfh="`df -h`"
pse="`top -n 1 -b`"
free="`free`"
lsof="`lsof -i`"

#clients="`iw dev wlan0 station dump`"
clients="No wifi enabled"
dhcp="`cat /tmp/dhcp.leases`"
transmission="nothing"
#"`transmission-remote -l`"

while read line
do 
	#echo $line;
	#echo $ip;
        #do another check again.
	if [ "$line" == "" ] || [ $line != $ip ]
		then
                        echo "Sending Mail with new IP!"
			echo -e "From: router@home.home\nTo: $EMAILTO\nSubject: Your IP Has Changed Sir $dat\nReply-to: nowhere@no.no\nContent-Type: text/html; charset=\"UTF-8\"\nMime-Version: 1.0;\nContent-Transfer-Encoding: 8bit; \n\n<html><body><p><h2>Time:</h2>\n$dat\n</p><p><h2>IP: </h2>\n$ip \n</p><p><h2>uptime:</h2>\n$upt</p><h2>Memory:</h2><pre style=\"font-size:12pt;color:blue;\" >\n$free</pre><p><h2>df:\n</h2></p><pre style=\"font-size:12pt;color:blue;\" >\n$dfh</pre><p><h2>Top:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$pse\n\n\n</pre><p><h2>lsof -i:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$lsof\n\n\n</pre><p><h2>dhcp:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$dhcp\n\n\n</pre><p><h2>clients:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$clients\n\n\n</pre><p><h2>transmission:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$transmission\n\n\n</pre></body></html> " | msmtp --from=default -t $EMAILTO ;

	fi
done  < "/www/ip.html"
echo "Mail with new ip sent"
echo "IP CHECK END"
echo "Sending new ip to opendns..."
/usr/bin/curl -k -s -u $DDNSUSER:$DDNSPASS https://updates.opendns.com/nic/update?hostname=tsardi > /dev/null 2>&1
echo "SCRIPT STOP"
if [ -z "$ip" ]; then
	echo "10.0.0.0" > /www/ip.html
else
	echo $ip > /www/ip.html
fi
