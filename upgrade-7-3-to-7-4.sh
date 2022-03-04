
# Live upgrade from a 7.3 install to a 7.4 install

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env

# If you are using this script

echo ======= Update 1
apt-get update

apt-get install -y build-essential python-software-properties software-properties-common
apt-get install -y byobu curl git htop man unzip vim wget
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

echo ======= Update 2
apt-get update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2

echo ======= Update 3
apt-get update

echo This is intended to be run interactively

apt-get install php7.4 libapache2-mod-php7.4 php7.4-cli php7.4-opcache php7.4-readline php7.4-common php7.4-mysql php7.4-curl php7.4-json php7.4-mbstring php7.4-zip php7.4-xml php7.4-gd php7.4-apc php7.4-intl php7.4-memcache php7.4-memcached

cat << EOF

If the software installed correctly, do the following steps manually to switch php versions:

a2dismod php7.3
a2enmod php7.4
systemctl restart apache2

Then check with info.php to make sure you have PHP 7.4

To make sure you are running PHP 7.4 at the command line use

update-alternatives --config php

EOF

