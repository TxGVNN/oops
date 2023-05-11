NAME	?= $(shell basename $(shell pwd))
ORG	?=

REPO	:= ${ORG}/${NAME}
ifeq (${ORG},)
REPO	:= ${NAME}
endif
# Use latest tag if VERSION is null
ifeq (${HASH},)
HASH := latest
endif
ifeq (${VERSION},)
VERSION := ${HASH}
endif

TAG_BUILD	:= ${REPO}:${HASH}
TAG_RELEASE := ${REPO}:${VERSION}

all: build

build/codespace:
	docker build -t ${TAG_BUILD} --build-arg=VERSION=$(VERSION) -f Dockerfile.codespace .
	docker tag ${TAG_BUILD} ${TAG_RELEASE}

build/gitpod:
	docker build -t ${TAG_BUILD} --build-arg=VERSION=$(VERSION) -f Dockerfile.gitpod .
	docker tag ${TAG_BUILD} ${TAG_RELEASE}

push:
	docker push ${TAG_RELEASE}
