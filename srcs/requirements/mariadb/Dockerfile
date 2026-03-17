FROM debian:bookworm
# Use Debian Bookworm as base image (stable and allowed in the subject)

# Update package lists and install MariaDB server
# --no-install-recommends avoids installing unnecessary packages
# Clean apt cache and remove lists to reduce final image size
# Remove default database files to ensure a clean initialization at runtime
RUN apt-get update \
	&& apt-get install -y --no-install-recommends mariadb-server \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/*

# Copy custom MariaDB configuration file into the container
# This overrides default settings (network, datadir, etc.)
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/mariadb.cnf

# Copy database initialization script into the container
# This script will handle first-time setup (DB creation, users, etc.)
COPY tools/init_db.sh /usr/local/bin/init_db.sh

# Ensure the initialization script has execution permissions
RUN chmod +x /usr/local/bin/init_db.sh

# Expose MariaDB default port for inter-container communication
# (Not for external access — handled via Docker network)
EXPOSE 3306

# Set the container entrypoint to the initialization script
# This ensures the script runs as PID 1 and starts MariaDB properly
ENTRYPOINT ["/usr/local/bin/init_db.sh"]