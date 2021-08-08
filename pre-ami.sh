# Setup a scalable app server instance behind ELB
# Leave hostname alone

# Start from https://github.com/tsugiproject/tsugi-build/docker/base/tsugi-base-prepare.sh
# /Users/csev/dev/tsugi-build/docker/base/tsugi-base-prepare.sh

sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env
echo ======= Update 1
apt -y update

echo ======= Upgrade
apt upgrade
apt-get install -y build-essential
apt-get install -y software-properties-common
apt-get install -y byobu curl git htop man unzip vim wget
apt-get install -y apt-utils
apt-get install -y mysql-client-8.0
apt-get install -y nfs-common
if [ ! -f "/usr/bin/crontab" ]; then
    apt-get install -y cron
fi
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

echo ======= Update 2
apt update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y universe
apt update
apt-get install -y apache2
apt-get install -y php8.0
apt-get install -y libapache2-mod-php8.0 php8.0-mysql php8.0-curl
apt-get install -y php8.0-mbstring php8.0-zip php8.0-xml php8.0-gd
apt-get install -y php8.0-apcu
apt-get install -y php8.0-intl
apt-get install -y php8.0-memcached php8.0-memcache
apt-get install -y certbot python-certbot-apache
a2enmod -q rewrite dir expires headers
phpenmod mysqlnd pdo_mysql intl

echo ======= Installing Node and Friends
apt-get install -y nodejs
node --version
apt-get install -y npm

npm --version
echo === Installing certbot - https://certbot.eff.org/lets-encrypt/ubuntufocal-apache
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

echo ======= Installing Postfix
echo "postfix postfix/mailname string example.com" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y mailutils

echo ====== Check out build scripts if they are not already there
if [ ! -d "/root/tsugi-build" ]; then
    git clone https://github.com/tsugiproject/tsugi-build.git /root/tsugi-build
fi
echo ======= Cleanup Start
df
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done
# End from https://github.com/tsugiproject/tsugi-build/docker/base/tsugi-base-prepare.sh

cp apache2.conf /etc/apache2

echo ===========================
echo === PRE-AMI is Complete ===
echo ===========================

echo Next is to shutdown and make the AMI
echo
echo systemctl poweroff
echo
