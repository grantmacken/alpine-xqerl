# Dockerfile grantmacken/alpine-xqerl
# https://github.com/grantmacken/alpine-xqerl
# FROM beardedeagle/alpine-erlang-builder  as shell
FROM erlang:alpine as shell
# LABEL maintainer="${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
# Set working directory
# RUN mkdir -p /home/rebar3/bin
WORKDIR /home

RUN apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/zadean/xqerl.git
WORKDIR  /home/xqerl
ENTRYPOINT ["rebar3", "shell"]

FROM erlang:alpine as rel
WORKDIR /home
COPY ./inc inc
COPY --from=shell /home/xqerl /home/xqerl
RUN apk add --no-cache --virtual .build-deps git \
 && cd xqerl \
 && rm rebar.config \
 && mv /home/inc/rebar.config rebar.config \
 && rm -rv /home/inc \
 && rebar3 as prod release

FROM alpine:3.9 as min
# Install some libs
RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs

COPY --from=rel /home/xqerl/_build/prod/rel/xqerl /usr/local/xqerl
ENV XQERL_HOME /usr/local/xqerl
WORKDIR /usr/local/xqerl
ENTRYPOINT ["./bin/xqerl","foreground" ]
EXPOSE 8081
ENV LANG C.UTF-8
STOPSIGNAL SIGQUIT
