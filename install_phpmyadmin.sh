#! /bin/bash

rm -rf /var/www/html/phpMyAdmin
cd /home/ubuntu
curl -O https://files.phpmyadmin.net/phpMyAdmin/4.7.9/phpMyAdmin-4.7.9-all-languages.zip

X=`sha256sum phpMyAdmin-4.7.9-all-languages.zip | awk '{print $1}'`
if [ "$X" == "2fb9f7b31ae7cb71f6398e5da8349fb4f41339386e06a851c4444fc7a938a38a" ]
then
  echo "Sha Match"
  unzip phpMyAdmin-4.7.9-all-languages.zip
  mv phpMyAdmin-4.7.9-all-languages /var/www/html/phpMyAdmin
else
  echo "SHA256 mismatch"
  exec "$@"
  exit
fi
