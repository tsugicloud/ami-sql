# Setup a scalable app server instance behind ELB
# Leave hostname alone

# Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-05c1fa8df71875112

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env

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
# add-apt-repository -y ppa:ondrej/mysql-5.6
add-apt-repository -y ppa:certbot/certbot

echo ======= Update 3
apt-get update

apt-get install -y apache2

# apt-cache search php7

apt-get install -y php7.4
apt-get install -y libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-json
apt-get install -y php7.4-mbstring php7.4-zip php7.4-xml php7.4-gd
apt-get install -y php7.4-apc php7.4-intl
apt-get install -y php7.4-memcache php7.4-memcached


apt-get install -y mysql-client
apt-get install -y nfs-common  # For EFS

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
