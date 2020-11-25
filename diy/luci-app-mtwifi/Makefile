include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mtwifi
LUCI_TITLE:=LuCI support for mt wifi driver
PKG_VERSION:=1
PKG_RELEASE:=17
PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=Hua Shao <nossiac@163.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=LuCI
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for mt wifi driver
  DEPENDS:=@TARGET_ramips +mt_wifi
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	LuCI support for mt wifi driver.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/wireless/mt7615/
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DATA) ./root/usr/lib/lua/mtkwifi.lua $(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/admin_mtk
	$(INSTALL_DATA) ./luasrc/view/admin_mtk/*.htm $(1)/usr/lib/lua/luci/view/admin_mtk/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./root/sbin/mtkwifi $(1)/sbin/mtkwifi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
