#! /bin/bash
echo Running user-data from `pwd` on `date "+%F-%T"`
echo `pwd` > /tmp/user-data-`date "+%F-%T"`

cat << EOF > /home/ubuntu/tsugi_env.sh
export TSUGI_USER=apps_db_user
export TSUGI_PASSWORD=APPS_PW_8973498
export TSUGI_PDO="mysql:host=tsugi-cluster-1.cluster-ce43983889mk.us-east-2.rds.amazonaws.com;dbname=apps_db"
export TSUGI_NFS_VOLUME=fs-439fd792.efs.us-east-2.amazonaws.com
export TSUGI_ADMINPW=apps_admin_pw

export DYNAMODB_KEY= 'AKIISDIUSDOUISDHFBUQ';
export DYNAMODB_SECRET = 'zFKsdkjhkjskhjSAKJHsakjhSAKJHakjhdsasYaZ';
export DYNAMODB_REGION = 'us-east-2';

export TSUGI_SETUP_GIT=yes
export TSUGI_MAIL_DOMAIN=apps.lrnxp.net
export TSUGI_APPHOME=https://apps.lrnxp.net
export TSUGI_WWWROOT=https://apps.lrnxp.net/tsugi
export TSUGI_SERVICENAME=LearnXP
EOF

source /home/ubuntu/tsugi_env.sh

# Get the latest
cd /home/ubuntu/ami-sql
git pull

source /home/ubuntu/ami-sql/post-ami.sh
