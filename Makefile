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
  --target="$(if $(TARGET),$(TARGET),$(DOCKER_TAG))" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(DOCKER_TAG))" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(DOCKER_TAG))-$(shell date --iso | sed s/-//g)" \
 .

.PHONY: push
push:
	@echo '## $@ ##'
	@docker push $(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(DOCKER_TAG))
	@docker push $(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(DOCKER_TAG))-$(shell date --iso | sed s/-//g)

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

.PHONY: rec
rec:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/csv.cast \
 --overwrite \
 --title='grantmacken/alpine-xqerl ran `make up'\
 --idle-time-limit 1 \
 --command="\
sleep 1 && printf %60s | tr ' ' '='  && echo && \
echo ' - start the container ... ' && \
make --silent up   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - check running container status ... ' && \
make --silent check   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - example xqerl command using \"docker exec\" ... ' && \
echo 'xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \"). ... '  && \
make --silent do   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
make --silent down && \
sleep 1 && printf %60s | tr ' ' '='  && echo\
"

PHONY: play
play:
	@clear && asciinema play ../tmp/csv.cast

.PHONY: upload
upload:
	asciinema upload ../tmp/csv.cast
