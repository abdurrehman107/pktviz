package xdp

import "github.com/cilium/ebpf"

// Objects is just an exported alias for xdpObjects.
type Objects = xdpObjects

// LoadObjects loads the compiled BPF programs and maps into the kernel,
// filling the given *Objects struct.
func LoadObjects(obj *Objects, opts *ebpf.CollectionOptions) error {
	return loadXdpObjects(obj, opts) // call the un-exported helper
}
