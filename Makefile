all:
	@git config user.name "Simon Wong"
	@git config user.email "simonwong1985hk@gmail.com"
	@git config list --local
	@echo
	@git remote get-url upstream > /dev/null 2>&1 || git remote add upstream https://github.com/laravel/laravel.git
	@git remote -v
	@echo
	@git fetch upstream > /dev/null 2>&1
	@git merge upstream/12.x --no-edit

up:
	@sh ./docker/up

php:
	@docker exec -it "laravel-php" /bin/sh
