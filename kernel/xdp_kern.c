// SPDX-License-Identifier: GPL-2.0
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

/* per-CPU global packet counter (key = 0) */
struct {
    __uint(type,        BPF_MAP_TYPE_PERCPU_ARRAY);
    __uint(max_entries, 1);
    __type(key,         __u32);
    __type(value,       __u64);
} pkt_cnt SEC(".maps");

/* XDP program: count + pass */
SEC("xdp")
int xdp_count(struct xdp_md *ctx)
{
    __u32 key = 0;
    __u64 *val = bpf_map_lookup_elem(&pkt_cnt, &key);
    if (val)
        __sync_fetch_and_add(val, 1);
    return XDP_PASS;
}

char LICENSE[] SEC("license") = "GPL";
