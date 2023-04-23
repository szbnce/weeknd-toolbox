#!/bin/sh

cd "$(dirname "$0")"

if [ ! -f pkmd.bin ] || [ ! -f vbmeta.img ] || [ ! -f lk2nd.img ]; then
	echo 'Please run build.sh first.'
	exit 1
fi

if [ "$(fastboot devices)" = "" ]; then
	echo
	echo '[!] Please power off the device and plug it in with the volume-down key pressed'
	echo
fi

fastboot oem sudo
fastboot flash avb_custom_key pkmd.bin
fastboot flash vbmeta vbmeta.img
fastboot flash recovery lk2nd.img
echo
echo '[!] Please hold the volume-up key... Will reboot in 5 seconds...'
sleep 5
fastboot reboot
sleep 3
echo
echo '[*] You may now release the volume-up key.'
echo
fastboot boot boot.img
