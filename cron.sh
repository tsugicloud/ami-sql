#! /bin/bash

echo "I am Cron Cron I Am"
date

# Install any needed tools if we are second to the cluster
sudo su -s "/home/ubuntu/ami-sql/tool_update.sh" www-data

# Create/update the Tsugi database tables
sudo su -s "/home/ubuntu/ami-sql/db_upgrade.sh" www-data

