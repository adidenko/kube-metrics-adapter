#
# kube-metrics-adapter.dockerfile
#
# Wayfair version of Dockerfile to build our own image
#
# @author Oleksandr Didenko <odidenko@wayfair.com>
# @copyright 2022 Wayfair, LLC -- All rights reserved.

FROM library/golang:1.20 as test
ENV GOPATH=/go
ENV PATH="$PATH:$GOPATH/bin"
WORKDIR /go/src/github.com/zalando-incubator/kube-metrics-adapter
COPY . ./
RUN make test

FROM test as build
ENV GOPATH=/go
ENV PATH="$PATH:$GOPATH/bin"
WORKDIR /go/src/github.com/zalando-incubator/kube-metrics-adapter
RUN make build.linux

FROM external/alpine:3.15.0
ENV wf_version="v0.1.18.2-wf"
ENV wf_description="A fork of a project from Github"
LABEL \
  com.wayfair.app="zalando-incubator/kube-metrics-adapter" \
  com.wayfair.description=${wf_description}

WORKDIR /
COPY --from=build /go/src/github.com/zalando-incubator/kube-metrics-adapter/build/linux/kube-metrics-adapter /

RUN apk add --no-cache tzdata

ENTRYPOINT ["/kube-metrics-adapter"]
