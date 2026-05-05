APP := $(shell basename $(shell git remote get-url origin))
REGISTRY=lutska
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=arm

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
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/lutska/kbot/cmd.appVersion=${VERSION}
#GOARCH=${shell dpkg --print-architecture} 
image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean: rm -f kbot