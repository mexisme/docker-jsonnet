JSONNET-VERSION=0.13.0

DOCKER=docker

GOLANG-VERSION=1.12
DOCKER-REPO=mexisme/jsonnet

.PHONY: all latest
all: build latest
latest: alpine
	$(DOCKER) tag $(DOCKER-REPO):$< $(DOCKER-REPO):$@

.PHONY: build
build: alpine debian

.PHONY: alpine debian
alpine: alpine-build/Dockerfile
debian: debian-build/Dockerfile
alpine debian:
	$(DOCKER) build --tag=$(DOCKER-REPO):$@ --tag=$(DOCKER-REPO):$(JSONNET-VERSION)-$@ --file $< .

alpine-build/Dockerfile: alpine-build
alpine-build/Dockerfile: PARENT=alpine
alpine-build/Dockerfile: PARENT_CC=alpine
alpine-build/Dockerfile: PARENT_GOLANG=golang:$(GOLANG-VERSION)-alpine

alpine-build/Dockerfile: debian-build
debian-build/Dockerfile: PARENT=debian
debian-build/Dockerfile: PARENT_CC=debian
debian-build/Dockerfile: PARENT_GOLANG=golang:$(GOLANG-VERSION)

alpine-build debian-build:
	mkdir -pv $@

alpine-build/Dockerfile debian-build/Dockerfile: template.dockerfile
	sed -e 's/%PARENT%/$(PARENT)/g;s/%PARENT_CC%/$(PARENT_CC)/g;s/%PARENT_GOLANG%/$(PARENT_GOLANG)/g' <$< >$@

.PHONY: update update-vendored
update: update-vendored alpine-build/Dockerfile debian-build/Dockerfile

# Note: You need to install https://github.com/ingydotnet/git-subrepo for this to work:
update-vendored:
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule foreach --recursive git checkout v$(JSONNET-VERSION)

.PHONY: push
push: alpine debian latest
	for D in $^; do \
	  $(DOCKER) push $(DOCKER-REPO):$$D; \
	  [[ $$D = latest ]] || $(DOCKER) push $(DOCKER-REPO):$(JSONNET-VERSION)-$$D; \
	done
