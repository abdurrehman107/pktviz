
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

Sample output:
```bash
root@test-vm:~/pktviz# ./main 
2025/07/23 17:55:31 XDP program attached (generic) on eth0
2025/07/23 17:55:31 packets seen: 0
2025/07/23 17:55:33 packets seen: 3
2025/07/23 17:55:35 packets seen: 10
2025/07/23 17:55:37 packets seen: 16
2025/07/23 17:55:39 packets seen: 45
2025/07/23 17:55:41 packets seen: 51
2025/07/23 17:55:43 packets seen: 69
2025/07/23 17:55:45 packets seen: 74
2025/07/23 17:55:47 packets seen: 80
2025/07/23 17:55:49 packets seen: 85
```