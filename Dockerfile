ARG SIMPLE_SIDECAR_VERSION=1.0.1
ARG BUILD_PREFIX=/usr/local/sidecar

FROM dbhys/net-simplesidecar-build:2.0.0 as build-stage

FROM dbhys/openresty-stage:2.0.1
ARG BUILD_PREFIX

LABEL name="dbhys net simplesidecar" version="1.0.1"

MAINTAINER Milas King

COPY ./bin /usr/local/bin
COPY ./crontabs /var/spool/cron/crontabs

COPY --from=build-stage ${BUILD_PREFIX}/deps/lib/lua/5.1/ /usr/local/openresty/luajit/lib/lua/5.1/
COPY --from=build-stage ${BUILD_PREFIX}/deps/share/lua/5.1/ /usr/local/openresty/luajit/share/lua/5.1/
COPY ./deps/ ./deps/

COPY ./sidecar/ ./sidecar/
COPY ./conf/ ./conf/
COPY ./config/ ./config/

RUN mkdir -p logs \
    && /usr/local/bin/replace_listen_port.sh

CMD /usr/local/openresty/bin/openresty -p ${PREFIX} -g 'daemon off;'

STOPSIGNAL SIGQUIT
