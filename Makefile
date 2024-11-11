export GO111MODULE=on
TOP_LEVEL=$(shell git rev-parse --show-toplevel)
COMMIT_HASH=$(shell git describe --always --tags --long)
RELEASE_TAG=$(shell git describe --tags --abbrev=0)
COMMIT ?= $(if $(shell git status --porcelain --untracked-files=no),$(COMMIT_HASH)-dirty,$(COMMIT_HASH))
OS ?= $(shell go env GOOS)
ARCH ?= $(shell go env GOARCH)
HOST_OS := $(shell go env GOOS)
HOST_ARCH := $(shell go env GOARCH)
OUTDIR ?= $(TOP_LEVEL)/bin

GO_VERSION=$(shell go version | awk '{print $$3}')
GO111MODULE_VALUE=auto
GO_BUILDTAGS ?=
ifneq ($(STATIC),)
	GO_BUILDTAGS += osusergo netgo static_build
endif
GO_TAGS=$(if $(GO_BUILDTAGS),-tags "$(strip $(GO_BUILDTAGS))",)

GO_LD_FLAGS=-ldflags '-X $(PKG)/version.Version=$(VERSION) -X $(PKG)/version.Revision=$(REVISION) $(GO_EXTRA_LDFLAGS)
ifeq ($(GODEBUG),)
    GO_LD_FLAGS += -s -w
endif
ifneq ($(STATIC),)
	GO_LD_FLAGS += -extldflags "-static"
endif
GO_LD_FLAGS+='

.PHONY: all build clean

all: build

build: atomfs-snapshotter-grpc


atomfs-snapshotter-grpc: 
	mkdir -p $(OUTDIR)
	GO111MODULE=$(GO111MODULE_VALUE) go build -o $(OUTDIR)/$@ $(GO_BUILD_FLAGS) $(GO_LD_FLAGS) $(GO_TAGS) ./cmd/atomfs-snapshotter-grpc

clean:
	rm -rf $(OUTDIR)
