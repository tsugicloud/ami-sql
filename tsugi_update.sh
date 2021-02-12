#! /bin/bash

cd /var/www/html/tsugi

# git pull

# avoid a git pull leaving the code halfway through a merge and unable 
# to be updated
git pull -s recursive -X theirs

