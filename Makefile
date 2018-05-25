include .env

.PHONY: up down stop prune ps shell drush logs

default: up

DRUPAL_ROOT ?= /var/www/html/web

#
# Dev Operations
#
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose pull
	docker-compose up -d --remove-orphans

down: stop

stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") sh

shell-mysql:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_mariadb' --format "{{ .ID }}") sh

drush:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

install:
	chmod 777 web/sites/default/settings.php
	#cat scripts/drupal/invoke_local_settings.txt >> web/sites/default/settings.php
	chmod 666 web/sites/default/settings.php
	if [ ! -f web/sites/default/settings.local.php ]; then cp scripts/drupal/settings.local.php web/sites/default/settings.local.php; fi

composer-update:	##@dev-environment Run composer update.
	docker-compose exec -T php composer update -n --prefer-dist -vvv

composer-install:	##@dev-environment Run composer install
	docker-compose exec -T php composer install -n --prefer-dist -vvv

# https://stackoverflow.com/a/6273809/1826109
%:
	@:

