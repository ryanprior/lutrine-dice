.PHONY: dev server-container-prod deploy-staging destroy-db

dev:
	docker-compose up -d
	watchexec -w server -w client/dist docker-compose restart server

server-container-prod:
	docker-compose -f docker-prod.yml run --rm client
	docker-compose -f docker-prod.yml build server

deploy-staging: server-container-prod
	flyctl deploy

destroy-db:
	:>lutrine-dice.db
