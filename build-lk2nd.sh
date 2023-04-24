#!/bin/sh
# Author: Affe Null
# SPDX-License-Identifier: MIT
set -e

repo="https://github.com/msm8916-mainline/lk2nd"

if [ ! -d lk2nd ]; then
	git clone --depth 1 -b experimental-tmp2 "$repo" lk2nd
fi

cd lk2nd
rm -rf lk2nd/device/dts/msm8952
ln -s ../../../../lk2nd-dts-msm8952 lk2nd/device/dts/msm8952
make lk2nd-msm8952 LK2ND_PARTITION_BASE=recovery
