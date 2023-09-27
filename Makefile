NAME	?= $(shell basename $(shell pwd))
ORG	?=

REPO	:= ${ORG}/${NAME}
ifeq (${ORG},)
REPO	:= ${NAME}
endif
# Use latest tag if VERSION is null
ifeq (${HASH},)
HASH := $(shell git rev-parse --short HEAD 2>/dev/null)
endif
ifeq (${VERSION},)
VERSION := ${HASH}
endif

TAG_BUILD	:= ${REPO}:${HASH}
TAG_RELEASE := ${REPO}:${VERSION}

all: build

generate_version:
	@echo "VERSION=${VERSION}" > VERSION
	@echo "HASH=${HASH}" >> VERSION
	@echo "BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" >> VERSION

build/codespace: generate_version
	docker build -t ${TAG_BUILD} --build-arg=REVISION=$(VERSION) -f Dockerfile.codespace .
	docker tag ${TAG_BUILD} ${TAG_RELEASE}

build/gitpod: generate_version
	docker build -t ${TAG_BUILD} --build-arg=REVISION=$(VERSION) -f Dockerfile.gitpod .
	docker tag ${TAG_BUILD} ${TAG_RELEASE}

push:
	docker push ${TAG_RELEASE}
