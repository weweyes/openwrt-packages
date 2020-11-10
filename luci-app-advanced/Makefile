include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for advanced and filebrowser
LUCI_DEPENDS:=
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0-or-later

define Package/luci-app-advanced/conffiles
/etc/config/advanced
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
