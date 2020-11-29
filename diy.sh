sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' */Makefile
rm -Rf */antileech/src/* && git clone https://github.com/persmule/amule-dlp.antiLeech antileech/src
sed -i '/\/etc\/config\/AdGuardHome/a /etc/config/AdGuardHome.yaml'  luci-app-adguardhome/Makefile
sed -i 's/+rclone\( \|$\)/+rclone +fuse-utils\1/g' luci-app-rclone/Makefile
sed -i 's/shadowsocksr-libev-alt/shadowsocksr-libev-redir/g' */Makefile
sed -i 's/shadowsocksr-libev-ssr-local/shadowsocksr-libev-local/g' */Makefile
sed -i 's/ca-certificates/ca-bundle/g' */Makefile
sed -i 's/ +kmod-fs-exfat//g' automount/Makefile
sed -i 's/ @!BUSYBOX_DEFAULT_IP:/ +/g' wrtbwmon/Makefile
find */luasrc/view/ -maxdepth 2 -name "*.htm" | xargs -i sed -i 's?"http://" + window.location.hostname?window.location.protocol + "//" + window.location.hostname?g' {}
getversion(){
ver=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/$1/releases/latest) | grep -o -E "[0-9].+")
[ $ver ] && echo $ver || git ls-remote --tags git://github.com/$1 | cut -d/ -f3- | sort -t. -nk1,2 -k3 | awk '/^[^{]*$/{version=$1}END{print version}' | grep -o -E "[0-9].+"
}
#sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(getversion v2fly/v2ray-core)/g" v2ray/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(getversion AdguardTeam/AdGuardHome)/g" AdGuardHome/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(getversion c0re100/qBittorrent-Enhanced-Edition)/g" qBittorrent-Enhanced-Edition/Makefile
sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" */Makefile
find / -maxdepth 2 -name "Makefile" | xargs -i sed -i "s/SUBDIRS=/M=/g" {}
