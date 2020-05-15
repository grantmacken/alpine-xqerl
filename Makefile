SHELL=/bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

include .env

# include inc/checks.mk
# include inc/run.mk
#XQN=shell
XQN=$(XQERL_CONTAINER_NAME)
EVAL=docker exec $(XQERL_CONTAINER_NAME) xqerl eval

Address = http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQERL_CONTAINER_NAME)):$(CONFIG_PORT)

HEAD_SHA != curl -s https://api.github.com/repos/zadean/xqerl/git/ref/heads/master | jq -Mr '.object.sha'
THIS_SHA != grep -oP 'REPO_SHA=\K(.+)' .env

.PHONY: build
build: shell
	@docker buildx build --output "type=image,push=false" \
  --tag="$(REPO_OWNER)/$(REPO_NAME):$(THIS_SHA)" \
  --tag="$(REPO_OWNER)/$(REPO_NAME):latest" \
  --tag="docker.pkg.github.com/$(REPO_OWNER)/$(REPO_NAME)/$(XQERL_CONTAINER_NAME):$(GHPKG_VER)" \
 .
	@echo

.PHONY: clean
clean:
	@rm -f xqerl.config rebar.config
	@#docker rmi $$(docker images -a | grep "xqerl" | awk '{print $$3}')

xqerl.config:
	@cat << EOF | tee $@
	%% -------------------------------------------------------------------
	%%
	%% xqerl - XQuery processor
	%%
	%% Copyright (c) 2017-2020 Zachary N. Dean  All Rights Reserved.
	%%
	%% This file is provided to you under the Apache License,
	%% Version 2.0 (the "License"); you may not use this file
	%% except in compliance with the License.  You may obtain
	%% a copy of the License at
	%%
	%%   http://www.apache.org/licenses/LICENSE-2.0
	%%
	%% Unless required by applicable law or agreed to in writing,
	%% software distributed under the License is distributed on an
	%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
	%% KIND, either express or implied.  See the License for the
	%% specific language governing permissions and limitations
	%% under the License.
	%%
	%% -------------------------------------------------------------------
	[{xqerl, [
	   {log_file, "$(CONFIG_LOG_FILE)"},
	   {data_dir, "$(CONFIG_DATA_DIR)"},
	   {code_dir, "$(CONFIG_CODE_DIR)"},
	   {port, $(CONFIG_PORT)},
	   {trace_handler , xqerl_trace_h},
	   {event_handlers, []},
	   {environment_access, $(CONFIG_ENVIRONMENT_ACCESS)}
	 ]},
	%% Index Settings
	 {merge_index, []},
	 {emojipoo, [ {default_depth, 15}]}
	].
	EOF

# 	% {debug_info, strip}

rebar.config:
	@cat << EOF | tee $@
	{minimum_otp_vsn, "21.2"}.
	{deps,[
	{xs_regex,    ".*", {git, "https://github.com/zadean/xs_regex.git",    {branch, "master"}}},
	{xmerl_sax,   ".*", {git, "https://github.com/zadean/xmerl_sax.git",   {branch, "master"}}},
	{erluca,      ".*", {git, "https://github.com/zadean/erluca.git",      {branch, "master"}}},
	{merge_index, ".*", {git, "https://github.com/zadean/merge_index.git", {branch, "zadean"}}},
	{emojipoo,    ".*", {git, "https://github.com/zadean/emojipoo.git",    {branch, "master"}}},
	{htmerl,      ".*", {git, "https://github.com/zadean/htmerl.git",      {branch, "master"}}},
	{hackney,     ".*", {git, "https://github.com/benoitc/hackney.git",    {branch, "master"}}},
	{cowboy,      ".*", {git, "https://github.com/ninenines/cowboy.git",   {branch, "master"}}},
	{sext,        ".*", {git, "https://github.com/uwiger/sext.git",        {branch, "master"}}},
	{locks,       ".*", {git, "https://github.com/uwiger/locks.git",       {branch, "master"}}},
	{uuid,        ".*", {git, "https://github.com/okeuday/uuid.git",       {tag, "v1.7.5"}}},
	{basexerl,    ".*", {git, "https://github.com/zadean/basexerl.git",    {branch, "master"}}}
	]}.
	{erl_opts, [
	  {i ,"include"},
	  debug_info
	]}.
	{shell, [{config, "config/xqerl.config"}]}.
	{profiles, 
	[{ test, [ {ct_opts, [ {sys_config, ["config/xqerl.test.config"]},{logopts, [no_src]}]}]},
	 {prod, 
	  [{relx, [ 
	    {dev_mode, false},
	    {include_src, false},
	    {include_erts, true} ]}]
	}]
	}.
	{relx, [{release, {xqerl, {git, long}}, [xqerl]},
	  {sys_config, "config/xqerl.config"},
	  {vm_args_src,    "config/vm.args.src"},
	  {dev_mode, true},
	  {include_erts, false},
	  {extended_start_script, true},
	  {overlay, [{mkdir, "log"},
	    {mkdir, "code"},
	    {mkdir, "data"}]}
	]}.

.PHONY: shell
shell: sha xqerl.config rebar.config 
	@docker buildx build --output "type=image,push=false" \
  --target $@ \
  --tag="$(REPO_OWNER)/$(REPO_NAME):$@" \
 .
	@echo

.PHONY: sha
sha:
	@echo "previous commit sha: $(THIS_SHA)"
	@LATEST=$(HEAD_SHA);echo "  latest commit sha: $$LATEST";\
  if [ ! "$$LATEST" = "$(THIS_SHA)" ]; then sed -i 's/REPO_SHA.*/REPO_SHA=$(HEAD_SHA)/' .env ; fi

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down



.PHONY: network 
network: 
	@docker network create $(NETWORK)

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

.PHONY: run-shell
run-shell:
	@docker run  -it --rm \
  --name  xqShell \
  $(DOCKER_IMAGE):shell

