.PHONY: watch-server dev-server

watch-server:
	watchexec -w server docker-compose restart server

dev-server:
	docker-compose up server
