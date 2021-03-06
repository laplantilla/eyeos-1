#!/bin/bash

REL="2.5.1"
IP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# First install all the dependencies for eyeOS 2.5.

apt-get update
apt-get -y install wget
apt-get -y install apache2
apt-get -y install mysql-server libapache2-mod-auth-mysql php5-mysql
apt-get -y install php5 libapache2-mod-php5 php5-mcrypt

# Install PHP extensions required by eyeOS

apt-get -y install php5-gd
apt-get -y install php5-curl
apt-get -y install php5-mcrypt

# Install zip, unzip, exiftool, python, python uno, etc.

apt-get -y install python
apt-get -y install zip
apt-get -y install unzip
apt-get -y install exif
apt-get -y install openoffice.org
apt-get -y install libimage-exiftool-perl

# Reload Apache2 to enable php modules

/etc/init.d/apache2 restart

# Enable mod_rewrite apache

a2enmod rewrite
/etc/init.d/apache2 restart

####### (NEEDS FIXING) Automatically create MySQL user and database for eyeos. Grant perms. ######
#
#mysql
#CREATE USER 'eyeos'@'localhost' IDENTIFIED BY 'password';
#CREATE DATABASE eyeos;
#GRANT ALL PRIVILEGES ON eyeos.* TO 'eyeos'@'localhost';
#FLUSH PRIVILEGES;

# Automatically wget and copy eyeos to www root directory; fix permissions

wget https://github.com/dhamaniasad/eyeos/archive/$REL.zip
unzip $REL.zip
rm -rf eyeos-$REL/README.md
tar xvzf eyeos-$REL/eyeos-$REL.tar.gz
rm -rf $REL.zip
rm -rf eyeos-$REL.zip
mv * /var/www/
rm -rf /var/www/index.html
chown -R www-data /var/www/

echo "To finish your installation, go to http://$IP/install"
echo "You might get warnings about SQLite Extension and PDO SQLite Driver not being installed, but you may ignore them as we are using MySQL instead of SQLite"
