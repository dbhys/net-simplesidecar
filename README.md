# DBHYS-NET Simple Sidecar

## What's in Simple Sidecar

This is a project to build a docker image, this image provide following functions:
1. we can easily migrate traffic from one port to another， just send a reload(http://localhost:8008/sidecar/config/reload?secret=xxx) request.
2. We can also help the resource server verify the jwt token issued by the oidc provider through configuration.
3. We can also enable apm configuration to help resource server collect metrics to apm.
4. May be many application don't have access logs, this image will collect access logs by default and keep them for 7(you can change the crontab) days.

## More about this project

It is base on openresty and dbhys/openresty-stage images.

## How to use

**First:** 

We add env: $PREFIX, which should be dir your code in and is the same as openresty's $prefix or ${prefix}, you should add $PREFIX dir to the lua_package_path in your conf/nginx.conf. the example is in the [conf/nginx.conf](conf/nginx.conf), the [default value of $PREFIX](https://github.com/dbhys/openresty-stage/blob/master/Dockerfile) is /usr/local/stage.

**Second:** 

Copy config/config.yaml from git or from the container use docker command:
``` 

docker run -d --rm --name temp dbhys/net-simplesidecar:$verison

docker cp temp:/usr/local/stage/config/config.yaml $yourdir

docker stop temp

```

**Third:**

Mount your config dir to the container:
```
docker run -d --name sidecar -p 80:80 -v yourconfigdir:/usr/local/stage/config/ dbhys/net-simplesidecar:$verison
```