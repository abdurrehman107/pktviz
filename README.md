
# pktviz — tiny eBPF XDP packet counter

**pktviz** is a packet counter that shows how to load an eBPF program using the **XDP hook** and count every packet that enters a Linux host. I aim at making it to be a counter which can be deployed as a daemonset on a cluster. This would allow us to monitor the traffic on every node in the cluster and potentially also tag packets with a little 
tweaking. 

## Features

* **Instant visibility** – see counters tick in real time.
* **Generic mode compatible** – works on any NIC/VM, no driver changes.

## 1 . Prerequisites

| Requirement | Tested version / package |
|-------------|--------------------------|
| Linux kernel | ≥ 5.4 (virtio-net OK) |
| Go | ≥ 1.20 (`sudo apt install golang-go`) |
| Tool-chain | `clang`, `llvm`, `libbpf-dev`, `bpftool`, `linux-headers-$(uname -r)` |
| Root access | needed for BPF syscalls & XDP attach |

## 2. Run the program
Install required packages. 

```bash
sudo apt-get update
sudo apt-get install -y \
    clang llvm libbpf-dev libelf-dev pkg-config build-essential \
    linux-libc-dev linux-headers-$(uname -r) \
    golang-go bpftool git
```

Clone the repository and when on the root build the Go program by: 
```bash 
go build cmd/pktvizd/main.go
```

Run the output file: 
```bash
./main
```
