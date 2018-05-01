echo Running post-ami-sql `date "+%F-%T"`
touch /tmp/post-ami-sql-`date "+%F-%T"`

# source /home/ubuntu/tsugi_env.sh

echo "====== Environment variables"
env | sort

cat << EOF >> /home/ubuntu/.bashrc
if [ "\$EUID" -ne 0 ]
then
PS1="\e[0;32m${TSUGI_SERVICENAME}:\e[m\e[0;34m\w\e[m$ "
else
PS1="\e[0;31m${TSUGI_SERVICENAME}:\e[m\e[0;34m\w\e[m# "
fi
EOF

apt-get update

echo ======= Installing Postfix
echo "postfix postfix/mailname string ${TSUGI_MAIL_DOMAIN}" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y mailutils

if [ ! -d /efs ]; then
    echo ====== Setting up the efs volume
    mkdir /efs
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $TSUGI_NFS_VOLUME:/ /efs
    if grep --quiet /efs /etc/fstab ; then
        echo Fstab already has efs mount
    else
        echo Adding efs mount to /etc/fstab
        cat << EOF >> /etc/fstab
$TSUGI_NFS_VOLUME:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0
EOF
    fi
fi

if [ ! -d /efs ]; then
    echo Failed to mount /efs - execution terminated
    exit 1
fi

echo Checking if there already is a git and is it good
if [ -d /var/www/html ] ; then
  if [ -d /var/www/html/tsugi ] ; then
    if ! git status /var/www/html/tsugi ; then
      echo git status failed on /var/www/html/tsugi
      export TSUGI_FRESH_EFS=yes
    fi
  else
    echo /var/www/html/tsugi does not exist
    export TSUGI_FRESH_EFS=yes
  fi
  if ! git status /var/www/html ; then
    echo git status failed on /var/www/html
    export TSUGI_FRESH_EFS=yes
  fi
fi

if [[ -f /var/www/html && -n "$TSUGI_FRESH_EFS" ]] ; then
    echo Clearing out /var/www/html
    echo File count: `du -a /var/www/html | wc -l`
    rm -rf /var/www/html/* /var/www/html/.??*
    echo /var/www/html cleared.
fi


if [ ! -d /efs/blobs ]; then
  mkdir /efs/blobs
fi

echo "Patching efs permissions"
chown -R www-data:www-data /efs

# If we are making a fresh install
if [ ! -d /var/www/html/tsugi/.git ]; then
  cd /var/www/html/
  if [ -n "$MAIN_REPO" ] ; then
    echo Cloning $MAIN_REPO
    git clone $MAIN_REPO site
  else
    echo Cloning default repo
    git clone https://github.com/tsugicloud/dev-jekyll-site.git site
  fi
  cd site
  mv .git* * ..
  cd ..
  rm -r site

  cd /var/www/html/
  git clone https://github.com/tsugiproject/tsugi.git

fi

# Sanity Check
if [[ -f /var/www/html/tsugi/admin/upgrade.php && -f /var/www/html/tsugi/admin/install/update.php ]] ; then
  echo Tsugi checkout looks good
else
  echo Tsugi checkout fail
  exit 1
fi

# Make sure FETCH_HEAD and ORIG_HEAD are created
cd /var/www/html
git pull
cd /var/www/html/tsugi
git pull

# Fix the config.php file
if [ ! -f /var/www/html/tsugi/config.php ] ; then
    echo Building config.php
    php /home/ubuntu/ami-sql/fixconfig.php < /home/ubuntu/ami-sql/config.php > /var/www/html/tsugi/config.php
fi

# Make git work from the browser
cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chmod a+s /usr/local/bin/gitx

# Patch permissions
chown -R www-data:www-data /var/www/html/tsugi

# Create/update the Tsugi database tables
cd /var/www/html/tsugi/admin
su -s "php upgrade.php" www-data

# Install any needed tools if we are second to the cluster
cd /var/www/html/tsugi/admin/install
su -s "php update.php" www-data

# Make git work from the browser
if [ -n "$TSUGI_SETUP_GIT" ] ; then
  echo "Enabling git from the browser"
  chmod a+s /usr/local/bin/gitx
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

# https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job

echo ====== Setting up cron jobs
cp /home/ubuntu/ami-sql/cron.sh /home/ubuntu/cron.sh
chown ubuntu:ubuntu /home/ubuntu/cron.sh
chmod 664 /home/ubuntu/cron.sh

cp /home/ubuntu/ami-sql/crontab.txt /var/spool/cron/crontabs/ubuntu
chown ubuntu:ubuntu /var/spool/cron/crontabs/ubuntu
chmod 600 /var/spool/cron/crontabs/ubuntu

service cron restart

echo Setting Apache to auto-start on reboot
update-rc.d apache2 defaults

echo Starting Apache
/usr/sbin/apachectl start

