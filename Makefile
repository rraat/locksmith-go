VERSION=0.0.3
BUILD=$(shell git rev-parse --short HEAD)
MODULE=locksmith
BIN=bin
DIST=dist
export GOPATH=$(CURDIR)
export GOBIN=$(GOPATH)/$(BIN)

_TARGETS=\
	darwin-386 \
	darwin-amd64 \
	linux-386 \
	linux-amd64 \
	linux-arm \
	linux-arm64 \
	windows-386 \
	windows-amd64

	# android-386 \
	# android-amd64 \
	# android-arm \
	# android-arm64 \

TARGET_BINS=$(patsubst %,$(BIN)/$(MODULE)-%,$(_TARGETS))
TARGET_ZIPS=$(patsubst %,$(DIST)/$(MODULE)-%-$(VERSION).zip,$(_TARGETS))

default: $(TARGET_ZIPS)

depend:
	go get ./...

clean:
	rm -rf $(BIN) $(DIST)

$(DIST)/%-$(VERSION).zip: $(BIN)/%
	@mkdir -p $(@D)
	zip $@ $(BIN)/$(*F)

$(BIN)/$(MODULE)-%: $(MODULE)/*.go
	name="$(@F)"; \
	module=$${name%%-*}; \
	os_arch=$${name#*-}; \
	os=$${os_arch%%-*}; \
	arch=$${os_arch##*-}; \
	GOOS=$$os GOARCH=$$arch \
	go build \
		-ldflags "-X=main.Version=$(VERSION) -X=main.Build=$(BUILD)" \
		-o $@ ./$$module

.PHONY: default
.SECONDARY: $(TARGET_BINS)
