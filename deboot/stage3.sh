#!/bin/bash -ex

# set locale
echo 'LANG="en_US.UTF-8"' > /etc/default/locale
locale-gen en_US.UTF-8
dpkg-reconfigure -f noninteractive locales

# set timezone
echo "tzdata tzdata/Areas select Etc" > /tmp/tmptz
echo "tzdata tzdata/Zones/Etc select UTC" >> /tmp/tmptz
debconf-set-selections /tmp/tmptz
rm -f /etc/timezone
rm -f /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
rm -f /tmp/tmptz

# set default hostname
echo localhost > /etc/hostname

# create user and passwd
useradd -m -d /home/pp -s /bin/bash pp
gpasswd -a pp sudo
echo -e "papaya\npapaya\n" | passwd pp

# overwrite apt source list
rm -f /etc/apt/sources.list
echo deb     http://ports.ubuntu.com/ubuntu-ports xenial          main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://ports.ubuntu.com/ubuntu-ports xenial          main restricted universe multiverse >> /etc/apt/sources.list
echo deb     http://ports.ubuntu.com/ubuntu-ports xenial-updates  main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://ports.ubuntu.com/ubuntu-ports xenial-updates  main restricted universe multiverse >> /etc/apt/sources.list
echo deb     http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted universe multiverse >> /etc/apt/sources.list

