# User Documentation

## Overview

This project provides a web infrastructure composed of three services:

- NGINX: handles HTTPS and serves as the public entry point
- WordPress: provides the website and the administration panel
- MariaDB: stores the website database

All services run inside Docker containers and communicate through an internal Docker network.

---

## Starting the Project

To build and start the full infrastructure, run:

    make

This command:
- creates the required data directories
- builds the Docker images
- starts all containers in detached mode

---

## Stopping the Project

To stop and remove the containers, run:

    make down

To stop the containers without removing them, run:

    make stop

To start previously stopped containers again, run:

    make start

To restart the full infrastructure, run:

    make restart

---

## Accessing the Website

Once the project is running, you can access:

- Website: https://`<login>`.42.fr
- WordPress Admin: https://`<login>`.42.fr/wp-admin

Make sure that `<login>.42.fr` points to your local IP address.

---

## Credentials

Credentials are stored in the project configuration files.

They can be found in:
- `srcs/.env`
- `secrets/`

These files contain the values used for:
- the domain name
- the database user and passwords
- the WordPress administrator account
- the standard WordPress user account

Credentials should be managed carefully and should not be exposed publicly.

---

## Checking Services

To check whether the containers are running correctly, run:

    make ps

To view the logs of all services, run:

    make logs

These commands help confirm that NGINX, WordPress, and MariaDB are running as expected.

---

## Data Persistence

Project data is stored on the host machine in:

    /home/<login>/data/

This includes:
- `mariadb/` for database files
- `wordpress/` for website files

These directories are created automatically by the Makefile before the containers start.

Because the data is stored outside the containers, it remains available even if the containers are stopped or recreated.

---

## Resetting Project Data

To stop the project and remove all stored website and database data, run:

    make fclean

To fully clean the data and start the project again, run:

    make re

These commands should be used carefully, since they delete persistent data.
