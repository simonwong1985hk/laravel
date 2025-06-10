include .env

all:
	@git config user.name "Simon Wong"
	@git config user.email "simonwong1985hk@gmail.com"
	@git config --list --local
	@echo
	@git remote get-url upstream > /dev/null 2>&1 || git remote add upstream https://github.com/laravel/laravel.git
	@git remote -v
	@echo

merge-upstream:
	@git fetch upstream > /dev/null 2>&1
	@git merge upstream/12.x --no-edit

up-local:
	@docker compose -f ./compose.local.yml up  -d
	@docker exec $(APP_ID)-php /bin/sh -c "composer install"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan key:generate"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan storage:link"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan migrate:fresh --seed --force"
	@docker exec $(APP_ID)-php /bin/sh -c "npm install"
	@docker exec $(APP_ID)-php /bin/sh -c "npm run build"

up-production:
	@docker compose -f ./compose.production.yml up  -d
	@docker exec $(APP_ID)-php /bin/sh -c "composer install"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan key:generate"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan storage:link"
	@docker exec $(APP_ID)-php /bin/sh -c "php artisan migrate:fresh --seed --force"
	@docker exec $(APP_ID)-php /bin/sh -c "npm install"
	@docker exec $(APP_ID)-php /bin/sh -c "npm run build"

php:
	@docker exec -it $(APP_ID)-php /bin/sh
