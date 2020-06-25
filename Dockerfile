# syntax=docker/dockerfile:experimental
# @ref: https://adoptingerlang.org/docs/production/docker# 
# @ref: https://github.com/grantmacken/alpine-xqerl
#@https://github.com/erlang/docker-erlang-otp


FROM erlang:23-alpine as shell
LABEL maintainer="Grant MacKenzie <grantmacken@gmail.com>"

WORKDIR /home
COPY .env  rebar.config xqerl.config ./
ENV HOME /home
ENV LANG C.UTF-8
ENV REBAR_BASE_DIR /home/_build

RUN  --mount=type=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache \
    && apk add git \
    && source .env \
    && git clone --depth=1 --branch ${REPO_BRANCH} --progress ${REPO_URI} \
    && rm ./xqerl/rebar.config \
    && rm ./xqerl/config/xqerl.config \
    && mv ./rebar.config ./xqerl/rebar.config \
    && mv ./xqerl.config ./xqerl/config/xqerl.config

WORKDIR /home/xqerl
RUN --mount=type=cache,target=/home/.cache/rebar3 \
     rebar3 compile

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

FROM alpine:3.12.0
COPY --from=prod /usr/local/xqerl /usr/local/xqerl

RUN  --mount=type=cache,target=/var/cache/apk \
      ln -vs /var/cache/apk /etc/apk/cache \
      && apk add --update openssl ncurses \
      && ln -s /usr/local/xqerl/bin/xqerl /usr/local/bin/xqerl \
      && mkdir /usr/local/xqerl/bin/scripts \
      && mkdir /usr/local/xqerl/code/src 

ENV XQERL_HOME /usr/local/xqerl
ENV XQERL_NAME xqerl@127.0.0.1
ENV XQERL_COOKIE monster
ENV HOME=/home
WORKDIR ${XQERL_HOME}
EXPOSE 8081
STOPSIGNAL SIGQUIT
ENTRYPOINT ["xqerl","foreground" ]


