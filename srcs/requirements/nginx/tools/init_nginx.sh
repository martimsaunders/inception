#!/bin/bash
# Tell the system to execute this script using Bash

# Exit immediately if any command fails
set -e

# Create the directory that will store the SSL certificate and private key
mkdir -p /etc/nginx/ssl

# Generate a self-signed certificate only if it does not already exist
# This prevents overwriting existing TLS files every time the container starts
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=PT/ST=Lisboa/L=Lisboa/O=42/OU=42/CN=${DOMAIN_NAME}"
	# -x509: generate a self-signed certificate
	# -nodes: do not encrypt the private key
	# -days 365: make the certificate valid for one year
	# -newkey rsa:2048: create a new 2048-bit RSA key
	# -keyout: output path for the private key
	# -out: output path for the certificate
	# -subj: provide certificate information non-interactively
fi

echo "Starting NGINX..."

# Replace the shell with the NGINX process and keep it in the foreground
# "daemon off;" is required so NGINX stays attached to PID 1 inside the container
exec nginx -g "daemon off;"