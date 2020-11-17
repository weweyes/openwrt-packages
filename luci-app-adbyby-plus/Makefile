# Copyright (C) 2020 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Adbyby
LUCI_DEPENDS:=+adbyby +wget +ipset +dnsmasq-full
LUCI_PKGARCH:=all
PKG_NAME:=luci-app-adbyby-plus
PKG_VERSION:=2.0
PKG_RELEASE:=72

define Package/luci-app-adbyby-plus/conffiles
/etc/config/adbyby
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

