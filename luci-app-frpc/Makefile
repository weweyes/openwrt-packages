#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI for FRPC
LUCI_DEPENDS:=+wget +frpc
LUCI_PKGARCH:=all
PKG_VERSION:=git-99.289.33737-a2c7457
PKG_RELEASE:=1

define Package/luci-app-frpc/conffiles
/etc/config/frp
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


