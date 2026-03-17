#!/bin/bash
# Tell the system to execute this script using Bash

# Exit immediately if any command fails
set -e

# Directory where WordPress files will be stored
WP_PATH="/var/www/html"

# Create the directory used for the PHP-FPM socket
mkdir -p /run/php

# Create the WordPress installation directory if it does not exist
mkdir -p "$WP_PATH"

# PHP-FPM runs as www-data, so these directories must be owned by that user
chown -R www-data:www-data /run/php
chown -R www-data:www-data "$WP_PATH"

# Read sensitive credentials from Docker secrets
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_adm_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Move to /tmp because temporary installation files will be downloaded there
cd /tmp

# Wait until the MariaDB server is ready to accept connections
# This prevents WordPress setup from running before the database is available
until mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; do
	echo "Waiting for MariaDB..."
	sleep 2
done

# If wp-config.php does not exist, WordPress has not been configured yet
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "Downloading WordPress..."

	# Download the latest WordPress archive into /tmp
	cd /tmp
	wget https://wordpress.org/latest.tar.gz

	# Extract the archive and copy WordPress files to the target directory
	tar -xzf latest.tar.gz
	cp -a wordpress/. "$WP_PATH"/

	# Remove temporary installation files
	rm -rf /tmp/latest.tar.gz /tmp/wordpress

	# Move to the WordPress directory to run WP-CLI commands
	cd "$WP_PATH"

	# Generate the wp-config.php file with database connection settings
	wp config create \
		--allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$MYSQL_HOST:3306" 
	
	# Install WordPress core and create the administrator account
	wp core install \
		--allow-root \
		--url="$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email

	# Create an additional WordPress user required by the subject
	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--allow-root \
		--role=author \
		--user_pass="$WP_USER_PASSWORD"
	
	echo "WordPress installed."
fi

echo "Starting WordPress..."

# Replace the shell with php-fpm and keep it in the foreground
# The -F option prevents php-fpm from running as a daemon, which is required in Docker
exec /usr/sbin/php-fpm8.2 -F
