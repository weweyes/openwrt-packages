#
# Copyright (C) 2020 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qtbase
PKG_BASE:=5.15
PKG_BUGFIX:=1
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://mirrors.tuna.tsinghua.edu.cn/qt/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://qt.mirror.constant.com/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/qtbase/Default
	SECTION:=libs
	CATEGORY:=Libraries
	SUBMENU:=Qt5
	TITLE:=qtbase
	URL:=http://qt-project.org
	DEPENDS:=+libstdcpp @!LINUX_2_6_36
endef

define Package/qtbase/description
  This package provides the Qt5 libraries.

  Qt is a cross-platform application development framework for desktop, embedded and mobile.
  Supported Platforms include Linux, OS X, Windows, VxWorks, QNX, Android, iOS, BlackBerry,
  Sailfish OS and others.

  Qt is not a programming language on its own. It is a framework written in C++.

  This package provides the following run-time libraries:
  - core
  - network
  - xml
endef

define Package/qtbase
	$(call Package/qtbase/Default)
	TITLE+=all libs
	DEPENDS+=$(QTBASE_DEPENDS)
endef

define Package/qtbase/install
	true
endef

EXTRA_CFLAGS += $(FPIC) -ffunction-sections -fdata-sections -flto
EXTRA_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS = \
		-hostprefix $(STAGING_DIR_HOSTPKG) \
		-sysroot $(STAGING_DIR) \
		-prefix /usr \
		-plugindir /usr/lib/Qt/plugins \
		-I $(STAGING_DIR)/usr/include \
		-I $(TOOLCHAIN_DIR)/usr/include \
		-L $(STAGING_DIR)/usr/lib \
		-L $(STAGING_DIR)/lib \
		-L $(TOOLCHAIN_DIR)/lib \
		-device linux-generic-g++ \
		-device-option CROSS_COMPILE="$(TARGET_CROSS)" \
		-device-option COMPILER_FLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
		-device-option LINKER_FLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
		-confirm-license \
		-opensource \
		-release \
		-shared \
		-strip \
		-no-rpath \
		-no-use-gold-linker \
		-ltcg \
		-openssl-linked \
		-qt-doubleconversion \
		-system-pcre \
		-system-zlib \
		-no-angle \
		-no-cups \
		-no-dbus \
		-no-directfb \
		-no-dtls\
		-no-egl \
		-no-eglfs \
		-no-freetype \
		-no-gbm \
		-no-glib \
		-no-gtk \
		-no-gui \
		-no-harfbuzz \
		-no-iconv \
		-no-icu \
		-no-kms \
		-no-libjpeg \
		-no-libpng \
		-no-libudev \
		-no-mtdev \
		-no-opengl \
		-no-opengles3 \
		-no-openvg \
		-no-pch \
		-no-slog2 \
		-no-sql-db2 \
		-no-sql-ibase \
		-no-sql-mysql \
		-no-sql-oci \
		-no-sql-odbc \
		-no-sql-psql \
		-no-sql-sqlite \
		-no-sql-sqlite2 \
		-no-sql-tds \
		-no-sqlite \
		-no-tslib \
		-no-vulkan \
		-no-widgets \
		-no-xcb \
		-no-xcb-xlib \
		-no-xkbcommon \
		-no-compile-examples \
		-no-feature-concurrent \
		-make libs \
		-nomake examples \
		-nomake tests \
		-nomake tools \
		-v

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(MAKE) -C $(PKG_BUILD_DIR) install
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/bin/qt.conf $(STAGING_DIR_HOSTPKG)/bin
endef

define DefineQtbaseLibrary
  QTBASE_DEPENDS+=+qt5-$(1)

  QTBASE_LIBS+=$(1)

  define Package/qt5-$(1)
    $(call Package/qtbase/Default)
    TITLE+=$(1)
    DEPENDS+=$$(foreach lib,$(2),+qt5-$$(lib)) $(3)
    HIDDEN:=1
  endef

  define Package/qt5-$(1)/description
   This package contains the qt5 $(1) library.
  endef
endef

$(eval $(call DefineQtbaseLibrary,core,,+libatomic +libpcre2-16 +zlib +libzstd))
$(eval $(call DefineQtbaseLibrary,network,core,+libopenssl +zlib))
$(eval $(call DefineQtbaseLibrary,xml,core,))

define Package/qtbase/Default/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libQt5$(shell echo $(2) | sed -e 's/\b[[:alpha:]]/\u&/g').so* $(1)/usr/lib/
endef

define BuildQtbaseLibrary
  define Package/qt5-$(1)/install
    $(call Package/qtbase/Default/install,$$(1),$(1))
  endef

  $$(eval $$(call BuildPackage,qt5-$(1)))
endef

$(foreach lib,$(QTBASE_LIBS),$(eval $(call BuildQtbaseLibrary,$(lib))))
$(eval $(call BuildPackage,qtbase))
