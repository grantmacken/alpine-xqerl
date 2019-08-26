include .env

default: 
	@docker run -it grantmacken/alpine-xqerl:shell

.PHONY: shell
shell:
	@docker run -it grantmacken/alpine-xqerl:shell

.PHONY: slim
slim:
	@docker run grantmacken/alpine-xqerl:slim --name xql

.PHONY: check
check:
	@docker ps -a
	@docker-compose logs
	@docker exec $(XQERL_CONTAINER_NAME) ls -al ./bin
	@docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
	@#docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."

.PHONY: do
do:
	@docker exec xq ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
	@docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."
.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down

.PHONY: buildTargetShell
buildTargetShell:
	@docker build \
  --target="shell" \
  --tag="$(DOCKER_IMAGE):shell" \
 .

.PHONY: build
build:
	@docker build \
  --target="$(if $(TARGET),$(TARGET),slim)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),slim)" \
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
