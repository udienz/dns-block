#!/bin/bash

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