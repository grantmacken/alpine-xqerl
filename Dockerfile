# Dockerfile grantmacken/alpine-xqerl
# https://github.com/grantmacken/alpine-xqerl
# FROM beardedeagle/alpine-erlang-builder  as shell
FROM erlang:alpine as shell
# LABEL maintainer="${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
# Set working directory
ARG REPO=https://github.com/zadean/xqerl.git
ARG BRANCH=master

WORKDIR /home
RUN apk add --no-cache --virtual .build-deps git \
  && git clone --depth=1 --branch ${BRANCH} --progress ${REPO}
WORKDIR  /home/xqerl
ENTRYPOINT ["rebar3", "shell"]

FROM erlang:alpine as rel
COPY --from=shell /home/xqerl /home/xqerl
WORKDIR /home/xqerl
RUN apk add --no-cache --virtual .build-deps git \
 && sed -i '/dev_mode/a  {include_src, false},' rebar.config \
 && rebar3 release -o /usr/local \
 && rm -rf /home/xqerl \
 && apk del .build-deps
WORKDIR /usr/local/
ENTRYPOINT ["/bin/ash"]

FROM alpine:3.9 as min
COPY --from=rel /usr/local/xqerl /usr/local/xqerl
RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs \
    && ln -sf /dev/stdout /usr/local/xqerl/log/erl.log
ENV XQERL_HOME /usr/local/xqerl
WORKDIR /usr/local/xqerl
EXPOSE 8081
ENV LANG C.UTF-8
STOPSIGNAL SIGQUIT
ENTRYPOINT ["./bin/xqerl","foreground" ]
