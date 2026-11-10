.PHONY: up dev setup check migrate test docker-up docker-down clean

PYTHON := $(shell if [ -x .venv/bin/python ]; then echo .venv/bin/python; else echo .venv/Scripts/python.exe; fi)

up:
	@bash ./setup.sh

dev: up

setup:
	@bash ./setup.sh --setup-only

check:
	@$(PYTHON) manage.py check

migrate:
	@$(PYTHON) manage.py migrate --noinput

test:
	@$(PYTHON) manage.py test

docker-up:
	@docker compose up --build

docker-down:
	@docker compose down -v

clean:
	@rm -rf .venv db.sqlite3 media
