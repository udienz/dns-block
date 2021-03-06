#!/bin/bash

BASE=/srv/archive.mahyudd.in
DLDIRTO=$BASE/shallalist/
DLFILETO=$DLDIRTO/BL.tar.gz
EXTARCTDIR=$BASE/uncompress
#SRCDL=http://archive.mahyudd.in/dns-block/BL.tar.gz
SRCDL=http://www.shallalist.de/Downloads/shallalist.tar.gz
#CATEGORIES="aggressive"
CATEGORIES="adv aggressive drugs gamble hacking porn sex/lingerie spyware tracker updatesites violence warez "
OUTDIR=$BASE/out
ZONEDIR=$OUTDIR/zones
CONFDIR=$OUTDIR/conf

make_domain () {
cat > $ZONEDIR/$1/$2.zone.tmp<<EOF
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
mv $ZONEDIR/$1/$2.zone.tmp $ZONEDIR/$1/$2.zone
}

make_zoneconf () {
cat >>$CONFDIR/$1.conf.tmp<<EOF
zone "$2" {
	type master;
	file "/srv/bind/zone/$1/$2.zone";
};

EOF
}

cek_dir_exist () {
	if [ ! -d $1 ];
	then
	mkdir -p $1
fi
}

cd $BASE/shallalist/
wget $SRCDL -N
#wget $SRCDL -O $DLFILETO -c

if [ "$?" = "0" ]; then

	echo 'Successfully download proper file'
	mv $BASE/shallalist/shallalist.tar.gz $DLFILETO
	cd $BASE
	tar -xzf $DLFILETO -C $EXTARCTDIR
	mkdir -p $ZONEDIR $CONFDIR
	for kategori in $CATEGORIES
		do
		echo "build $kategori"
		cek_dir_exist $ZONEDIR/$kategori

		grep -v [0-9]$ $EXTARCTDIR/BL/$kategori/domains | sed -e '/\//d' | while read bl
			do
				#make domain here
				if [ ! -f $ZONEDIR/$kategori/$bl.zone ];
					then
					make_domain $kategori $bl
				fi
				make_zoneconf $kategori $bl
			done
				cd $ZONEDIR
				mv $CONFDIR/$kategori.conf.tmp $CONFDIR/$kategori.conf
				tar cJf $ZONEDIR/$kategori.xz.tmp $kategori/
				mv $ZONEDIR/$kategori.xz.tmp $ZONEDIR/$kategori.xz
				cd $CONFDIR
				tar cJf $CONFDIR/$kategori.xz.tmp $kategori.conf
				mv $CONFDIR/$kategori.xz.tmp $CONFDIR/$kategori.xz
		done
else
	echo 'cannot download files'
	exit 0
fi
