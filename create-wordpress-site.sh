#!/bin/bash

# installs a wordpress site

set -euo pipefail

WORDPRESS_URL="https://wordpress.org/latest.tar.gz"
EC2_PUBLIC_IP=$(curl -sS http://169.254.169.254/latest/meta-data/public-hostname)
HOSTNAME="${HOSTNAME:-$EC2_PUBLIC_IP}"
DB_PASSWORD="wordpress"
DB_USER="wordpress"

while [ $# -gt 0 ]; do
	case "$1" in
		--hostname)
			HOSTNAME="$2"
			shift
			;;
		--db-user)
			DB_USER="$2"
			shift
			;;
		--db-password)
			DB_PASSWORD="$2"
			shift
			;;
		--*)
			echo "Usage: $(basename $0) [--foo FOO] [--bar]"
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y apache2 \
    ghostscript \
    libapache2-mod-php \
    mysql-server \
    php \
    php-bcmath \
    php-curl \
    php-imagick \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip

mkdir -p /srv/www
curl -sS "$WORDPRESS_URL" | tar zx -C /srv/www

cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerName ${HOSTNAME:-localhost}
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite -q wordpress
a2dissite 000-default
a2enmod -q rewrite
systemctl restart apache2

mysql -u root <<EOF
CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY '$DB_PASSWORD';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;
FLUSH PRIVILEGES;
EOF

systemctl restart mysql

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sed -i 's/\$PASSWORD/${DB_PASSWORD}/' /srv/www/wordpress/wp-config.php

chown -R www-data: /srv/www
