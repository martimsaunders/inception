FROM debian:bookworm
# Use Debian Bookworm as base image (stable and allowed in the subject)

# Update package lists and install required packages
# php8.2: core PHP interpreter
# php8.2-fpm: FastCGI Process Manager to handle PHP execution
# php8.2-mysql: enables PHP to communicate with MariaDB/MySQL
# mariadb-client: allows the container to test database connectivity
# curl, wget, tar: used for downloading and extracting WordPress
# ca-certificates: ensures HTTPS requests work properly (SSL validation)
# Clean apt cache and remove lists to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
	php8.2 \
	php8.2-fpm \
	php8.2-mysql \
	mariadb-client \
	curl \
	wget \
	tar \
	ca-certificates \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Download and install WP-CLI (WordPress command-line interface)
# This tool is used to automate WordPress setup (config, install, users, etc.)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Copy custom PHP-FPM pool configuration
# This defines how PHP-FPM listens and runs inside the container
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy WordPress initialization script
# This script installs and configures WordPress at container startup
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh

# Ensure the initialization script is executable
RUN chmod +x /usr/local/bin/init_wp.sh

# Set the working directory to the WordPress root
WORKDIR /var/www/html

# Expose PHP-FPM port used for communication with NGINX
# This port is only used internally via the Docker network
EXPOSE 9000

# Set the entrypoint to the initialization script
# This script prepares WordPress and then starts php-fpm in the foreground
ENTRYPOINT ["/usr/local/bin/init_wp.sh"]