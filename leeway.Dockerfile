FROM node:12.14.1-alpine AS node_installer

RUN mkdir -p /theia/node/bin \
    /theia/node/include/node/ \
    /theia/node/lib/node_modules/npm/ \
    /theia/node/lib/ && \
    cp -a  /usr/local/bin/node              /theia/node/bin/ && \
    cp -a  /usr/local/bin/npm               /theia/node/bin/ && \
    cp -a  /usr/local/bin/npx               /theia/node/bin/ && \
    cp -ar /usr/local/include/node/         /theia/node/include/ && \
    cp -ar /usr/local/lib/node_modules/npm/ /theia/node/lib/node_modules/

FROM alpine:3.9 AS builder_alpine

RUN apk add --no-cache bash gcc g++ make pkgconfig python libc6-compat libexecinfo-dev git patchelf findutils

RUN cp /theia/node/bin/node /theia/node/bin/gitpod-node && rm /theia/node/bin/node

FROM scratch
COPY --from=builder_alpine /theia/ /theia/

WORKDIR /ide/
COPY supervisor-ide-config.json /ide/

# supervisor is still needed here to work without registry-facade
# TODO(cw): remove once registry-facade is standard (except for supervisor-ide-config.json)
COPY components-supervisor--app/supervisor /theia/supervisor
COPY components-docker-up--app/* /theia/
COPY supervisor-config.json supervisor-ide-config.json /theia/
