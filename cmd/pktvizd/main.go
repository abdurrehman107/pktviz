package main

import (
	"log"
	"time"

	"github.com/cilium/ebpf/link"
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
	// -------- load compiled object --------
	var objs xdp.Objects
	if err := xdp.LoadObjects(&objs, nil); err != nil {
		log.Fatalf("load objs: %v", err)
	}
	defer objs.Close()

	// -------- attach to eth0 (change if needed) --------
	lnk, err := link.AttachXDP(link.XDPOptions{
		Program:   objs.XdpCount,
		Interface: ifaceIndex("eth0"),
		Flags:     link.XDPGenericMode,
	})
	if err != nil {
		log.Fatalf("attach: %v", err)
	}
	defer lnk.Close()
	log.Println("XDP program attached to eth0")

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
