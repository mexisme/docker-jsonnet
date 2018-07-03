DOCKER=docker
DOCKER-BUILD=$(DOCKER) build

GOLANG-VERSION=1.10
DOCKER-TAG=jsonnet

alpine:
	$(DOCKER-BUILD) --tag=$(DOCKER-TAG):alpine --build-arg=PARENT_GOLANG=golang:$(GOLANG-VERSION)-alpine --build-arg=PARENT=alpine .
debian:
	$(DOCKER-BUILD) --tag=$(DOCKER-TAG):debian --build-arg=PARENT_GOLANG=golang:$(GOLANG-VERSION) --build-arg=PARENT=debian .
