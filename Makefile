# --------------------------------------------
# pktviz – simple XDP packet counter
#
# $ make            # generate BPF + build pktvizd (default)
# $ sudo make run   # attach program, print packet counts
# $ make clean      # remove generated artefacts
# --------------------------------------------

# ——— config ——————————————————————————————————
GO          ?= go
CLANG       ?= clang
BPF2GO      ?= bpf2go
EXTRA_CFLAGS:= -I/usr/include/$(shell dpkg-architecture -qDEB_HOST_MULTIARCH)
PKG         := github.com/abdurrehman/pktviz
BPF_DIR     := kernel
BPF_IDENT   := xdp
BIN         := pktvizd
ARCH        := $(shell uname -m)   # x86_64 or aarch64

# Generated filenames (arch-agnostic after build)
OBJ_GO := $(BPF_DIR)/$(BPF_IDENT)_bpfel.go
OBJ_O  := $(BPF_DIR)/$(BPF_IDENT)_bpfel.o

# ——— targets ————————————————————————————
.PHONY: all build generate run clean help

all: build           ## = generate + build  (default)

generate: $(OBJ_GO)  ## Generate BPF objects for current arch

$(OBJ_GO): $(BPF_DIR)/$(BPF_IDENT)_kern.c
	@echo "[BPF2GO] generating $(ARCH) objects…"
	@cd $(BPF_DIR) && \
	GOPACKAGE=$(BPF_IDENT) \
	$(BPF2GO) -no-strip -no-btf -cc $(CLANG) \
		-cflags "-O2 -g $(EXTRA_CFLAGS)" \
		$(BPF_IDENT) $(BPF_IDENT)_kern.c -- $(EXTRA_CFLAGS)
	@echo "[OK] generated $(OBJ_GO) & .o"

build: generate      ## Build static pktvizd binary
	@echo "[BUILD] compiling $(BIN)…"
	CGO_ENABLED=0 $(GO) build -o $(BIN) ./cmd/$(BIN)
	@echo "[OK] => ./$(BIN)"

run: build           ## Run pktvizd and show packet counts
	@echo
	@echo "⇨ Ctrl-C to stop"
	@sudo ./$(BIN)

clean:               ## Remove generated artefacts
	@rm -f $(BIN) $(BPF_DIR)/*_bpfel.* $(BPF_DIR)/*_bpfeb.*
	@echo "[CLEAN] removed binary & generated BPF files"

help:                ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?##"}; {printf "  %-10s %s\n", $$1, $$2}'
