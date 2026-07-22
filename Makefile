SHELL := /bin/bash
AWS_PROFILE ?= root
WORKSPACE ?= dev
INFRA_MAKE := $(MAKE) -C terraform WORKSPACE=$(WORKSPACE) AWS_PROFILE=$(AWS_PROFILE)
COMPOSE := docker compose -f docker-compose.yml


.PHONY: 


# Secrets
setup:
	@$(INFRA_MAKE) setup

decrypt:
	@$(INFRA_MAKE) decrypt

encrypt:
	@$(INFRA_MAKE) encrypt

encrypt-all: 
	@$(INFRA_MAKE) encrypt-all

# AWS
reconfig:
	@$(INFRA_MAKE) reconfig

init:
	@$(INFRA_MAKE) init

validate:
	@$(INFRA_MAKE) validate

plan:
	@$(INFRA_MAKE) plan

apply:
	@$(INFRA_MAKE) apply

destroy:
	@$(INFRA_MAKE) destroy

list:
	@$(INFRA_MAKE) list

unlock:
	@$(INFRA_MAKE) unlock




# DOCKER COMMANDS FOR LOCAL ENVIRONMENT
down:
	@if [ -n "$$(docker ps -aq)" ]; then \
		echo "Deleting Docker containers, images, volumes, and networks..."; \
		docker container stop $$(docker ps -aq) > /dev/null; \
		$(COMPOSE) down --rmi local --volumes --remove-orphans; \
	else \
		echo "No Docker containers to delete."; \
	fi

build:
	$(COMPOSE) up --build
	$(COMPOSE) run --rm api python manage.py makemigrations
	$(COMPOSE) run --rm api python manage.py migrate

up:
	$(COMPOSE) up
	$(COMPOSE) run --rm api python manage.py makemigrations
	$(COMPOSE) run --rm api python manage.py migrate

migrate:
	$(COMPOSE) run --rm api python manage.py makemigrations
	$(COMPOSE) run --rm api python manage.py migrate

admin:
	$(COMPOSE) exec \
	-e DJANGO_SUPERUSER_EMAIL=admin@corpershub.local \
	-e DJANGO_SUPERUSER_PASSWORD=ifG0dbi4mi \
	-e DJANGO_SUPERUSER_USERNAME=admin \
	-e DJANGO_SUPERUSER_FIRST_NAME=Admin \
	-e DJANGO_SUPERUSER_LAST_NAME=Admin \
	api python3 manage.py createsuperuser --noinput

seed:
	$(COMPOSE) exec api python manage.py seed_demo_data

shell:
	$(COMPOSE) run --rm api python manage.py shell

test:
	$(COMPOSE) run --rm api python manage.py test

prune:
	@docker system df
	@docker system prune -f
	@docker volume prune -f