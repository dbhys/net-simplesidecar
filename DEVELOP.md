## Command

### Build

docker build -f Dockerfile-build -t dbhys/net-simplesidecar-build:1.0.2 .

docker build -t dbhys/net-simplesidecar:1.0.2 .

### Run

When you run this image directly or test your service on your host, we recommended that you use “--net=host” arg to run docker container. But it doesn't work on Mac, https://docs.docker.com/desktop/mac/networking/, 
if you want to proxy in mac, please add upstream_ip = gateway.docker.internal
 in config/config.conf.

#### Run a container

docker run -d --rm --name ssc --net=host -v /Users/king/Workspace/dbhys/net-simplesidecar/config:/usr/local/stage/config dbhys/net-simplesidecar:1.0.1

MAC: 
docker run -d --rm --name ssc -p your_listen_port:your_listen_port -v /Users/king/Workspace/dbhys/net-simplesidecar/config:/usr/local/stage/config dbhys/net-simplesidecar:1.0.2
docker run -d --rm --name ssc -p 8008:8008 -v /Users/king/Workspace/dbhys/net-simplesidecar/config:/usr/local/stage/config dbhys/net-simplesidecar:1.0.2

#### Run in container

1. docker run -it --rm --name ssc --net=host dbhys/net-simplesidecar:1.0.2 sh
MAC:
docker run -it --rm --name ssc -p 8008:8008 -v /Users/king/Workspace/dbhys/net-simplesidecar/config:/usr/local/stage/config dbhys/net-simplesidecar:1.0.2 sh

2. /usr/local/openresty/bin/openresty -p ${PREFIX} -g 'daemon off;'

#### Clear the dangling images

    docker rmi $(docker images -q -f dangling=true)