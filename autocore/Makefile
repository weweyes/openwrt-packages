#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autocore
PKG_VERSION:=1
PKG_RELEASE:=35


include $(INCLUDE_DIR)/package.mk

define Package/autocore
  TITLE:=x86/x64 auto core loadbalance script.
  MAINTAINER:=Lean
  DEPENDS:=@(TARGET_bcm27xx||TARGET_bcm53xx||TARGET_ipq40xx||TARGET_ipq806x||TARGET_rockchip||TARGET_x86) \
	+ethtool \
	+TARGET_x86:bc \
	+TARGET_x86:lm-sensors \
    +TARGET_bcm53xx:nvram \
    +TARGET_ipq40xx:lm-sensors

endef

define Package/autocore/description
A usb autoconfig hotplug script.
endef

define Build/Compile
endef

define Package/autocore/install
	$(INSTALL_DIR) $(1)/sbin
	$(CP) ./files/sbin/* $(1)/sbin
endef

$(eval $(call BuildPackage,autocore))
