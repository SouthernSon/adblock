#!/bin/sh 

#---Ad block script for DD-WRT using dnsmasq

TMPPATH=/tmp/tmphosts
HOSTPATH=/tmp/adhosts
CONFPATH=/tmp/dnsmasq.conf

{
wget -O - 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext'
wget -O - 'http://www.mvps.org/winhelp2002/hosts.txt'
wget -O - http://www.malwaredomainlist.com/hostslist/hosts.txt
} > $TMPPATH

#Format downloaded lists for hosts file.
#UUOC, don't care. Change if you like.
cat $TMPPATH | sed 's/127.0.0.1/0.0.0.0/g' | grep 0.0.0.0 | grep -v localhost | sed -e 's/#.*$//' | sort | uniq -u > $HOSTPATH

rm $TMPPATH

#Example below removes sites you may need from the list, add other sites accordingly.
sed -i /"adf.ly"/d "$HOSTPATH"

#Add entry to dnsmasq conf file.
echo "addn-hosts=$HOSTPATH" >> $CONFPATH

#Kill and reload dnsmasq. These are the options DD-WRT uses at startup.
killall dnsmasq
sleep 1
dnsmasq -u root -g root --conf-file=$CONFPATH
