#!/bin/bash

#set -x

BASE=/srv/archive.mahyudd.in
DLDIRTO=$BASE/shallalist/
DLFILETO=$DLDIRTO/BL.tar.gz
EXTARCTDIR=$BASE/uncompress
SRCDL=http://www.shallalist.de/Downloads/shallalist.tar.gz
CATEGORIES="aggressive"
#CATEGORIES="adv aggressive drugs gamble hacking porn sex/lingerie spyware tracker updatesites violence warez "
OUTDIR=$BASE/www/BL
ZONEDIR=$OUTDIR/zones
CONFDIR=$OUTDIR/conf

make_domain () {
cat > $ZONEDIR/$1/$2.zone<<EOF
\$TTL 86400
$2.   86400   IN      SOA     ns.sby.rad.net.id.      udienz.rad.net.id.      (
                                                `date +%Y%m%d%H%M` ;Serial Number
                                                86400 ;refresh
                                                7200 ;retry
                                                604800 ;expire
                                                86400 ;minimum
        )
;
; Zone NS Records
;
$2.   86400   IN      NS      ns.sby.rad.net.id.
$2.   86400   IN      NS      ns1.sby.rad.net.id.
$2.   86400   IN      NS      ns2.sby.rad.net.id.
$2.   14400   IN      A       127.0.0.1
EOF
}

make_zoneconf () {
cat >>$CONFDIR/$1.conf<<EOF
zone "$2" {
	type master;
	file "/srv/bind/zone/$1/$2.zone";
}

EOF
}

cek_file_exist () {
	if [ -f $1 ];
		then
		rm $1
	fi
}

cek_dir_exist () {
	if [ ! -d $1 ];
	then
	mkdir -p $1
fi
}

#cek_file_exist $DLFILETO

#wget $SRCDL -O $DLFILETO -c
wget -N -O $DLFILETO $SRCDL
if [ "$?" = "0" ]; then
	echo 'remote have newer list'
	tar -xzf $DLFILETO -C $EXTARCTDIR
	mkdir -p $ZONEDIR $CONFDIR
	for kategori in $CATEGORIES
		do
		echo "build $kategori"
		grep -v [0-9]$ $EXTARCTDIR/BL/$kategori/domains | sed -e '/\//d' | while read bl
			do
				#make domain here
				cek_dir_exist $ZONEDIR/$kategori
				cek_file_exist $CONFDIR/$kategori/$bl
				make_domain $kategori $bl
				make_zoneconf $kategori $bl
			done
				set -x
				tar -czf $ZONEDIR/$kategori.tar.gz $ZONEDIR/$kategori/
				tar -czf $CONFDIR/$kategori.tar.gz $CONFDIR/$kategori.conf
				set +x
		done
else
	echo 'remote does not have newer file'
	exit 0
fi
