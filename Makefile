DOCKER=docker

GOLANG-VERSION=1.11
DOCKER-REPO=mexisme/jsonnet

.PHONY: all latest
all: alpine debian latest
latest: alpine
	$(DOCKER) tag $(DOCKER-REPO):$< $(DOCKER-REPO):$@

# alpine: GOLANG-TAG=$(GOLANG-VERSION)-$@
# debian: GOLANG-TAG=$(GOLANG-VERSION)
# alpine debian:
# 	$(DOCKER) build --tag=$(DOCKER-REPO):$@ --build-arg=PARENT_GOLANG=golang:$(GOLANG-TAG) --build-arg=PARENT=$@ .

.PHONY: alpine debian
alpine: alpine-build/Dockerfile
debian: debian-build/Dockerfile
alpine debian:
	$(DOCKER) build --tag=$(DOCKER-REPO):$@ --file $< .

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

.PHONY: update update-subrepo
update: update-subrepo alpine-build/Dockerfile debian-build/Dockerfile

# Note: You need to install https://github.com/ingydotnet/git-subrepo for this to work:
update-subrepo:
	git subrepo pull --all

# Note: You need to install https://github.com/ingydotnet/git-subrepo for this to work:
update:
	git subrepo pull --all

.PHONY: push
push: alpine debian latest
	for D in $^; do $(DOCKER) push $(DOCKER-REPO):$$D; done
