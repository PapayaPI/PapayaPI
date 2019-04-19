
echo "creating partitions..."

_DEV="$1"
_ROOTFS="rootfs"
_DISTRO="deboot/rootfs-xenial-armhf_20190312_152112.tgz"
_UBOOT="u-boot/u-boot-sunxi-with-spl.bin"
_IMAGE="linux/arch/arm/boot/zImage"
_DTB="linux/arch/arm/boot/dts/sun8i-v3s-papayapi.dtb"
_CMD="papaya_boot/boot.scr"
if [ -z $_DEV ];then echo "SD Card Device not specifed!" && exit;fi
if [ -e $_DISTRO ]
		then
		      echo "Checking the DISTRO file - in place!"
		else  echo "Can not find DISTRO file!"   && exit
	     fi
if [ -e $_UBOOT ]
		then
		      echo "Checking the U-BOOT file - in place!"
		else  echo "Can not find U-BOOT file!"   && exit
	     fi
if [ -e $_IMAGE ]
		then
		      echo "Checking the zImage file - in place!"
		else  echo "Can not find UzImage file!"   && exit
	     fi
if [ -e $_DTB ]
		then
		      echo "Checking the DTB file - in place!"
		else  echo "Can not find DTB file!"   && exit
	     fi
if [ -e $_CMD ]
		then
		      echo "Checking the CMD file - in place!"
		else  echo "Can not find CMD file!"   && exit
	     fi

umount /dev/${_DEV}1
umount /dev/${_DEV}2

dd if=/dev/zero of=/dev/$_DEV count=100000

cat  <<EOT | fdisk /dev/$_DEV
n
p
1

34815
n
p



w
EOT

sleep 10
sync
partx -u /dev/$_DEV
sync
mkfs.vfat  /dev/${_DEV}1 ||exit
fatlabel /dev/${_DEV}1 BOOT
sleep 5
sync
mkfs.ext4  -O ^64bit -q -m 2 /dev/${_DEV}2 ||exit
tune2fs -L rootfs /dev/${_DEV}2
sleep 5
sync
dd if=$_UBOOT of=/dev/$_DEV bs=1024 seek=8
sleep 5
sync

mkdir p1
mkdir p2

mount /dev/${_DEV}1 p1
mount /dev/${_DEV}2 p2

rm -rf  p1/*
rm -rf  p2/*

cp -af $_CMD p1
cp -af $_DTB p1
cp -af $_IMAGE p1

mkdir rootfs
cd $_ROOTFS
tar -zxvf ../$_DISTRO --exclude=sys --exclude=proc --exclude=tmp --exclude=mnt --exclude=sys --exclude=dev --exclude=run

# add support for rtl8192cu Wifi
mkdir lib/firmware
mkdir lib/firmware/rtlwifi
cp ../rtl8192cufw_TMSC.bin  lib/firmware/rtlwifi/

cd ..
cp -af $_ROOTFS/* p2

sync

umount p1 p2 
rm -rf p1
rm -rf p2
rm -rf rootfs


