#!/bin/bash
# Termux Downloader
# Downloads packages from termux repository (attempts to resolve dependencies)
# 2024/08/06 ArlingtonBrooks

PKG=$1

#Refresh packages list
if [[ $(find "Packages" -mtime +5 -print) ]]; then
	echo "Packages file is older than 5 days; refreshing packages file."
	rm Packages
fi
wget -c -nv --show-progress "https://packages.termux.dev/apt/termux-main/dists/stable/main/binary-aarch64/Packages"

BaseUrl="https://packages.termux.dev/apt/termux-main/"

GetDepends() {
	echo "GetDepends $1"
	local PkgLines=$(grep -A 10 -m 1 "Package: $1" Packages)
	local Depends=$(echo "$PkgLines" | grep "Depends: " | cut -d':' -f 2 | tr ',' ' ' | xargs)
	local Url=$(echo "$PkgLines" | grep Filename | cut -d' ' -f 2)

	for F in $Depends; do
		GetDepends "$F"
	done
	wget -nc -nv --show-progress "${BaseUrl}${Url}"
}

CheckIntegrity() {
	local SUCCESS=0
	local FAIL=0
	local MD5=""
	local MD5Mine=""

	echo "Checking MD5Sums"
	for F in *.deb; do
		MD5=$(grep -m 1 -A 10 "$F" ./Packages | grep MD5sum | cut -d' ' -f 2)
		MD5Mine=$(md5sum "$F" | cut -d' ' -f 1)
		if [ "$MD5" == "$MD5Mine" ]; then
			SUCCESS=$(expr $SUCCESS + 1)
		else
			FAIL=$(expr $FAIL + 1)
			echo "$F failed MD5 check"
			echo "$MD5 != $MD5Mine"
		fi
	done

	echo "Checking SHA256 Sums"
	for F in *.deb; do
		MD5=$(grep -m 1 -A 10 "$F" ./Packages | grep SHA256 | cut -d' ' -f 2)
		MD5Mine=$(sha256sum "$F" | cut -d' ' -f 1)
		if [ "$MD5" == "$MD5Mine" ]; then
			SUCCESS=$(expr $SUCCESS + 1)
		else
			FAIL=$(expr $FAIL + 1)
			echo "$F failed MD5 check"
			echo "$MD5 != $MD5Mine"
		fi
	done

	if [ $FAIL != 0 ]; then
		echo "####################################"
		echo "Some packages did not pass checksum!"
		echo " Somebody may be trying to pwn you!"
		echo "####################################"
	fi
}

GetDepends $1
CheckIntegrity

echo "Completed package downloads."
