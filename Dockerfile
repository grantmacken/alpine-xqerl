# Dockerfile grantmacken/alpine-xqerl
# https://github.com/grantmacken/alpine-xqerl
FROM erlang:alpine as shell
# LABEL maintainer="${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
WORKDIR /home
RUN apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/zadean/xqerl.git \
  && cd xqerl \
  && rebar3 compile \
  && rebar3 release -o _build

WORKDIR  /home/xqerl
ENTRYPOINT ["rebar3", "shell"]
# CMD ["application:ensure_all_started(xqerl)"]

FROM alpine:3.9 as slim
COPY --from=shell /home/xqerl/_build/xqerl /usr/local/xqerl
COPY --from=shell /usr/lib/libncursesw* /usr/lib/
# Install some libs
ENV XQERL_HOME /usr/local/xqerl
WORKDIR /usr/local/xqerl
ENTRYPOINT ["./bin/xqerl","foreground" ]
# CMD ["foreground"]
EXPOSE 8081
ENV LANG C.UTF-8
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
#STOPSIGNAL SIGQUIT
STOPSIGNAL SIGQUIT


