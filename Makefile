NAME = inception
COMPOSE = docker-compose -f srcs/docker-compose.yml
LOGIN = $(shell grep '^LOGIN=' srcs/.env | cut -d '=' -f2)

DATA_PATH = /home/$(LOGIN)/data
DB_PATH = $(DATA_PATH)/mariadb
WP_PATH = $(DATA_PATH)/wordpress

all: up

up: create_dirs
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: down up

build:
	$(COMPOSE) build

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

create_dirs:
	mkdir -p $(DB_PATH)
	mkdir -p $(WP_PATH)

fclean: down
	sudo rm -rf $(DB_PATH)/*
	sudo rm -rf $(WP_PATH)/*

re: fclean up

.PHONY: all up down start stop restart build logs ps create_dirs fclean re