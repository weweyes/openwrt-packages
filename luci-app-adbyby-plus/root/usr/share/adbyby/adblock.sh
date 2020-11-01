#!/bin/sh
# 防止重复启动
LOCK=/var/lock/adbyby.lock
[ -f $LOCK -a "$1" != addown ] && exit 1
if ! mount | grep adbyby >/dev/null 2>&1;then
	echo "Adbyby is not Mounted,Stop Update!"
	exit 1
fi
touch $LOCK

gen(){
	cat /tmp/adnew.conf | grep ^\|\|[^\*]*\^$ | grep -Ev "^\|\|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}*" | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/ad.conf
	rm -f /tmp/adnew.conf
}

down(){
	TMP=/tmp/ad_tmp/rules
	rm -rf ${TMP%/*}
	mkdir -p $TMP
	for i in $URL;do
		if curl -Lfso $TMP/ad_new.conf $i;then
			if grep -wq "address=" $TMP/ad_new.conf;then
				cat $TMP/ad_new.conf >> $TMP/3rd.conf
			elif grep -wq -e"0.0.0.0" -e"127.0.0.1" $TMP/ad_new.conf;then
				cat $TMP/ad_new.conf >> $TMP/3rd.host
			else
				cat $TMP/ad_new.conf | grep ^\|\|[^\*]*\^$ | grep -Ev "^\|\|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}*" | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' >> $TMP/3rd.conf
			fi
		fi
		echo $i >> $TMP/url
	done
	[ -s $TMP/3rd.conf ] && echo "`sort -u $TMP/3rd.conf`" > $TMP/3rd.conf && sed -i '/^$/d' $TMP/3rd.conf
	[ -s $TMP/3rd.host ] && echo "`sort -u $TMP/3rd.host`" > $TMP/3rd.host && sed -i -e '/localhost/d' -e '/#/d' -e '/^$/d' $TMP/3rd.host
	[ -s $TMP/url ] && echo "`sort -u $TMP/url`" > $TMP/url
	if [ -s $TMP/3rd.conf -a -s $P/dnsmasq/dnsmasq.adblock ];then
		echo "`sort -u $TMP/3rd.conf $P/dnsmasq/dnsmasq.adblock`" > $TMP/3rd.conf
		echo "`sort $TMP/3rd.conf $P/dnsmasq/dnsmasq.adblock | uniq -u`" > $TMP/3rd.conf
	fi
	if [ -s $TMP/3rd.conf -o -s $TMP/3rd.host ];then
		C=1
		rm -f $TMP/ad_new.conf
		[ "$1" = 1 ] && rm -f $LOCK && exit
		X=`uci -q get adbyby.@adbyby[0].flash`
		Y=`md5sum $TMP/* | awk '{print $1}'`
		[ "$X" = 0 ] && Z=`md5sum $P/rules/* 2>/dev/null | awk '{print $1}'` || Z=`md5sum /etc/adbyby_conf/rules/* 2>/dev/null | awk '{print $1}'`
		if [ "$Y" != "$Z" ];then
			if [ "$X" = 0 ];then
				rm -f $P/rules/*
				cp -a $TMP $P
			else
				rm -f /etc/adbyby_conf/rules/*
				cp -a $TMP /etc/adbyby_conf
			fi
			E=1
		fi
	fi
	rm -rf ${TMP%/*}
}

A="Download Adblock Plus Rules"
B="Download Subscribe Rules"
C=0
D=0
E=0
DATE="date +'%Y-%m-%d %H:%M:%S'"
URL=`uci -q get adbyby.@adbyby[0].url`
P=/tmp/adbyby

if [ "$1" = addown ];then
	down
	exit
elif [ "$1" = down ];then
	down 1
elif [ "$1" = gen ];then
	gen
	rm -f $LOCK
	exit
fi
if [ "`uci -q get adbyby.@adbyby[0].wan_mode`" = 1 ];then
	TMP=`curl -LSfso /tmp/adnew.conf https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/easylistchina%2Beasylist.txt 2>&1 || curl -LSfso /tmp/adnew.conf https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt 2>&1`
	if [ $? = 0 ];then
		echo "`eval $DATE` [$A Successful]"
		gen
		if [ -s /tmp/ad.conf ] && ! cmp -s /tmp/ad.conf $P/dnsmasq/dnsmasq.adblock;then
			cp -f /tmp/ad.conf $P/dnsmasq/dnsmasq.adblock
			D=1
		fi
	else
		echo "`eval $DATE` [$A Failed]"
		echo -e "$TMP\n"
	fi
	rm -f /tmp/ad.conf
fi
if [ -n "$URL" ];then
	down
	[ $C = 1 ] && echo "`eval $DATE` [$B Successful]" || echo "`eval $DATE` [$B Failed]"
fi

rm -f $LOCK
$P/adupdate.sh $D $E
