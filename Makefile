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
Note:
tag now from zadean git heads/master ref sha


endef


help: export HELP=$(mkHelp)
help:
	@echo "$${HELP}"

SHA != curl -s https://api.github.com/repos/zadean/xqerl/git/ref/heads/master | jq -Mr '.object.sha'

.PHONY: build
build:
	@export DOCKER_BUILDKIT=1;\
  docker buildx build -o type=docker \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(SHA))" \
  --tag="$(DOCKER_IMAGE):latest" \
 .
	@echo

.PHONY: sha
sha:
	@sed -i 's/REPO_SHA.*/REPO_SHA=$(SHA)/' .env



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


