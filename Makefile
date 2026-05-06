include .env
export

PROJECT_ID ?=
REGION ?=
REPO ?=

APP := $(shell basename -s .git $(shell git remote get-url origin))


REGISTRY := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO)

VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)-$(shell git rev-parse --short HEAD)

# define id run without arguments 
TARGETOS := $(shell go env GOOS)
TARGETARCH := $(shell go env GOARCH)
#TARGETARCH=${shell dpkg --print-architecture} 

.PHONY: format lint test get build linux windows macos arm image push clean check-env help


# Help

help:
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "  make build       Build binary for local platform"
	@echo "  make linux       Build binary for Linux (amd64)"
	@echo "  make windows     Build binary for Windows (amd64)"
	@echo "  make macos       Build binary for macOS (arm64)"
	@echo "  make arm         Build binary for Linux ARM64"
	@echo ""
	@echo "  make image       Build Docker image (Linux runtime)"
	@echo "  make push        Push image to GCP Artifact Registry"
	@echo "  make clean       Clean build artifacts"
	@echo ""

# Code format

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


# Default Build

build: format get
	@echo "Building for $(TARGETOS)/$(TARGETARCH)"
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
	go build -v -o kbot \
	-ldflags "-X github.com/lutska/kbot/cmd.appVersion=$(VERSION)"


# Cross-platform builds 

linux:
	@echo "Building for Linux..."
	$(MAKE) build TARGETOS=linux TARGETARCH=amd64

windows:
	@echo "Building for Windows..."
	$(MAKE) build TARGETOS=windows TARGETARCH=amd64

macos:
	@echo "Building for macOS..."
	$(MAKE) build TARGETOS=darwin TARGETARCH=arm64

arm:
	@echo "Building for ARM Linux..."
	$(MAKE) build TARGETOS=linux TARGETARCH=arm64


check-env: 
	@test -n "$(PROJECT_ID)" || (echo "PROJECT_ID is not set"; exit 1)
	@test -n "$(REGION)" || (echo "REGION is not set"; exit 1)
	@test -n "$(REPO)" || (echo "REPO is not set"; exit 1)

image: check-env
	@echo "Building docker image - Linux runtime, binary for platform $(TARGETOS)/$(TARGETARCH)"
	docker build . \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

push:
	@echo "Push docker image - Linux runtime, binary for platform $(TARGETOS)/$(TARGETARCH)"
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean: 
	rm -f kbot kbot-* *.exe
	docker rmi $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) || true