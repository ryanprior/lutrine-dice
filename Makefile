.PHONY: dev server-staging deploy-prod client-static destroy-db

dev:
	docker-compose up -d
	watchexec -w server -w client/dist docker-compose restart server

server-prod:
	docker-compose build server
	(cd client && mint build)
	docker build -t lutrine-dice .

deploy-staging:
	(cd client && mint build --skip-service-worker --minify --env ../.env.staging)
	docker-compose build server
	flyctl deploy

client-static:
	(cd client && mint build)

destroy-db:
	:>lutrine-dice.db
