# syntax=docker/dockerfile:experimental
# @ref: https://adoptingerlang.org/docs/production/docker# 
# @ref: https://github.com/grantmacken/alpine-xqerl
#@ https://github.com/erlang/docker-erlang-otp

FROM erlang:23.3.1-alpine as shell
LABEL maintainer="Grant MacKenzie <grantmacken@gmail.com>"

WORKDIR /home
COPY .env rebar.config  ./

ENV HOME /home
ENV LANG C.UTF-8
ENV REBAR_BASE_DIR /home/_build

RUN  --mount=type=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache \
    && apk add git \
    && source .env \
    && git clone --depth=1 --branch ${REPO_BRANCH} --progress ${REPO_URI} \
    && sed -i "s/false/${CONFIG_ENVIRONMENT_ACCESS}/g" ./xqerl/config/xqerl.config \
    && rm ./xqerl/rebar.config \
    && mv ./rebar.config ./xqerl/rebar.config

WORKDIR /home/xqerl
RUN --mount=type=cache,target=/home/.cache/rebar3 rebar3 compile

WORKDIR /home/xqerl
ENTRYPOINT ["rebar3", "shell"]

# create a tar release based on the rebar.conf
# - include erts 
# - don't include src files
# - dev_mode set as false

FROM shell as prod

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/home/.cache/rebar3 \
    apk add --update git tar \
    && cd /home/xqerl \
    && rebar3 as prod tar \
    && mkdir /usr/local/xqerl \
    && tar -zxvf ${REBAR_BASE_DIR}/prod/rel/*/*.tar.gz -C /usr/local/xqerl
    
FROM alpine:3.13.4
COPY --from=prod /usr/local/xqerl /usr/local/xqerl

RUN  --mount=type=cache,target=/var/cache/apk \
      ln -vs /var/cache/apk /etc/apk/cache \
      && apk add --update openssl ncurses tzdata \
      && ln -s /usr/local/xqerl/bin/xqerl /usr/local/bin/xqerl

ENV XQERL_HOME /usr/local/xqerl
ENV HOME=/home
WORKDIR /usr/local/xqerl
STOPSIGNAL SIGQUIT
ENTRYPOINT ["xqerl","foreground" ]


