#!/bin/sh
# Author: Affe Null
# SPDX-License-Identifier: MIT
set -e

repo="https://github.com/affenull2345/linux"

if [ ! -d linux ]; then
	git clone --depth 1 -b wip/qm215/6.3-rc7 "$repo" linux
fi

cd linux
cp ../defconfig .config
make ARCH=arm64 ${JOBS:+-j$JOBS}
# make ARCH=arm64 modules_install INSTALL_MOD_PATH=../rootfs
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/qm215-nokia-weeknd.dtb > ../Image.gz-dtb
