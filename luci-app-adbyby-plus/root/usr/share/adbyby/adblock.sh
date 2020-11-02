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
	cat /tmp/adnew.conf | grep ^\|\|[^\*]*\^$ | grep -Ev "^\|\|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}*" | sed -e 's:||:address=/:' -e 's:\^:/:' > /tmp/ad.conf
	rm -f /tmp/adnew.conf
}

down(){
	G=/tmp/ad_tmp/rules
	F=$G/ad_new.conf
	rm -rf ${G%/*}
	mkdir -p $G
	for i in $URL;do
		if curl -Lfso $F $i;then
			sed -i -e 's:#.*::' -e 's:!.*::' -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e '/^$/d' $F
			if grep -q "^address=" $F;then
				cat $F >> $G/3rd.conf
			elif grep -q -e "^0.0.0.0 " -e "^127.0.0.1 " $F;then
				cat $F >> $G/host
			else
				cat $F | grep ^\|\|[^\*]*\^$ | grep -Ev "^\|\|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}*" | sed -e 's:||:address=/:' -e 's:\^:/:' >> $G/3rd.conf
			fi
		fi
		echo $i >> $G/url
	done
	[ -s $G/host ] && sed -e '/ localhost$/d' -e 's:127.0.0.1 :address=/:' -e 's:0.0.0.0 :address=/:' -e 's:$:/:' $G/host >> $G/3rd.conf
	[ -s $G/3rd.conf ] && echo "`sort -u $G/3rd.conf`" > $G/3rd.conf && sed -i -e 's:/127.0.0.1$:/:' -e 's:/0.0.0.0$:/:' $G/3rd.conf
	[ -s $G/url ] && echo "`sort -u $G/url`" > $G/url
	if [ -s $G/3rd.conf -a -s $P/dnsmasq/dnsmasq.adblock ];then
		echo "`sort -u $G/3rd.conf $P/dnsmasq/dnsmasq.adblock`" > $G/3rd.conf
		echo "`sort $G/3rd.conf $P/dnsmasq/dnsmasq.adblock | uniq -u`" > $G/3rd.conf
	fi
	if [ -s $G/3rd.conf ];then
		C=1
		rm -f $F $G/host
		[ "$1" = 1 ] && rm -f $LOCK && exit
		X=`uci -q get adbyby.@adbyby[0].flash`
		Y=`md5sum $G/* | awk '{print $1}'`
		[ "$X" = 0 ] && Z=`md5sum $P/rules/* 2>/dev/null | awk '{print $1}'` || Z=`md5sum /etc/adbyby_conf/rules/* 2>/dev/null | awk '{print $1}'`
		if [ "$Y" != "$Z" ];then
			if [ "$X" = 0 ];then
				rm -f $P/rules/*
				cp -a $G $P
			else
				rm -f /etc/adbyby_conf/rules/*
				cp -a $G /etc/adbyby_conf
			fi
			E=1
		fi
	fi
	rm -rf ${G%/*}
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
	G=`curl -LSfso /tmp/adnew.conf https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/easylistchina%2Beasylist.txt 2>&1 || curl -LSfso /tmp/adnew.conf https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt 2>&1`
	if [ $? = 0 ];then
		echo "`eval $DATE` [$A Successful]"
		gen
		if [ -s /tmp/ad.conf ] && ! cmp -s /tmp/ad.conf $P/dnsmasq/dnsmasq.adblock;then
			cp -f /tmp/ad.conf $P/dnsmasq/dnsmasq.adblock
			D=1
		fi
	else
		echo "`eval $DATE` [$A Failed]"
		echo -e "$G\n"
	fi
	rm -f /tmp/ad.conf
fi
if [ -n "$URL" ];then
	down
	[ $C = 1 ] && echo "`eval $DATE` [$B Successful]" || echo "`eval $DATE` [$B Failed]"
fi

rm -f $LOCK
$P/adupdate.sh $D $E
