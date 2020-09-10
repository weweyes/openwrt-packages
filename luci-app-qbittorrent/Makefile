# Copyright (C) 2019 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for qBittorrent
LUCI_DEPENDS:=+qBittorrent-Enhanced-Edition
LUCI_PKGARCH:=all

define Package/luci-app-qbittorrent/conffiles
/etc/config/qbittorrent
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
