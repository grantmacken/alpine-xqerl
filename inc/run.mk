.PHONY: run-shell
run-shell:
	@echo $(CURDIR)
	@docker run \
  -it --rm \
  --name shell \
  --network www \
  --publish 8082:8081 \
  --log-driver=$(XQERL_LOG_DRIVER) \
  --mount "type=bind,source=$(CURDIR)/fixtures,target=/home/xqerl/fixtures" \
  --detach \
  grantmacken/alpine-xqerl:shell
	@echo -n '- IP address: '
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' shell
	@printf %60s | tr ' ' '-' && echo
	@docker ps --filter name=shell --format ' -    name: {{.Names}}'
	@docker ps --filter name=shell --format ' -  status: {{.Status}}'
	@echo -n '-    port: '
	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
	@docker attach shell

.PHONY: run-dev
run-dev:
	@mkdir -p src
	@docker run \
  --name xqDev \
  --hostname gmack.nz \
  --network www \
  --publish 8083:8081 \
  --log-driver=$(XQERL_LOG_DRIVER) \
  -it --rm \
  grantmacken/alpine-xqerl:rel

.PHONY: attach-shell
attach-shell:
	@echo '## $@ ##'
	@docker attach shell



# .PHONY: attach
# attach:
# 	@echo '## $@ ##'
# 	@docker exec  xqerl remote_console

# .PHONY: run
# run:
# 	@docker run \
#   --name $(XQN) \
#   --hostname gmack.nz \
#   --network www \
#   --publish 8082:8081 \
#   --log-driver=$(XQERL_LOG_DRIVER) \
#   --mount "type=bind,source=$(CURDIR)/fixtures,target=$(XQERL_HOME)/fixtures" \
#   --rm -d \
#   grantmacken/alpine-xqerl:min foreground




