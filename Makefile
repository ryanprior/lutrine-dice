.PHONY: server-container-prod dev check deploy-staging destroy-db

server-container-prod:
	docker-compose -f docker-prod.yml run --rm client
	docker-compose -f docker-prod.yml build server

dev:
	docker-compose up -d server client
	watchexec -w server -w client/dist --restart docker-compose restart server

check:
	docker-compose run --rm client-behavior-test

deploy-staging: server-container-prod
	flyctl deploy

destroy-db:
	:>lutrine-dice.db
