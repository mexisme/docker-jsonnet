# You should override $PARENT at build-time to name the upper-level container
#     e.g. node:7-alpine
# Override $SECRETS_CONFIG_FILE to use a different get-secrets config. file

# Note: This will only work for recent versions of Docker
# Note: Your $PARENT base OS/Distribution (Debian or Alpine) must be compatible with the Golang builder base.
#      A Golang binary built with Debian won't usually work on Alpine out-of-the-box, for example

ARG PARENT
ARG PARENT_CC=$PARENT
ARG PARENT_GOLANG

# Debian-based builder:
# ARG PARENT=debian
# ARG PARENT_CC=debian
# ARG PARENT_GOLANG=golang:1.10

# Alpine-based builder:
# ARG PARENT=alpine
# ARG PARENT_CC=alpine
# ARG PARENT_GOLANG=golang:1.10-alpine

ARG ROOT_USER=root

##########

FROM $PARENT_CC as cc_builder

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y git make build-essential; \
    \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates git build-base; \
    fi

WORKDIR /src

RUN git clone https://github.com/google/jsonnet.git
RUN cd jsonnet && make jsonnet
RUN cp -av jsonnet/jsonnet /

##########

FROM $PARENT_GOLANG as go_builder

ARG GOPATH=/src

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y git make; \
    \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates git make; \
    fi

WORKDIR $GOPATH

RUN go get -v github.com/google/go-jsonnet/jsonnet
RUN cp -av $GOPATH/bin/jsonnet /

#RUN git clone git@github.com:google/go-jsonnet.git

##########

FROM $PARENT
USER $ROOT_USER

RUN if [ -f /etc/debian_version ]; then \
      apt-get update && apt-get upgrade -y && \
      apt-get install -y ca-certificates && \
      addgroup app && \
      adduser --disabled-password --ingroup app --home /app --shell /bin/sh app; \
      \
    elif [ -f /etc/alpine-release ]; then \
      apk upgrade --no-cache --update && \
      apk add --no-cache --update ca-certificates && \
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