# Dockerfile grantmacken/alpine-xqerl
# https://github.com/grantmacken/alpine-xqerl
FROM erlang:alpine
# LABEL maintainer="${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
WORKDIR /home
RUN apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/zadean/xqerl.git \
  && cd xqerl \
  && rebar3 compile \
  && rebar3 release -o _build

FROM alpine:3.10
# Install some libs
RUN apk add --no-cache openssl ncurses-libs 
COPY --from=0 /home/xqerl/_build/xqerl /usr/local/xqerl
ENV XQERL_HOME /usr/local/xqerl
WORKDIR $XQERL_HOME  
ENTRYPOINT ["./bin/xqerl"]
CMD ["foreground"]
EXPOSE 8081
ENV LANG C.UTF-8
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT


