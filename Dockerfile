ARG SIDECAR_BUILD_VERSION=1.0.2
ARG BUILD_PREFIX=/usr/local/sidecar

FROM dbhys/net-simplesidecar-build:${SIDECAR_BUILD_VERSION} as build-stage

FROM dbhys/openresty-stage:2.0.1
ARG BUILD_PREFIX

LABEL name="dbhys net simplesidecar" version="1.0.2"

MAINTAINER Milas King

COPY --from=build-stage ${BUILD_PREFIX}/deps/lib/lua/5.1/ /usr/local/openresty/luajit/lib/lua/5.1/
COPY --from=build-stage ${BUILD_PREFIX}/deps/share/lua/5.1/ /usr/local/openresty/luajit/share/lua/5.1/

COPY ./bin/nginx_logrotate.sh /usr/local/bin/
COPY ./crontabs /var/spool/cron/crontabs

COPY ./ ./

ENTRYPOINT ["bin/docker-entrypoint.sh"]

CMD /usr/local/openresty/bin/openresty -p ${PREFIX} -g 'daemon off;'

STOPSIGNAL SIGQUIT

# docker build -t dbhys/net-simplesidecar:1.0.2 .
