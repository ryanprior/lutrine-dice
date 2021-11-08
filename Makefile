.PHONY: watch-server dev-server

watch-server:
	watchexec -w server -w client/dist docker-compose restart server

dev-server:
	docker-compose up server

destroy-db:
	:>lutrine-dice.db
