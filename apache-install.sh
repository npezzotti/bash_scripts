#! /bin/bash

# This script installs Apache on Ubuntu

if [ $(id -u) != 0 ]
then
  echo "* This script requires root privileges"
  exit 1
fi

echo "* Updating package cache..."
apt-get update -qq
echo "* Installing Apache..."
apt-get install -y apache2 > /dev/null

echo "* Allowing Apache app in Firewall..."
ufw allow in "Apache"

UFW_STATUS=$(sudo ufw status | head -n 1 | awk '{print $2}')

if [ $UFW_STATUS == "inactive" ]
then
  echo "* WARNING: Firewall inactive..."
fi

mkdir /var/www/test

echo """<html>
<head>
  <title> This is a test! </title>
</head>
<body>
  <p> I'm running this website on an Ubuntu Server server!
</body>
</html>
""" > /var/www/test/index.html

echo "Creating configs..."
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/test.conf
sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/test/' /etc/apache2/sites-available/test.conf
sed -i 's/#ServerName www.example.com/ServerName www.test.com/' /etc/apache2/sites-available/test.conf

echo "Enabling test site..."
a2ensite test > /dev/null

echo "Reloading Apache..."
systemctl reload apache2

echo -e "Installation succesfull! \nRun 'curl localhost -H \"Host: www.test.com\"'"
