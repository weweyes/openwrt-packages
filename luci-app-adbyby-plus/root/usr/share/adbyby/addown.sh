#!/bin/sh
[ "$1" = --down ] || exit 1
mount | grep adbyby >/dev/null 2>&1 || exit 1
# 防止重复启动
LOCK=/var/lock/adbyby.lock
[ -f $LOCK ] && exit 1
touch $LOCK

for a in $(opkg print-architecture | awk '{print $2}');do
	case $a in
		all|noarch);;
		arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_fa526|arm_xscale|armeb_xscale)ARCH=arm;P=2p;;
		aarch64_cortex-a53|aarch64_cortex-a72|aarch64_generic|arm_cortex-a15_neon-vfpv4|arm_cortex-a5_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_mpcore|arm_mpcore_vfp)ARCH=armv7;P=4p;;
		mips_24kc|mips_mips32|mips64_mips64|mips64_octeon)ARCH=mips;P=6p;;
		mipsel_24kc|mipsel_24kec_dsp|mipsel_74kc|mipsel_mips32|mipsel_1004kc_dsp)ARCH=mipsel;P=8p;;
		x86_64)ARCH=x64;P=10p;;
		i386_pentium|i386_pentium4)ARCH=x86;P=12p;;
		*)exit 1;;
	esac
done

CURL="curl -Lfso"
A=https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master
B=https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules
C=https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master
D=/tmp/adbyby
E=/tmp/adupdate.log
DATE="date +'%Y-%m-%d %H:%M:%S'"

echo "`eval $DATE` [Download Adbyby BIN File]" > $E
while ! $CURL $D/adbyby $A/$ARCH;do
	sleep 2
done
chmod +x $D/adbyby

echo "`eval $DATE` [Download Adbyby BIN MD5 File]" >> $E
while ! $CURL $D/md5 $A/md5;do
	sleep 2
done

md5_local=$(md5sum $D/adbyby | awk -F' ' '{print $1}')
md5_online=$(sed 's/":"/\n/g' $D/md5 | sed 's/","/\n/g' | sed -n "$P")
[ "$md5_local" != "$md5_online" ] && A=1 && rm -f $D/adbyby

if [ "$(head -1 $D/data/lazy.txt | awk -F' ' '{print $3,$4}')" = "2017-1-2 00:12:25" ];then
	echo "`eval $DATE` [Download Adbyby Formal Rules]" >> $E
	while ! ($CURL $D/data/lazy.txt $B/lazy.txt || $CURL $D/data/lazy.txt $C/lazy.txt);do
		sleep 2
	done
	echo "`eval $DATE` [Download Adbyby Beta Rules]" >> $E
	while ! ($CURL $D/data/video.txt $B/video.txt || $CURL $D/data/video.txt $C/video.txt);do
		sleep 2
	done
fi

if [ "$(uci -q get adbyby.@adbyby[0].wan_mode)" = 1 ];then
	mkdir -p $D/dnsmasq
	echo "`eval $DATE` [Download Adblock Plus Rules]" >> $E
	while ! $CURL $D/dnsmasq/dnsmasq.adblock $A/dnsmasq.adblock;do
		sleep 2
	done
	echo "`eval $DATE` [Download Adblock Plus MD5 File]" >> $E
	while ! $CURL $D/md5 $A/md5_1;do
		sleep 2
	done
	md5_local=$(md5sum $D/dnsmasq/dnsmasq.adblock | awk -F' ' '{print $1}')
	md5_online=$(sed 's/":"/\n/g' $D/md5 | sed 's/","/\n/g' | sed -n '2P')
	rm -f $D/md5
	[ "$md5_local" != "$md5_online" ] && A=1 && rm -rf $D/dnsmasq
fi

if [ "$2" = 1 ];then
	echo "`eval $DATE` [Download Subscribe Rules]" >> $E
	$D/adblock.sh addown
fi

[ $A = 1 ] || (echo "`eval $DATE` [Start Adbyby Plus+]" >> $E;echo `eval $DATE` > $D/adbyby.updated)
rm -f $LOCK
/etc/init.d/adbyby start &
