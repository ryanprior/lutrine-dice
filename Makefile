.PHONY: watch-server dev-server

dev:
	docker-compose up -d
	watchexec -w server -w client/dist docker-compose restart server

server-prod:
	docker-compose build server
	(cd client && mint build)
	docker build -t lutrine-dice .


client-static:
	(cd client && mint build)

destroy-db:
	:>lutrine-dice.db
