include .env

all:
	docker compose up -d
	sleep 24
	docker exec $(APP_NAME)-php /bin/sh -c "composer install"
	docker exec $(APP_NAME)-php /bin/sh -c "php artisan key:generate"
	docker exec $(APP_NAME)-php /bin/sh -c "php artisan storage:link"
	docker exec $(APP_NAME)-php /bin/sh -c "php artisan migrate:fresh --seed"
	docker exec $(APP_NAME)-php /bin/sh -c "npm install"
	docker exec $(APP_NAME)-php /bin/sh -c "npm run build"

cli:
	docker exec -it --user root $(APP_NAME)-php /bin/sh
