package main

import (
	"log"
	"time"

	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
	"github.com/vishvananda/netlink"

	xdp "github.com/abdurrehman/pktviz/kernel"
)

func ifaceIndex(name string) int {
	l, err := netlink.LinkByName(name)
	if err != nil {
		log.Fatalf("lookup iface: %v", err)
	}
	return int(l.Attrs().Index)
}

func main() {
	// Allow unlimited locked memory for this process
	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatalf("set rlimit memlock: %v", err)
	}

	// ---- load objects & attach XDP (generic) ----
	var objs xdp.Objects
	if err := xdp.LoadObjects(&objs, nil); err != nil {
		log.Fatalf("load objs: %v", err)
	}
	defer objs.Close()

	lnk, err := link.AttachXDP(link.XDPOptions{
		Program:   objs.XdpCount,
		Interface: ifaceIndex("eth0"),
		Flags:     link.XDPGenericMode,   // virtio-net → generic
	})
	if err != nil {
		log.Fatalf("attach: %v", err)
	}
	defer lnk.Close()
	log.Println("XDP program attached (generic) on eth0")

	// -------- poll counter --------
	key := uint32(0)
	for {
		var v uint64
		if err := objs.PktCnt.Lookup(&key, &v); err == nil {
			log.Printf("packets seen: %d\n", v)
		}
		time.Sleep(2 * time.Second)
	}
}
