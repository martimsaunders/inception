*This project has been created as part of the 42 curriculum by mprazere.*

# Inception

## Description

Inception is a System Administration project focused on containerization using Docker.
The goal is to set up a small infrastructure composed of multiple services, each running in its own container, orchestrated with Docker Compose.

This project demonstrates how Docker can be used to isolate services, ensure portability, and simplify deployment through containerization.
All services are built from custom Dockerfiles, without using pre-built images.

The infrastructure includes:
- NGINX (with TLS)
- WordPress (with PHP-FPM)
- MariaDB (database)

All services communicate through a Docker network and use volumes for data persistence.

---

## Instructions

### Requirements
- Linux (Debian recommended)
- Docker
- Docker Compose
- Make

### Setup

```bash
git clone <repo>
cd inception
make
```

### Access

- Website: https://`<login>`.42.fr
- WordPress Admin: https://`<login>`.42.fr/wp-admin

---

## Project Architecture

```
inception
├── Makefile
├── secrets
│   ├── db_password
│   ├── db_root_password
│   ├── wp_adm_password
│   └── wp_password
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── conf
        │   │   └── mariadb.cnf
        │   ├── Dockerfile
        │   └── tools
        │       └── init_db.sh
        ├── nginx
        │   ├── conf
        │   │   └── nginx.conf
        │   ├── Dockerfile
        │   └── tools
        │       └── init_nginx.sh
        └── wordpress
            ├── conf
            │   └── www.conf
            ├── Dockerfile
            └── tools
                └── init_wp.sh
```
Each service runs in its own container and is built from a custom Dockerfile, as required by the project subject.

### Services

- **NGINX**
  - Handles HTTPS (TLSv1.2 / TLSv1.3)
  - Acts as reverse proxy
  - Only exposed service (port 443)

- **WordPress**
  - Runs with PHP-FPM
  - Connects to MariaDB
 
- **MariaDB**
  - Stores WordPress database
  - Internal service (not exposed)

---

### Networking

- All containers are connected through a custom Docker network, allowing secure internal communication.

- Only NGINX is exposed to the outside world.

---

### Volumes

Data persistence is handled through Docker volumes mapped to:

```bash
/home/<login>/data/
```

- mariadb → database files  
- wordpress → website files  

---

## Design Choices

### Virtual Machines vs Docker

- Virtual machines run a full operating system for each instance, which makes them heavier and slower to start.
- Docker containers, on the other hand, share the host system’s kernel, making them lightweight, faster, and more efficient.

### Secrets vs Environment Variables

- Secrets provide a more secure way to store sensitive data because they are not directly exposed in images or environment variables.  
- Environment variables are easier to configure and use, especially through a `.env` file, but they can be exposed if not handled carefully.  
- In this project, environment variables are used, with attention to avoiding exposing sensitive data in the repository.

### Docker Network vs Host Network

- A Docker network provides isolation between containers and allows controlled communication between services.  
- Using the host network removes this isolation and exposes services more directly, which can reduce security.  

### Docker Volumes vs Bind Mounts

- Docker volumes are managed by Docker and provide better portability and abstraction from the host system.  
- Bind mounts directly map a host directory into a container, which gives more control but reduces portability and can lead to inconsistencies.  
- This project uses Docker named volumes, as required, mapped to `/home/<login>/data` to ensure persistence while respecting the subject rules.

---

## Resources

- Docker Documentation — https://docs.docker.com/
- Docker Compose — https://docs.docker.com/compose/
- NGINX Documentation — https://nginx.org/en/docs/
- WordPress Documentation — https://wordpress.org/documentation/
- MariaDB Documentation — https://mariadb.org/documentation/

---

## AI Usage

AI was used to:
- Clarify Docker concepts
- Assist in debugging configuration issues
- Help structure documentation

