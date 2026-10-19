// Infrastructure tree: Proxmox host ▸ VM (k3s node when names match) ▸ pod ▸ container.
const { amounts, nodeUsage, res, USAGE, pct, gb, live, COLS, podNode } = require("./_shared.js");
module.exports = {
  title: "hosts",
  prom: USAGE,
  tree({ store, h }) {
    return {
      cols: COLS, empty: store.errors.pve ? "" : "waiting for Proxmox…",
      nodes: store.hosts.map((x) => {
        const vms = store.vms.filter((v) => v.host === x.name).sort((a, b) => a.vmid - b.vmid);
        return {
          id: `host:${x.name}`, bad: x.status !== "online",
          cells: [x.name, h.status(x.status === "online" ? "Ready" : x.status), `${vms.filter((v) => v.status === "running").length}/${vms.length}`,
            ...(() => {
              const g = nodeUsage(store, x.name), ne = g.mem != null;
              const u = ne ? { cpu: g.cpu, mem: g.mem } : { cpu: x.cpu * x.maxcpu, mem: x.mem }, mmax = g.memMax ?? x.maxmem;
              return [res(h, u.cpu, x.maxcpu), res(h, u.mem, mmax),
                h.fg("dim", `${amounts(h, u, x.maxcpu, mmax)} · ${ne ? `excl. cache + zfs arc ${(g.arc / 2 ** 30).toFixed(1)}Gi` : "proxmox (incl. cache)"} · up ${h.age(x.uptime * 1000)}`)];
            })()],
          children: () => vms.map((v) => {
            const node = store.nodes.find((n) => n.name === v.name), pods = live(store).filter((p) => p.node === v.name);
            return {
              id: `vm:${v.vmid}`, bad: v.status === "running" && !!node && !node.ready,
              cells: [`${v.name} (${v.vmid})`, h.status(v.status === "running" ? (node ? (node.ready ? "Ready" : "NotReady") : "Running") : v.status),
                node ? `${pods.filter((p) => p.ready).length}/${pods.length}` : "", ...(() => {
                  const g = nodeUsage(store, v.name), on = v.status === "running";
                  const u = g.mem != null ? { cpu: g.cpu, mem: g.mem } : { cpu: v.cpu * v.maxcpu, mem: v.mem }, mmax = g.memMax ?? v.maxmem;
                  return [on ? res(h, u.cpu, v.maxcpu) : "", on ? res(h, u.mem, mmax) : "",
                    h.fg("dim", `${amounts(h, u, v.maxcpu, mmax)} · ${g.mem != null ? "guest, excl. cache" : "proxmox"} · ${v.tags.replace(/;/g, " ")}`)];
                })()],
              children: node ? () => pods.sort((a, b) => a.ns.localeCompare(b.ns) || a.name.localeCompare(b.name)).map((p) => podNode(p, h, p.ns, store)) : undefined,
            };
          }),
        };
      }),
    };
  },
};
