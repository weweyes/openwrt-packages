#!/bin/sh
# 防止重复启动
LOCK=/var/lock/adbyby.lock
[ -f $LOCK ] && exit 1
if ! mount | grep adbyby >/dev/null 2>&1;then
	echo "Adbyby is not Mounted,Stop Update!"
	exit 1
fi
touch $LOCK

A=0
DATE="date +'%Y-%m-%d %H:%M:%S'"
CURL="curl -LSfso"
CDN=https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules
COD=https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master
GIT=https://raw.githubusercontent.com/adbyby/xwhyc-rules/master
P=/tmp/adbyby
MD5=$P/md5.json
MD5_L=$P/local-md5.json

RES(){
	echo "`eval $DATE` [Reload Adbyby Rules]"
	kill -9 $(ps -w | grep $P/adbyby | grep -v grep | awk '{print $1}') 2>/dev/null
	$P/adbyby >/dev/null 2>&1 &
}

SUB(){
	echo "`eval $DATE` [Subscribe Rules Need Update]"
	rm -f /tmp/dnsmasq.adbyby/05-3rd.conf;sed -i '/3rd/d' /tmp/dnsmasq.d/dnsmasq-adbyby.conf
	B=`uci -q get adbyby.@adbyby[0].flash`
	if [ "$B" = 1 ];then
		[ -s /etc/adbyby_conf/rules/3rd.conf ] && ln -sf /etc/adbyby_conf/rules/3rd.conf $P/rules/3rd.conf
		ln -sf /etc/adbyby_conf/rules/url $P/rules/url
	fi
	[ -s $P/rules/3rd.conf ] && ln -sf $P/rules/3rd.conf /tmp/dnsmasq.adbyby/05-3rd.conf
}

rm -f $P/data/*.bak
md5sum $P/data/lazy.txt $P/data/video.txt > $MD5_L

TMP=`$CURL $MD5 $CDN/md5.json 2>&1 || $CURL $MD5 $COD/md5.json 2>&1 || $CURL $MD5 $GIT/md5.json 2>&1`
if [ $? = 0 ];then
	echo "`eval $DATE` [Download Adbyby MD5 File Successful]"
	lazy_local=$(grep 'lazy' $MD5_L | awk -F' ' '{print $1}')
	video_local=$(grep 'video' $MD5_L | awk -F' ' '{print $1}')  
	lazy_online=$(sed 's/":"/\n/g' $MD5 | sed 's/","/\n/g' | sed -n '2p')
	video_online=$(sed 's/":"/\n/g' $MD5 | sed 's/","/\n/g' | sed -n '4p')
	if [ "$lazy_online" != "$lazy_local" ];then
		TMP=`$CURL /tmp/lazy.txt $CDN/lazy.txt 2>&1 || $CURL /tmp/lazy.txt $COD/lazy.txt 2>&1 || $CURL /tmp/lazy.txt $GIT/lazy.txt 2>&1`
		if [ $? = 0 ];then
			echo "`eval $DATE` [Download Adbyby Formal Rules Successful]"
			mv -f /tmp/lazy.txt $P/data/lazy.txt
			A=1
		else
			echo "`eval $DATE` [Download Adbyby Formal Rules Failed]"
			echo -e "$TMP\n"
		fi
	fi
	if [ "$video_online" != "$video_local" ];then
		TMP=`$CURL /tmp/video.txt $CDN/video.txt 2>&1 || $CURL /tmp/video.txt $COD/video.txt 2>&1 || $CURL /tmp/video.txt $GIT/video.txt 2>&1`
		if [ $? = 0 ];then
			echo "`eval $DATE` [Download Adbyby Beta Rules Successful]"
			mv -f /tmp/video.txt $P/data/video.txt
			A=1
		else
			echo "`eval $DATE` [Download Adbyby Beta Rules Failed]"
			echo -e "$TMP\n"
		fi
	fi
else
	echo "`eval $DATE` [Download Adbyby MD5 File Failed]"
	echo -e "$TMP\n"
fi

echo `eval $DATE` > $P/adbyby.updated

if [ "$1" = 1 -a "$2" = 1 -a $A = 1 ];then
	echo "`eval $DATE` [All Rules Need Update]"
	echo "`eval $DATE` [Restart Adbyby Plus+]"
	/etc/init.d/adbyby restart
	C=1
elif [ "$1" = 0 -a "$2" = 0 -a $A = 0 ];then
	echo "`eval $DATE` [All Rules No Change]"
	C=1
elif [ -z "$1" -a -z "$2" ];then
	[ $A = 0 ] && echo "`eval $DATE` [Adbyby Rules No Change]" || RES
	C=1
fi
[ "$C" = 1 ] && rm -f $LOCK $MD5_L $MD5 && exit

C=0
D=0
if [ "$1" = 1 ];then
	echo "`eval $DATE` [Adblock Plus Rules Need Update]"
	C=1
else
	echo "`eval $DATE` [Adblock Plus Rules No Change]"
fi
if [ "$2" = 1 ];then
	SUB
	C=1
else
	echo "`eval $DATE` [Subscribe Rules No Change]"
fi
if [ $A = 1 ];then
	echo "`eval $DATE` [Adbyby Rules Need Update]"
	D=1
else
	echo "`eval $DATE` [Adbyby Rules No Change]"
fi
if [ $C = 1 -a $D = 0 ];then
	echo "`eval $DATE` [Restart Dnsmasq]"
	/etc/init.d/dnsmasq restart >/dev/null 2>&1
elif [ $C = 1 -a $D = 1 ];then
	echo "`eval $DATE` [Restart Adbyby Plus+]"
	/etc/init.d/adbyby restart
else
	RES
fi

rm -f $LOCK $MD5_L $MD5
