FROM debian:bookworm
# Use Debian Bookworm as base image (stable and allowed in the subject)

# Update package lists and install only the required packages
# nginx: web server that will handle HTTPS requests
# openssl: used to generate the self-signed TLS certificate
# Clean apt cache and package lists afterwards to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Copy the custom NGINX configuration file into the container
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy the startup script that generates the certificate and launches NGINX
COPY tools/init_nginx.sh /usr/local/bin/init_nginx.sh

# Ensure the startup script has execution permissions
RUN chmod +x /usr/local/bin/init_nginx.sh

# Expose HTTPS port used by NGINX
EXPOSE 443

# Run the initialization script when the container starts
# This script prepares TLS files and then launches NGINX in the foreground
ENTRYPOINT ["/usr/local/bin/init_nginx.sh"]