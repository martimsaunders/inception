# Developer Documentation

## Environment Setup

### Prerequisites

To set up the project from scratch, the following environment is required:

- Linux (Debian recommended)
- Sudo privileges

---

### Installing Docker

#### Update package lists:

    sudo apt update

#### Install required dependencies:

    sudo apt install -y ca-certificates curl gnupg

#### Add Docker’s official GPG key:

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#### Set up the Docker repository:

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#### Install Docker and Docker Compose:

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#### Verify installation:

    docker --version
    docker compose version

#### After installing Docker, verify that it is working correctly:

    sudo docker run hello-world
    
#### Running Docker Without sudo:

By default, Docker commands require `sudo`.

To run Docker without sudo, add your user to the Docker group:

    sudo usermod -aG docker $USER

Then apply the changes:

    newgrp docker

After this, you can run Docker commands without using `sudo`.

---

## Project Setup

Clone the repository:

    git clone <repo>
    cd inception

---

## Project Structure

```
inception
├── Makefile
├── secrets
└── srcs
    ├── docker-compose.yml
    ├── .env
    └── requirements
        ├── mariadb
        ├── nginx
        └── wordpress
```

- Each service runs in its own container
- Each service is built from a custom Dockerfile
- Configuration and initialization scripts are stored per service

---

## Configuration

### Environment Variables

Environment variables are defined in:

    srcs/.env

These include:
- LOGIN (used to define data paths)
- domain name
- database credentials
- WordPress credentials

---

### Secrets

Sensitive data is not stored in the repository for security reasons.

After cloning the repository, the `secrets/` directory must be created manually, along with the required files.

Create the directory:

    mkdir secrets

Create the following files:

    touch secrets/db_password
    touch secrets/db_root_password
    touch secrets/wp_adm_password
    touch secrets/wp_password

Each file should contain the corresponding secret value (e.g., passwords).

These files are used during container initialization and must not be committed to the repository.

---

## Build and Launch

The project is managed using the Makefile.

To build and start the infrastructure:

    make

This command:
- creates required directories in /home/<login>/data/
- builds Docker images using docker-compose
- starts all containers in detached mode

---

## Container Management

Available Makefile commands:

Start containers:

    make start

Stop containers:

    make stop

Restart containers:

    make restart

Stop and remove containers:

    make down

Rebuild images:

    make build

View logs:

    make logs

List containers:

    make ps

---

## Volume and Data Management

Data is stored on the host machine in:

    /home/<login>/data/

This directory contains:
- mariadb → database files
- wordpress → website files

These directories are created automatically by the Makefile:

    make create_dirs

---

## Data Persistence

Docker volumes map container data to host directories.

This ensures:
- data persists after container restarts
- data is preserved even if containers are removed

---

## Cleaning and Resetting

To remove all containers and persistent data:

    make fclean

This command deletes:
- MariaDB data
- WordPress files

To fully reset and restart:

    make re

---

## Notes

- Each service runs in an isolated container
- No pre-built images are used
- All images are built from custom Dockerfiles
- Containers communicate via a Docker network
- Only NGINX exposes port 443 externally
