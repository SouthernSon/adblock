#!/bin/sh 
#---Ad block script for DD-WRT using dnsmasq

hostspath="/tmp"
tmpfile="$hostspath/tmphosts"
hostfile="$hostspath/adhosts"
conffile="$hostspath/dnsmasq.conf"
logfile="$hostspath/adblock.log"

>$tmpfile
>$hostfile
>$logfile

#Wget will fail during startup when under load
#adjust sleep time below for your router
sleep 20

#Add additional sources for ad providers here
wget -O - "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext" >> $tmpfile 2>>$logfile
wget -O - "http://www.mvps.org/winhelp2002/hosts.txt" >> $tmpfile 2>>$logfile
wget -O - "http://www.malwaredomainlist.com/hostslist/hosts.txt" >> $tmpfile 2>>$logfile

#Format lists for hosts file and remove comments, create hosts file
#and remove temp file
sed -e 's/#.*$//' -e 's/127.0.0.1/0.0.0.0/g' $tmpfile | grep 0.0.0.0 | 
grep -v localhost | sort | uniq -u >> $hostfile

rm $tmpfile

#Remove hosts from the list you may need
sed -i /"adf.ly"/d "$hostfile"

echo "addn-hosts=$hostfile" >> $conffile

#Kill and reload dnsmasq. For some reason if user not specified dnsmasq will
#start as nobody. Must explicitly define user,group, and config file. 
#These are the options DD-WRT uses at startup
killall dnsmasq
sleep 1
dnsmasq -u root -g root --conf-file=$conffile
