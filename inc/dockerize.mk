HEAD_SHA = $(shell curl -s https://api.github.com/repos/zadean/xqerl/git/ref/heads/main | jq -Mr '.object.sha')
ENV_SHA = $(shell grep -oP 'REPO_SHA=\K(.+)' .env)
ENV_OTP = $(shell grep -oP 'FROM_ERLANG=\K(.+)' .env)
ENV_ALPINE = $(shell grep -oP 'FROM_ALPINE=\K(.+)' .env)
README_OTP = $(shell grep -oP 'OTP \K([0-9.]+)' README.md)
README_ALPINE = $(shell grep -oP 'alpine \K([0-9.]+)' README.md)
DF_ALPINE = $(shell grep -oP 'FROM alpine:\K(.+)' Dockerfile)
DF_ERLANG = $(shell grep -oP 'FROM erlang:\K([0-9.]+)' Dockerfile)

.PHONY: build
build: shell
	@docker buildx build --output "type=image,push=false" \
  --tag="$(REPO_OWNER)/$(REPO_NAME):$(ENV_SHA)" \
  --tag="$(REPO_OWNER)/$(REPO_NAME):latest" \
  --tag="$(GHPKG_REGISTRY)/$(REPO_OWNER)/$(REPO_NAME):$(GHPKG_VER)" \
 .
	@echo

.PHONY: shell
shell: sha rebar.config
	@docker buildx build --output "type=image,push=false" \
  --target $@ \
  --tag="$(REPO_OWNER)/$(REPO_NAME):$@" \
 .
	@echo


.PHONY: sha
sha: rebar.config
	@echo "previous commit sha: $(ENV_SHA)"
	@LATEST=$(HEAD_SHA);
	@echo "  latest commit sha: $$LATEST";
	if [ ! "$$LATEST" = "$(ENV_SHA)" ]; 
	then sed -i 's/$(ENV_SHA)/$(HEAD_SHA)/' .env
	fi
	@sed -i 's%$(ENV_SHA)%$(HEAD_SHA)%g' README.md
	@sed -i 's%$(README_OTP)%$(ENV_OTP)%g' README.md
	@sed -i 's%$(DF_ERLANG)%$(ENV_OTP)%g' Dockerfile
	@sed -i 's%$(README_ALPINE)%$(ENV_ALPINE)%g' README.md
	@sed -i 's%$(DF_ALPINE)%$(ENV_ALPINE)%g' Dockerfile
# 	% {debug_info, strip}
rebar.config:
	@cat << EOF > $@
	{minimum_otp_vsn, "21.2"}.
	{deps,[
	{xs_regex,    ".*", {git, "https://github.com/zadean/xs_regex.git",    {branch, "main"}}},
	{xmerl_sax,   ".*", {git, "https://github.com/zadean/xmerl_sax.git",   {branch, "main"}}},
	{erluca,      ".*", {git, "https://github.com/zadean/erluca.git",      {branch, "main"}}},
	{merge_index, ".*", {git, "https://github.com/zadean/merge_index.git", {branch, "zadean"}}},
	{emojipoo,    ".*", {git, "https://github.com/zadean/emojipoo.git",    {branch, "main"}}},
	{htmerl,      ".*", {git, "https://github.com/zadean/htmerl.git",      {branch, "main"}}},
	{hackney,     ".*", {git, "https://github.com/benoitc/hackney.git",    {branch, "master"}}},
	{cowboy,      ".*", {git, "https://github.com/ninenines/cowboy.git",   {branch, "master"}}},
	{sext,        ".*", {git, "https://github.com/uwiger/sext.git",        {branch, "master"}}},
	{locks,       ".*", {git, "https://github.com/uwiger/locks.git",       {branch, "master"}}},
	{uuid,        ".*", {git, "https://github.com/okeuday/uuid.git",       {tag, "v1.7.5"}}},
	{basexerl,    ".*", {git, "https://github.com/zadean/basexerl.git",    {branch, "main"}}}
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
	  {sys_config,  "config/xqerl.config"},
	  {vm_args_src, "config/vm.args.src"},
	  {dev_mode, true},
	  {include_erts, false},
	  {extended_start_script, true},
	  {overlay, [{mkdir, "log"},
	    {mkdir, "data"},
	    {mkdir, "priv"},
	    {mkdir, "priv/static"},
	    {mkdir, "priv/static/assets"},
	    {mkdir, "bin/scripts"},
	    {mkdir, "code"},
	    {mkdir, "code/src"}]}
	]}.
	EOF

