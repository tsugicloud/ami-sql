
Building the AMI
================

Make the pre-instance to make the ami

    EC2 Dashboard
    ami-916f59f4 - Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
    t2.micro
    don't put user data in for the pre-process

Once your EC2 Instance is up and running, log in and run the following sequence:

    sudo bash
    git clone https://github.com/tsugicloud/ami-sql.git
    cd ami-sql
    bash pre-ami.sh
    systemctl poweroff

Make an AMI by taking a snapshot of your EC2 instance once it is powered off.

Creating the Necessary Services and Building the User Data
==========================================================

Take a look at the "user_data.sh" file - make your own copy of it.  Once you edit it
do not check it into a public repo.

Make an Aurora Instance - then get the DB connection information and put it in your user_data.sh file

    export TSUGI_USER=apps_db_user
    export TSUGI_PASSWORD=APPS_PW_8973498
    export TSUGI_PDO="mysql:host=tsugi-cluster-1.cluster-ce43983889mk.us-east-2.rds.amazonaws.com;dbname=apps_db"

Make an EFS volume and put its connection information into:

    export TSUGI_NFS_VOLUME=fs-439fd792.efs.us-east-2.amazonaws.com

Set up a DynamoDB service and make a table:

Then put the DynamoDB connection information into your user data:

    export DYNAMODB_KEY= 'AKIISDIUSDOUISDHFBUQ';
    export DYNAMODB_SECRET = 'zFKsdkjhkjskhjSAKJHsakjhSAKJHakjhdsasYaZ';
    export DYNAMODB_REGION = 'us-east-2';

Making an EC2 Instance Using the AMI
====================================

Put in the user data under Advanced - copy everything from the "#! /bin/bash" to the end of the file.
When the process sees the hashbang, it runs the user data as a shell script.

To debug the install process, you might find it useful to look at:

    /var/log/cloud-init-output.log

Notes
=====

About EFS and /etc/fstab

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot-old.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-update-fstab

