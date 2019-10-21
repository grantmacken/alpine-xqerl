include .env
include inc/checks.mk
include inc/run.mk

#XQN=shell
XQN=$(XQERL_CONTAINER_NAME)
EVAL=docker exec $(XQN) xqerl eval


Address = http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) ):8081

define mkHelp
-------------------------------------------------------------------------------
targets:
 - to build docker image
make build 
 - to build image only to shell target
make build TARGET=shell

-------------------------------------------------------------------------------
endef


help: export HELP=$(mkHelp)
help:
	@echo "$${HELP}"

.PHONY: build
build:
	@export DOCKER_BUILDKIT=1;\
 docker buildx build -o type=docker \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),v$(DOCKER_TAG))" \
  --tag="$(DOCKER_IMAGE):latest" \
 .
	@echo

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down

.PHONY: push
push:
	@echo '## $@ ##'
	@docker push $(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),v$(DOCKER_TAG))

.PHONY: clean
clean:
	@#docker image prune -a
	@#docker container prune
	@docker rmi $$(docker images -a | grep "xqerl" | awk '{print $$3}')

.PHONY: network 
network: 
	@docker network create $(NETWORK)

