# syntax=docker/dockerfile:experimental
# @ref: https://adoptingerlang.org/docs/production/docker# 
# @ref: https://github.com/grantmacken/alpine-xqerl
#@ https://github.com/erlang/docker-erlang-otp

FROM docker.io/erlang:24.0.6-alpine as shell
LABEL maintainer="Grant MacKenzie <grantmacken@gmail.com>"

WORKDIR /home
COPY .env rebar.config  ./

ENV HOME /home
ENV LANG C.UTF-8
ENV REBAR_BASE_DIR /home/_build

RUN  apk add git \
    && source .env \
    && git clone --depth=1 --branch ${REPO_BRANCH} --progress ${REPO_URI} \
    && sed -i "s/false/${CONFIG_ENVIRONMENT_ACCESS}/g" ./xqerl/config/xqerl.config \
    && rm ./xqerl/rebar.config \
    && mv ./rebar.config ./xqerl/rebar.config

WORKDIR /home/xqerl
RUN  rebar3 compile

WORKDIR /home/xqerl
ENTRYPOINT ["rebar3", "shell"]

# create a tar release based on the rebar.conf
# - include erts 
# - don't include src files
# - dev_mode set as false

FROM shell as prod

RUN apk add --update git tar \
    && cd /home/xqerl \
    && rebar3 as prod tar \
    && mkdir /usr/local/xqerl \
    && tar -zxvf ${REBAR_BASE_DIR}/prod/rel/*/*.tar.gz -C /usr/local/xqerl
    
FROM docker.io/alpine:3.14.2
COPY --from=prod /usr/local/xqerl /usr/local/xqerl

RUN apk add --no-cache openssl ncurses-libs tzdata libstdc++ \
    && ln -s /usr/local/xqerl/bin/xqerl /usr/local/bin/xqerl

ENV XQERL_HOME /usr/local/xqerl
ENV HOME=/home
WORKDIR /usr/local/xqerl
STOPSIGNAL SIGQUIT
ENTRYPOINT ["xqerl","foreground" ]


