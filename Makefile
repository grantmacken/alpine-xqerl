include .env

default: up

.PHONY: run-shell
run-shell:
	@docker run -it grantmacken/alpine-xqerl:shell

.PHONY: check
check:
	@# docker ps -a
	@#docker-compose logs
	@docker ps --filter name=$(XQERL_CONTAINER_NAME) --format ' -    name: {{.Names}}'
	@docker ps --filter name=$(XQERL_CONTAINER_NAME) --format ' -  status: {{.Status}}'
	@echo -n '-    port: '
	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
	@#docker volume list 
	@docker volume list  --format ' -  volume: {{.Name}}'
	@docker network list --filter name=$(NETWORK) --format ' - network: {{.Name}}'
	@echo -n '- started: '
	@docker exec xq ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
	@docker exec $(XQERL_CONTAINER_NAME) cat ./log/erl.log

.PHONY: do
do:
	@docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down

.PHONY: build
build:
	@docker build \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):v$(shell date --iso | sed s/-//g)" \
 .

.PHONY: push
push:
	@echo '## $@ ##'
	@docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	@docker push $(DOCKER_IMAGE):v$(shell date --iso | sed s/-//g)

.PHONY: clean
clean:
	@docker images -a | grep "xqerl" | awk '{print $3}' | xargs docker rmi

.PHONY: travis
travis: 
	@travis env set DOCKER_USERNAME $(shell git config --get user.name)
	@#travis env set DOCKER_PASSWORD
	@travis env list

.PHONY: network 
network: 
	@docker network create $(NETWORK)
