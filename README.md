
Make the pre-instance to make the ami

    EC2 Dashboard
    ami-916f59f4 - Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
    t2.micro
    don't put user data in for the pre-process

Log in and

    sudo bash
    git clone https://github.com/tsugicloud/ami-sql.git
    cd ami-sql
    bash pre-ami.sh
    systemctl poweroff

Make the AMI in AWS console

Make a new instance from the AMI

Put in the user data under Advanced

    /var/log/cloud-init-output.log


About EFS and /etc/fstab

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot-old.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-update-fstab

