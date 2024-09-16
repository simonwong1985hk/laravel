all:
	cp .env.example .env
	docker compose up -d
	docker exec php /bin/sh -c "composer install"
	docker exec php /bin/sh -c "php artisan key:generate"
	docker exec php /bin/sh -c "php artisan storage:link"
	docker exec php /bin/sh -c "php artisan migrate:fresh --seed"
	docker exec php /bin/sh -c "npm install"
	docker exec php /bin/sh -c "npm run build"
