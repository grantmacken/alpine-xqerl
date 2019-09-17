# [alpine-xqerl](https://github.com/grantmacken/alpine-xqerl)

Pre-build images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl)

Test build on [travis-ci](https://travis-ci.org/grantmacken/alpine-xqerl)

[![Build Status](https://travis-ci.org/grantmacken/alpine-eXist.svg?branch=master)](https://travis-ci.org/grantmacken/alpine-xqerl)

 [xqerl](https://zadean.github.io/xqerl)
 maintained by 
 [Zachary Dean](https://github.com/zadean),
 is an Erlang XQuery 3.1 Processor and XML Database.

## Deploy Image

```
docker pull grantmacken/alpine-xqerl:latest
```

Or you can pull the same image, tagged with the xqerl semver versioning,
which currently stands at [ 0.8.1 ]


This is a smallish  'deploy' image, where a binary executable boots the xqerl environment,

```
ENTRYPOINT ["./bin/xqerl","foreground" ]
```

The easiest way to use this image is through docker-compose.
I have provided and example 'docker-compose.yml' and '.env' 
which you can copy/clone and modify to use to boot your xqerl project.

The docker-compose run time environment includes
* A container name 'xq'
* Two persistent docker volumes 
    1. A volume named 'data' which holds the database data
    2. A volume name 'code' which holds the compiled xQuery  beam files 
* A network named 'www' 
* A port published on 8081

In my docker-compose the running container attaches to a pre-existing 
named network, so you will need to create that first. 
You only need to do this once
 
```
docker network create --driver=bridge www
```

Now to bring the container up.

```
docker-compose up -d
```

Once the container is up running, you can issue 
docker exec commands, like this ...

```
docker exec xq ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
docker exec xq ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."
```

The following cast 
1. brings the container up `docker-compose up -d`
2. runs various docker commands like `docker ps --filter name=xq --format ' -  status: {{.Status}}'`
3. runs `docker exec xq` commands
4. brings down the container  `docker-compose down`

[![asciicast](https://asciinema.org/a/264230.svg)](https://asciinema.org/a/264230)


## Fat Playground Desktop Image

This image is tagged 'shell'

```
docker run -it --rm grantmacken/alpine-xqerl:shell
```

This starts xqerl from ENTRYPOINT `rebar3 shell` to pop you into
the *interactive* erlang shell. 
The container contains a clone the  [xqerl repo](https://zadean.github.io/xqerl) so from here you should be able to follow the 
[Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md)
tutorial from section 4 onwards.

If you have a OS with 'systemd' init system (i.e. most modern linux OS),
you may also want to view the xqerl logged output from the container. 

```
docker run \
  -it --rm \
  --name xqShell \
  --network www \
  --publish 8081:8081 \
  --log-driver=journald \
  grantmacken/alpine-xqerl:shell
```

Now in the erlang shell, as you work through the [Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md) tutorial,
in another terminal you can follow the container logged output, by using the following command.

```
sudo journalctl -b CONTAINER_NAME=xqShell --all -f
```







 


