DOCKER=docker

GOLANG-VERSION=1.10
DOCKER-REPO=mexisme/jsonnet

all: alpine debian latest

latest: alpine
	$(DOCKER) tag $(DOCKER-REPO):$< $(DOCKER-REPO):$@

alpine: GOLANG-TAG=$(GOLANG-VERSION)-$@
debian: GOLANG-TAG=$(GOLANG-VERSION)
alpine debian:
	$(DOCKER) build --tag=$(DOCKER-REPO):$@ --build-arg=PARENT_GOLANG=golang:$(GOLANG-TAG) --build-arg=PARENT=$@ .

push: alpine debian latest
	for D in $^; do $(DOCKER) push $(DOCKER-REPO):$$D; done
