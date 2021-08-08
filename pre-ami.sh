# Setup a scalable app server instance behind ELB
# Leave hostname alone

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env

echo ======= Update 1
apt update

apt-get install -y build-essential python-software-properties software-properties-common
apt-get install -y byobu curl git htop man unzip vim wget
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

echo ======= Update 2
apt update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y -r ppa:certbot/certbot

echo ======= Update 3
apt update

# from docker/base/tsugi-base-prepare.sh

apt-get install -y apache2
apt-get install -y mysql-client-8.0
apt-get install -y nfs-common  # For EFS

apt-get install -y php8.0
apt-get install -y libapache2-mod-php8.0 php8.0-mysql php8.0-curl
apt-get install -y php8.0-mbstring php8.0-zip php8.0-xml php8.0-gd
apt-get install -y php8.0-apcu
apt-get install -y php8.0-intl
apt-get install -y php8.0-memcached php8.0-memcache
apt-get install -y certbot python-certbot-apache
a2enmod -q rewrite dir expires headers
phpenmod mysqlnd pdo_mysql intl

echo ======= Cleanup Start
df
apt-get --purge -y remove software-properties-common
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done

cp apache2.conf /etc/apache2

echo ===========================
echo === PRE-AMI is Complete ===
echo ===========================

echo Next is to shutdown and make the AMI
echo
echo systemctl poweroff
echo
