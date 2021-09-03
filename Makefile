SHELL=/bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
include .env
XQERL_IMAGE = $(GHPKG_REGISTRY)/$(REPO_OWNER)/$(REPO_NAME)/$(RUN_NAME):$(GHPKG_VER)
include inc/*

.PHONY: clean
clean:
	@rm -f rebar.config
	@rm -f $(Escripts)
	@#docker rmi $$(docker images -a | grep "xqerl" | awk '{print $$3}')
