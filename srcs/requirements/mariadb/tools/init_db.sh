#!/bin/bash
# Tell the system to execute this script using Bash

# Exit immediately if any command fails
set -e

# Create the directory used for the MariaDB Unix socket
mkdir -p /run/mysqld

# MariaDB runs as the mysql user, so these directories must be owned by mysql
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Read sensitive credentials from Docker secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# If the system database directory does not exist, the database has not been initialized yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."

	# Create the initial MariaDB system tables and data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal

	echo "Starting temporary MariaDB server..."
	# Start MariaDB in the background temporarily so SQL setup commands can be executed
	mysqld_safe --datadir=/var/lib/mysql &
	pid="$!"
	# '&' runs the process in the background, and '$!' stores its PID

	echo "Waiting for MariaDB to start..."
	# Wait until the server is ready to accept connections
	until mariadb-admin ping --silent; do
		sleep 1
	done

	echo "Creating database and user..."

	# Create the application database if it does not already exist
	mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

	# Create the application user with access from any host
	mariadb -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

	# Grant the user full privileges on the application database
	mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"

	# Set the root password for local administrative access
	mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	
	# Reload privilege tables so all changes take effect immediately
	mariadb -u root -e "FLUSH PRIVILEGES;"

	echo "Stopping temporary MariaDB server..."

	# Shut down the temporary MariaDB instance after initialization is complete
	mariadb-admin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

	# Wait for the background process to exit cleanly
	wait "$pid" || true
fi

echo "Starting MariaDB server..."

# Replace the shell process with mysqld so MariaDB becomes PID 1 inside the container
exec mysqld --user=mysql --datadir=/var/lib/mysql