#!/bin/sh
# Author: Affe Null
# SPDX-License-Identifier: MIT
set -e
cd "$(dirname "$0")"

step=0

step() {
	step=$((step+1))
	echo ">> [$step] $*"
}

needs() {
	if [ -f "$1" ]; then
		echo ">> OK       $1"
		return 1
	else
		echo ">> creating $1"
		return 0
	fi
}

step linux

if needs Image.gz-dtb; then
	./build-linux.sh
fi

step lk2nd

if needs lk2nd/build-lk2nd-msm8952/lk.bin-dtb; then
	./build-lk2nd.sh
fi

step busybox

mkdir -p rootfs/sbin

if needs rootfs/sbin/busybox; then
	wget -Orootfs/sbin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv8l
fi

for cmd in \
	sh \
	ls \
	mkdir \
	ln \
	cat \
	dd \
	grep \
	sed \
	clear \
	resize \
	fold \
	tail \
	head \
	sleep \
	dmesg \
	mount \
	umount \
	poweroff
do
	ln -sf busybox rootfs/sbin/$cmd
done

chmod +x rootfs/sbin/busybox

step initramfs

(cd rootfs && find . | cpio -o -H newc -R 0:0) | gzip > initramfs.cpio.gz

step boot image

python3 mkbootimg.py -o boot.img \
	--kernel Image.gz-dtb \
	--ramdisk initramfs.cpio.gz \
	--cmdline 'console=tty1 rw loglevel=7 fbcon=font:10x18'

step device tree overlay

overlays=""
for ovname in wnd1 wnd2e wnd2; do
	if needs overlay-$ovname.dtb; then
		dtc -o overlay-$ovname.dtb overlay-$ovname.dts
	fi
	overlays="$overlays overlay-$ovname.dtb"
done

if needs dtbo.img; then
	python3 mkdtboimg.py create dtbo.img $overlays
fi

step lk2nd image

python3 mkbootimg.py -o lk2nd.img \
	--kernel lk2nd/build-lk2nd-msm8952/lk.bin-dtb \
	--cmdline 'lk2nd' \
	--header_version 1 \
	--recovery_dtbo dtbo.img

dd if=boot.img of=lk2nd.img seek=512 bs=1024

step vbmeta image

if needs stock_vbmeta.img; then
	wget -Ostock_vbmeta.img https://storage.abscue.de/private/zImage/wnd-vbmeta.img
fi

if needs vbmeta.img; then
	openssl genrsa 2048 > key.pem
	python3 avbtool.py extract_public_key --key key.pem --output pkmd.bin
	python3 avbtool.py make_vbmeta_image \
		--padding_size 4096 \
		--algorithm SHA512_RSA2048 \
		--key key.pem \
		--public_key_metadata pkmd.bin \
		--output vbmeta.img \
		--include_descriptors_from_image stock_vbmeta.img \
		--set_hashtree_disabled_flag
fi

step "Done!"
