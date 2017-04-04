#!/bin/bash

#Hastily written script that sends multiple stats and a pair of camera shots to your email.
#You must have bash installed among other packages. 
#OpenWrt has none of them by default.
#Install with opkg

PASSWORD=$1;
EMAILTO=$2;

#Check if WAN connection is online
#You might want to disable this
ping  -q -c 1  www.google.gr > /dev/null 2>&1
if [ $? != 0 ]
then 
	exit 1
fi

######Get camera images######

#Camera IPs
ip[0]='10.11.10.2'
ip[1]='10.11.10.3'
ip[2]='10.11.10.4'
ip[3]='10.11.10.5'
ip[4]='10.11.10.9'
ip[5]='10.11.10.10'
ip[6]='10.11.10.11'
ip[7]='10.11.10.12'
ip[8]='10.11.10.13'

#Delete old camera images
rm /root/imagegrab/*.jpg
rm /root/cameraPics.tar.gz

#create the files so they are ready (router is so slow this is mandatory).
#Iterate through the camera IPs and touch the files.
for ip in "${ip[@]}"
do
	touch /root/imagegrab/$ip.jpg
done

#Try to get the images.
#If a camera is offline (10 tries) continue.
for ip in "${ip[@]}"
do
	i=0
	#While no image is present repeat - hack hack hack
	while [ `du /root/imagegrab/$ip.jpg | cut -f 0` -lt 15  ]
	do
		  echo $i
		  wget --tries=5 --http-user=admin --http-password=$PASSWORD --output-document=/root/imagegrab/$ip.jpg  http://$ip/image.jpg
		  let "i++"
		  if [ $i -gt 10 ]
		  then
		      break
		  fi
	done
done

#Create camera pics archive
tar -cvzf /root/cameraPics.tar.gz /root/imagegrab/*.jpg

######Get various stats######
#get ip
ip="`curl http://icanhazip.com`"

#get date
dat=`date`

#get uptime
upt="`uptime`"

#disk usage
dfh="`df -h`"

#just a top
pse="`top -n 1 -b`"

#memory
free="`free`"

#Open network connections
lsof="`lsof -i`"

#clients="`iw dev wlan0 station dump`"
clients="Wireless is disabled"

#dhcp leases
dhcp="`cat /tmp/dhcp.leases`"

#Torrents
transmission="no transmission daemon installed"
#"`transmission-remote -l`"


#Try to send the emails (2).
#Do not beautify the lines below - OpenWrt does not like it.
	
		
			echo -e "From: router@home.home\nTo: $EMAILTO\nSubject: Your IP Sir $dat\nReply-to: nowhere@no.no\nContent-Type: text/html; charset=\"UTF-8\"\nMime-Version: 1.0;\nContent-Transfer-Encoding: 8bit; \n\n<html><body><p><h2>Time:</h2>\n$dat\n</p><p><h2>IP: </h2>\n$ip \n</p><p><h2>uptime:</h2>\n$upt</p><h2>Memory:</h2><pre style=\"font-size:12pt;color:blue;\" >\n$free</pre><p><h2>df:\n</h2></p><pre style=\"font-size:12pt;color:blue;\" >\n$dfh</pre><p><h2>Top:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$pse\n\n\n</pre><p><h2>lsof -i:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$lsof\n\n\n</pre><p><h2>dhcp:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$dhcp\n\n\n</pre><p><h2>clients:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$clients\n\n\n</pre><p><h2>transmission:</h2>\n</p><pre style=\"font-size:12pt;color:blue;\" >$transmission\n\n\n</pre></body></html> " | msmtp --from=default -t $EMAILTO ;
                       echo -e "Cameras $dat" |  mutt $EMAILTO -s "Camera Pics $dat" -a /root/cameraPics.tar.gz > /dev/null 2>&1



echo "Hourly mail has been sent"

