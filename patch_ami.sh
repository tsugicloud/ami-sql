
echo "Making sure we don't fill disk with old AMI bits"

apt-get autoremove
apt-get update
apt-get autoremove

