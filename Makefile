#   make setup   : apt-installs all build tools (run once, root)
#   make         : generate BPF + build pktvizd (default)
#   sudo make run: attach XDP, print packet counts
#   make clean   : remove generated artefacts
#   make help    : list targets

GO          ?= go
CLANG       ?= clang
BPF2GO      ?= bpf2go

# Fallback if dpkg-architecture absent (e.g., Alpine); uses empty path
ARCHPATH    := $(shell command -v dpkg-architecture >/dev/null \
                    && dpkg-architecture -qDEB_HOST_MULTIARCH)

EXTRA_CFLAGS:= $(if $(ARCHPATH),-I/usr/include/$(ARCHPATH),)

BPF_DIR     := kernel
BPF_IDENT   := xdp
OBJ_GO      := $(BPF_DIR)/$(BPF_IDENT)_bpfel.go
BIN         := pktvizd

.PHONY: all build generate run clean help

all: setup build run

setup:
	@echo "[SETUP] Installing build dependencies…"
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends \
	    golang-go clang llvm libbpf-dev libelf-dev pkg-config \
	    build-essential linux-libc-dev linux-headers-$(shell uname -r) \
	    bpftool git
	$(GO) install github.com/cilium/ebpf/cmd/bpf2go@latest
	@echo "[SETUP] Done."

generate: $(OBJ_GO)

$(OBJ_GO): $(BPF_DIR)/$(BPF_IDENT)_kern.c
	@echo "[BPF2GO] generating objects…"
	cd $(BPF_DIR) && \
	GOPACKAGE=$(BPF_IDENT) \
	$(BPF2GO) -no-strip -no-btf -cc $(CLANG) \
	    -cflags "-O2 -g $(EXTRA_CFLAGS)" \
	    $(BPF_IDENT) $(BPF_IDENT)_kern.c -- $(EXTRA_CFLAGS)
	@echo "[OK] generated $(OBJ_GO)"

build: generate
	@echo "[BUILD] compiling $(BIN)…"
	CGO_ENABLED=0 $(GO) build -o $(BIN) ./cmd/$(BIN)
	@echo "[OK] => ./$(BIN)"

run: build
	@echo "⇨ Ctrl-C to stop"
	sudo ./$(BIN)

clean:
	rm -f $(BIN) $(BPF_DIR)/*_bpfel.* $(BPF_DIR)/*_bpfeb.*
	@echo "[CLEAN] removed binary & generated BPF files"

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) \
	 | awk 'BEGIN {FS = ":.*?##"}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
