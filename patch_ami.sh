
echo "Making sure we don't fill disk with old AMI bits"

apt-get -y autoremove
apt-get -y update
apt-get -y autoremove

