# syntax=docker/dockerfile:experimental
# @ref: https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md
# @ref: https://adoptingerlang.org/docs/production/docker# 
# @ref: https://github.com/grantmacken/alpine-xqerl
FROM erlang:22.1.1-alpine as shell
LABEL maintainer="Grant MacKenzie <grantmacken@gmail.com>"

RUN --mount=type=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache \
    && apk add --update git

WORKDIR /home
COPY .env  rebar.config ./
ENV HOME /home
ENV LANG C.UTF-8
ENV REBAR_BASE_DIR /home/_build

RUN source .env \
    && git clone --depth=1 --branch ${REPO_BRANCH} --progress ${REPO_URI} \
    && rm ./xqerl/rebar.config \
    && mv ./rebar.config ./xqerl/rebar.config

WORKDIR /home/xqerl

RUN --mount=type=cache,target=/home/.cache/rebar3 \
     rebar3 compile

ENTRYPOINT ["rebar3", "shell"]

# NOTE: could do a dev release stage

FROM shell as rel
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/home/.cache/rebar3 \
    apk add --update git \
    && cd /home/xqerl \
    && rebar3 as prod tar \
    && rebar3 release

FROM rel as prod

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/home/.cache/rebar3 \
    apk add --update git tar \
    && cd /home/xqerl \
    && rebar3 as prod tar \
    && mkdir /usr/local/xqerl \
    && tar -zxvf ${REBAR_BASE_DIR}/prod/rel/*/*.tar.gz -C /usr/local/xqerl
   
FROM alpine:3.10.2 as min

COPY --from=prod /usr/local/xqerl /usr/local/xqerl
RUN  --mount=type=cache,target=/var/cache/apk \
      ln -vs /var/cache/apk /etc/apk/cache \
      && apk add --update openssl ncurses \
      && ln -s /usr/local/xqerl/bin/xqerl /usr/local/bin/xqerl

ENV XQERL_HOME /usr/local/xqerl
WORKDIR ${XQERL_HOME}
EXPOSE 8081
STOPSIGNAL SIGQUIT
ENTRYPOINT ["xqerl","foreground" ]
