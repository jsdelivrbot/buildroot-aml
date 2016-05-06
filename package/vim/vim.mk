################################################################################
#
# vim
#
################################################################################

# 7.4 release patchlevel 889
VIM_VERSION = 74b738d414b2895b3365e26ae3b7792eb82ccf47
VIM_SITE = $(call github,vim,vim,$(VIM_VERSION))
# Win over busybox vi since vim is more feature-rich
VIM_DEPENDENCIES = \
	ncurses $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) \
	$(if $(BR2_PACKAGE_BUSYBOX),busybox)
VIM_SUBDIR = src
VIM_CONF_ENV = \
	vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes \
	vim_cv_tty_group=world \
	vim_cv_tty_mode=0620 \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=yes \
	vim_cv_memmove_handles_overlap=yes \
	ac_cv_sizeof_int=4 \
	ac_cv_small_wchar_t=no
# GUI/X11 headers leak from the host so forcibly disable them
VIM_CONF_OPTS = --with-tlib=ncurses --enable-gui=no --without-x
VIM_LICENSE = Charityware
VIM_LICENSE_FILES = README.txt

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
VIM_CONF_OPTS += --enable-selinux
VIM_DEPENDENCIES += libselinux
else
VIM_CONF_OPTS += --disable-selinux
endif

define VIM_INSTALL_TARGET_CMDS
	cd $(@D)/src; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installvimbin; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installtools; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installlinks
endef

define VIM_INSTALL_RUNTIME_CMDS
	cd $(@D)/src; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installrtbase; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installmacros
endef

define VIM_REMOVE_DOCS
	find $(TARGET_DIR)/usr/share/vim -type f -name "*.txt" -delete
endef

# Avoid oopses with vipw/vigr, lack of $EDITOR and 'vi' command expectation
define VIM_INSTALL_VI_SYMLINK
	ln -sf /usr/bin/vim $(TARGET_DIR)/bin/vi
endef
VIM_POST_INSTALL_TARGET_HOOKS += VIM_INSTALL_VI_SYMLINK

define VIM_INSTALL_VIMRC
	cp $(TOPDIR)/package/vim/vimrc $(TARGET_DIR)/.vimrc
endef

ifeq ($(BR2_PACKAGE_VIM_RUNTIME),y)
VIM_POST_INSTALL_TARGET_HOOKS += VIM_INSTALL_RUNTIME_CMDS
VIM_POST_INSTALL_TARGET_HOOKS += VIM_REMOVE_DOCS
VIM_POST_INSTALL_TARGET_HOOKS += VIM_INSTALL_VIMRC
endif

$(eval $(autotools-package))
