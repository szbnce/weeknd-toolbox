#!/bin/sh

rm -rf \
	boot.img \
	*.dtb \
	dtbo.img \
	lk2nd.img \
	vbmeta.img \
	initramfs.cpio.gz \
	key.pem pkmd.bin \
	Image.gz-dtb

if [ "$1" = "--all" ]; then
	rm -rf linux lk2nd rootfs/sbin stock_vbmeta.img
fi
