
# pktviz — tiny eBPF XDP packet counter

**pktviz** is a packet counter that loads an eBPF program using the **XDP hook** and count every packet that enters a Linux host. This can be deployed as a daemonset on a cluster. It would allow us to monitor the traffic on every node in the cluster and potentially also tag packets with a little tweaking. 

## Features

* **Instant visibility** – see counters tick in real time.
* **Generic mode compatible** – works on any NIC/VM, no driver changes.

## Prerequisites

| Requirement | Tested version / package |
|-------------|--------------------------|
| Linux kernel | ≥ 5.4 (virtio-net OK) |
| Go | ≥ 1.20 (`sudo apt install golang-go`) |
| Tool-chain | `clang`, `llvm`, `libbpf-dev`, `bpftool`, `linux-headers-$(uname -r)` |
| Root access | needed for BPF syscalls & XDP attach |

## Run the program
Clone the repository and when on the root install dependencies and run by:

```bash
make all
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

## How it is working
We attach the eBPF program to the interface (eth0). 
```bash
lnk, err := link.AttachXDP(link.XDPOptions{
		Program:   objs.XdpCount,
		Interface: ifaceIndex("eth0"),
		Flags:     link.XDPGenericMode, // virtio-net → generic
	})
```

We then use the eBPF map to count the packets and display the count in our log. 
```bash
for {
		if err := objs.PktCnt.Lookup(&key, &pcpuVals); err != nil {
			log.Printf("lookup error: %v", err)
		} else {
			var total uint64
			for _, v := range pcpuVals {
				total += v
			}
			log.Printf("packets seen: %d", total)
		}
		time.Sleep(2 * time.Second)
	}
```