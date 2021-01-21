#
# This is a way to upgrade to PHP 7.3
#

apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-mysql php7.3-curl php7.3-json php7.3-mbstring php7.3-zip php7.3-xml php7.3-gd php7.3-apc php7.3-intl php-memcached php-memcache

php --version

a2dismod php7.1
a2enmod php7.3
systemctl restart apache2

