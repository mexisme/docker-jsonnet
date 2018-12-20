# Use the attached Makefile to build target-specific Dockerfiles from this template.
# This file, as it stands, will not otherwise build correctly

# Debian-based builder:
# PARENT=debian
# PARENT_CC=debian
# PARENT_GOLANG=golang:1.11

# Alpine-based builder:
# PARENT=alpine
# PARENT_CC=alpine
# PARENT_GOLANG=golang:1.11-alpine


ARG ROOT_USER=root

##########

FROM %PARENT_CC% as cc_builder

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y git make build-essential; \
    \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates git build-base; \
    fi

WORKDIR /src

COPY vendor/jsonnet/ ./
RUN make jsonnet
RUN cp -av jsonnet /

##########

FROM %PARENT_GOLANG% as go_builder

ARG GOPATH=/src

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y git make build-essential; \
    \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates git build-base; \
    fi

WORKDIR $GOPATH/src/github.com/google/go-jsonnet

COPY vendor/go-jsonnet/ ./
RUN go get -v ./...
RUN go build -v
RUN cp -aiv jsonnet /

##########

FROM %PARENT%
USER $ROOT_USER

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y ca-certificates && \
      addgroup app && \
      adduser --disabled-password --ingroup app --home /app --shell /bin/sh app; \
      \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates libstdc++ && \
      addgroup app && \
      adduser -D -G app -h /app -s /bin/sh app; \
    fi

WORKDIR /

COPY --from=cc_builder /jsonnet jsonnet
COPY --from=go_builder /jsonnet go-jsonnet

RUN chmod a+x jsonnet*

VOLUME /src

USER app

CMD /jsonnet
