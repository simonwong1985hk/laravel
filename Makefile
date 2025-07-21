include .env

.PHONY: me mu local production list php down destroy

NAME = $(shell echo $(APP_NAME) | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

me:
	@git config user.name "Simon Wong"
	@git config user.email "simonwong1985hk@gmail.com"
	@git config list --local

own:
	@chown -R $(USER):$(USER) .

mu:
	@git remote get-url upstream > /dev/null 2>&1 || git remote add upstream https://github.com/laravel/laravel.git
	@git remote -v
	@git fetch upstream > /dev/null 2>&1
	@git merge upstream/12.x --no-edit

local:
	@docker compose -f ./compose.local.yml up  -d
	@docker exec $(NAME)-php /bin/sh -c "composer install"
	@docker exec $(NAME)-php /bin/sh -c "php artisan key:generate"
	@docker exec $(NAME)-php /bin/sh -c "php artisan storage:link"
	@docker exec $(NAME)-php /bin/sh -c "php artisan migrate:fresh --seed --force"
	@docker exec $(NAME)-php /bin/sh -c "npm install"
	@docker exec $(NAME)-php /bin/sh -c "npm run build"

production:
	@docker compose -f ./compose.production.yml up  -d
	@docker exec $(NAME)-php /bin/sh -c "composer install"
	@docker exec $(NAME)-php /bin/sh -c "php artisan key:generate"
	@docker exec $(NAME)-php /bin/sh -c "php artisan storage:link"
	@docker exec $(NAME)-php /bin/sh -c "php artisan migrate:fresh --seed --force"
	@docker exec $(NAME)-php /bin/sh -c "npm install"
	@docker exec $(NAME)-php /bin/sh -c "npm run build"

list:
	@echo "------------------------------------------CONTAINERS------------------------------------------"
	@docker container ls
	@echo "------------------------------------------IMAGES------------------------------------------"
	@docker image ls
	@echo "------------------------------------------VOLUMES------------------------------------------"
	@docker volume ls
	@echo "------------------------------------------NETWORKS------------------------------------------"
	@docker network ls

php:
	@docker exec -it $(NAME)-php /bin/sh

down:
	@docker container stop $(NAME)-nginx $(NAME)-php $(NAME)-phpmyadmin $(NAME)-mysql $(NAME)-mailpit 2>/dev/null || true
	@docker container rm $(NAME)-nginx $(NAME)-php $(NAME)-phpmyadmin $(NAME)-mysql $(NAME)-mailpit 2>/dev/null || true
	@docker image rm $(NAME)-nginx $(NAME)-php $(NAME)-phpmyadmin $(NAME)-mysql $(NAME)-mailpit 2>/dev/null || true
	@docker volume rm $(NAME)-db 2>/dev/null || true
	@docker network rm $(NAME)-network 2>/dev/null || true

destroy:
	@docker rm -f `docker ps -aq` 2>/dev/null || true
	@docker rmi -f `docker images -q` 2>/dev/null || true
	@docker volume rm `docker volume ls -q` 2>/dev/null || true
	@docker network rm `docker network ls -q` 2>/dev/null || true
