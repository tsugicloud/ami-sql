#! /bin/bash

echo "I am Cron Cron I Am"
date

# Install any needed tools if we are second to the cluster
cd /var/www/html/tsugi/admin/install
sudo su -s "php update.php" www-data

# Create/update the Tsugi database tables
cd /var/www/html/tsugi/admin
sudo su -s "php upgrade.php" www-data

