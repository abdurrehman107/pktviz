package xdp
import "C"

/*  This file is ignored at build time, but `go generate` inside
    this directory will execute the bpf2go command below and
    produce:
       xdp_bpfel.go  xdp_bpfel.o  (little-endian object + bindings)
*/

//go:generate bpf2go -no-strip -cc clang -cflags "-O2 -g -I/usr/include/x86_64-linux-gnu" -target bpfel,bpfeb -go-package xdp xdp xdp_kern.c -- -I/usr/include/x86_64-linux-gnu
