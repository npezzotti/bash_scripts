#! /bin/bash

# This script installs Apache on Ubuntu

if [ $(id -u) != 0 ]
then
  echo "This script requires root privileges"
  exit 1
fi

echo "Updating package cache..."
apt-get update -qq
echo "Installing Apache..."
apt-get install -y apache2 > /dev/null
which apache2 &> /dev/null

if [ $? != 0 ]
then
  echo "Apache failed to install- check logs above for reason."
  exit 1
fi

echo "Allowing Apache app in Firewall..."
ufw allow in "Apache"

UFW_STATUS=$(sudo ufw status | head -n 1 | awk '{print $2}')

if [ $UFW_STATUS == "inactive" ]
then
  echo "WARNING: Firewall inactive..."
fi

TEST_SITE_DIR=/var/www/test
TEST_SITE_HTML=/var/www/test/index.html

echo "Creating directory /var/www/test..."

if [ -d $TEST_SITE_DIR ]
then
  echo "/var/www/test already exists, moving on..."
else
  mkdir $TEST_SITE_DIR
fi

echo "Creating index.html for test site..."

if [ -f $TEST_SITE_HTML ]
then
  echo "/var/www/test/index.html already exists, moving on..."
else
  echo """<html>
  <head>
    <title> Test </title>
  </head>
  <body>
    <p> This is a test site! </p>
  </body>
</html>""" > $TEST_SITE_HTML

  cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/test.conf
  sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/test/' /etc/apache2/sites-available/test.conf
  sed -i 's/#ServerName www.example.com/ServerName www.test.com/' /etc/apache2/sites-available/test.conf
fi

echo "Enabling test site..."
a2ensite -q test > /dev/null

echo "Reloading Apache..."
systemctl reload apache2

if [  $(systemctl is-active apache2) == "active" ]
then
  echo -e "Installation succesfull! \nRun 'curl localhost -H \"Host: www.test.com\"'"
else
  echo "Apache failed to start, run systemctl status apache2 to troubleshoot."
fi
