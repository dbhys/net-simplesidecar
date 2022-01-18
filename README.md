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

Notice: you must add $PREFIX dir to the lua_package_path in your conf/nginx.conf. the example is in the [conf/nginx.conf](conf/nginx.conf). actually, the $prefix is the dir behind "openresty -p", in our image it is the same as $PREFIX.

### Mount workdir

If you don't want to change anything of the container, just run your lua code, the best way is mount your workdir
to the container workdir(/usr/local/stage), and the dir must contain the file conf/nginx.conf

### From this image

You can build your own image from this image, May be just replace those enviroment variables or commands (PREFIX, COPY, EXPOSE...)
