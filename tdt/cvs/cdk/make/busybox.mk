#
# busybox
#
$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ $(buildprefix)/Patches/busybox.config$(if $(UFS912)$(UFS913)$(SPARK)$(SPARK7162),_nandwrite)
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
<<<<<<< HEAD
=======
		patch -p1 < ../Patches/busybox-1.22.1-ash.patch && \
		patch -p1 < ../Patches/busybox-1.22.1-date.patch && \
		patch -p1 < ../Patches/busybox-1.22.1-iplink.patch && \
		patch -p1 < ../Patches/busybox-1.22.1-nc.patch && \
>>>>>>> cf6429b... busybox patch added
		$(INSTALL) -m644 $(lastword $^) .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(targetprefix)"#' .config
	cd @DIR_busybox@ && \
		export CROSS_COMPILE=$(target)- && \
		$(MAKE) all \
			CROSS_COMPILE=$(target)- \
			CONFIG_EXTRA_CFLAGS="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
#	@DISTCLEANUP_busybox@
	touch $@
