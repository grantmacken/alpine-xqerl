##################################################################
MustHaveNetwork = docker network list --format "{{.Name}}" | \
 grep -q $(1) || docker network create $(NETWORK) &>/dev/null

MustHaveVolume = docker volume list --format "{{.Name}}" | \
 grep -q $(1) || docker volume create --driver local --name $(1) &>/dev/null
#
# volume mounts
MountCode := type=volume,target=$(XQERL_HOME)/code,source=xqerl-compiled-code
MountData := type=volume,target=$(XQERL_HOME)/data,source=xqerl-database
MountAssets := type=volume,target=$(XQERL_HOME)/priv/static,source=static-assets
BindMount := type=bind,target=/tmp,source=$(CURDIR)/src/data

.PHONY: up
up:
	@echo '| $(@): $(XQERL_IMAGE) |'
	@if ! docker container inspect -f '{{.State.Running}}' $(RUN_NAME) &>/dev/null
	then 
	@$(call MustHaveNetwork,$(NETWORK))
	@$(call MustHaveVolume,xqerl-compiled-code)
	@$(call MustHaveVolume,xqerl-database)
	@$(call MustHaveVolume,static-assets)
	docker run --rm \
	--name  $(RUN_NAME) \
	--env "TZ=$(TZ)" \
	--env "NAME=$(NAME)" \
	--hostname $(HOST_NAME) \
	--network $(NETWORK) \
	--mount $(MountCode) \
	--mount $(MountData) \
  --mount $(MountAssets) \
	--mount $(BindMount) \
	--publish $(HOST_PORT):8081 \
	--detach \
	$(XQERL_IMAGE)	
	fi
	@while ! bin/xq eval 'application:ensure_all_started(xqerl).' &>/dev/null
	do
	echo ' ... '
	sleep 1 
	done
	@echo -n ' - $(RUN_NAME) running: ' 
	docker container inspect -f '{{.State.Running}}' $(RUN_NAME)
	@echo -n ' - xqerl application all started: ' 
	bin/xq eval 'application:ensure_all_started(xqerl).' | grep -oP 'ok'
	@$(MAKE) --silent escripts
	@$(MAKE) --silent main-modules

.PHONY: down
down:
	@echo '| $(@): $(XQERL_IMAGE) |'
	@docker stop $(RUN_NAME)

.PHONY: run-shell
run-shell:
	@docker run  -it --rm \
  --name  xqShell \
  $(REPO_OWNER)/$(REPO_NAME):shell
