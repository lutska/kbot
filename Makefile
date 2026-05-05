include .env
export

PROJECT_ID ?=
REGION ?=
REPO ?=

APP := $(shell basename $(shell git remote get-url origin))


REGISTRY := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO)

VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)-$(shell git rev-parse --short HEAD)

TARGETOS := $(shell go env GOOS)
TARGETARCH := $(shell go env GOARCH)


format: 
	@echo "Formatting the code..."
	gofmt -s -w ./

lint: 
	golint

test: 
	@echo "Running tests..."
	go test -v

get: 
	@echo "Installing dependencies..."
	go get

build: format get
	@echo "Building the app..."
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
	go build -v -o kbot \
	-ldflags "-X="github.com/lutska/kbot/cmd.appVersion=${VERSION}

#GOARCH=${shell dpkg --print-architecture} 

check-env: 
	@test -n "$(PROJECT_ID)" || (echo "PROJECT_ID is not set"; exit 1)
	@test -n "$(REGION)" || (echo "REGION is not set"; exit 1)
	@test -n "$(REPO)" || (echo "REPO is not set"; exit 1)

image: check-env
	docker build . \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean: 
	rm -f kbot
	docker rmi $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) || true