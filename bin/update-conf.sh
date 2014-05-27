#!/bin/bash
# 2014 Mahyuddin Susanto

# Helper script to update bind configurations
# Please inset this conf to /etc/{named|bind9}/named.conf
# with 
# include "/srv/bind/conf/$category";

set -x

CATEGORIES="adv aggressive drugs gamble hacking porn sex/lingerie spyware tracker updatesites violence warez"
URLBASE="http://archive.mahyudd.in/dns-block"
BASE=/srv/bind/

mkdir -p $BASE/zone $BASE/conf

for a in $CATEGORIES
do
	echo 'Downloading zones'
	mkdir $BASE/zone/$a -p
	wget -O /tmp/$a-zone.xz $URLBASE/zones/$a.xz
	tar xJfv /tmp/$a-zone.xz -C $BASE/zone/$a
	wget -O /tmp/$a-conf.xz $URLBASE/conf/$a.xz
	tar xJfv /tmp/$a-conf.xz -C $BASE/conf/$a
	rm /tmp/$a-*.xz -f
done

if [ -f /etc/debian_version ]; then
       service bind9 reload
elif [ -f /etc/redhat-release]; then
       service named reload
else
	echo 'Failed to detect distro, please reload named/bind manually'
fi
