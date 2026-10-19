// Helpers shared by the views (files starting with _ are not views).
const short = (pod) => pod.replace(/-[a-z0-9]{8,10}-[a-z0-9]{5}$|-[a-z0-9]{5}$/, "");
const pct = (h, used, max) => (max ? `${h.bar((100 * used) / max, 8)} ${h.pad(h.num((100 * used) / max, 0) + "%", 4)}` : "");
const gb = (b) => (b / 2 ** 30).toFixed(b >= 10 * 2 ** 30 ? 0 : 1);
const live = (store) => store.pods.filter((p) => p.phase !== "Succeeded");
const yes = (h, ok) => (ok ? h.fg("success", "yes") : h.fg("warning", "no"));
// Shared tree columns so every depth lines up: NAME STATUS READY CPU MEM INFO
const COLS = [{ h: "NAME", w: 50 }, { h: "STATUS", w: 13 }, { h: "READY", w: 7 }, { h: "CPU", w: 13 }, { h: "MEM", w: 13 }, { h: "INFO", w: 70 }];
// Live pod/container usage from cAdvisor; views that show pods declare USAGE as their prom queries.
const NE = (q) => `${q} * on (instance) group_left (nodename) max by (instance, nodename) (node_uname_info)`;
const USAGE = {
  // Guest view of each k3s VM: "used" = MemTotal - MemAvailable (excludes reclaimable page cache).
  vmMemUsed: { instant: `sum by (nodename) (${NE("(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes)")})` },
  vmMemTotal: { instant: `sum by (nodename) (${NE("node_memory_MemTotal_bytes")})` },
  arc: { instant: `sum by (nodename) (${NE("node_zfs_arc_size")})` }, // Proxmox hosts: reclaimable, so not "used"
  vmCpu: { instant: `sum by (nodename) (${NE('rate(node_cpu_seconds_total{mode!~"idle|iowait|steal"}[2m])')})` },
  ctrCpu: { instant: 'sum by (namespace, pod, container) (rate(container_cpu_usage_seconds_total{container!=""}[2m]))' },
  ctrMem: { instant: 'sum by (namespace, pod, container) (container_memory_working_set_bytes{container!=""})' },
};
const fmtCpu = (c) => (c >= 1 ? `${c.toFixed(c >= 10 ? 0 : 1)}c` : `${Math.round(c * 1000)}m`);
const fmtMem = (b) => (b >= 2 ** 30 ? `${(b / 2 ** 30).toFixed(1)}Gi` : `${Math.round(b / 2 ** 20)}Mi`);
// "% of what it may use": its limit when set; otherwise the node's capacity, marked "n" (no limit, can grow to the node).
const kq = (q) => { if (q == null) return undefined; const m = /^([\d.]+)(m|Ki|Mi|Gi|Ti|k|M|G)?$/.exec(String(q)); if (!m) return undefined;
  return parseFloat(m[1]) * ({ m: 1e-3, Ki: 2 ** 10, Mi: 2 ** 20, Gi: 2 ** 30, Ti: 2 ** 40, k: 1e3, M: 1e6, G: 1e9 }[m[2]] ?? 1); };
const nodeCap = (store, node, k) => kq(store.nodes.find((n) => n.name === node)?.[k]);
const res = (h, used, limit, cap) => {
  const max = limit || cap; if (used == null || !max) return "";
  const p = (100 * used) / max;
  return `${h.bar(p, 6)} ${h.pad(`${p >= 0.05 && p < 1 ? p.toFixed(1) : Math.round(p)}%`, 5)}`;
};
// VM usage from inside the guest (node-exporter), keyed by node name.
const nodeUsage = (store, name) => {
  const g = (k) => (store.prom[k] || []).find((s) => s.labels.nodename === name)?.last;
  const m = g("vmMemUsed");
  return { cpu: g("vmCpu"), mem: m == null ? undefined : Math.max(0, m - (g("arc") || 0)), memMax: g("vmMemTotal"), arc: g("arc") };
};
function usage(store, p, container) {
  const pick = (k) => (store.prom[k] || []).filter((s) => s.labels.namespace === p.ns && s.labels.pod === p.name && (!container || s.labels.container === container));
  const sum = (xs) => (xs.length ? xs.reduce((a, s) => a + (s.last || 0), 0) : undefined);
  return { cpu: sum(pick("ctrCpu")), mem: sum(pick("ctrMem")) };
}
const lim = (cs, k) => (cs.length && cs.every((c) => c[k]) ? cs.reduce((a, c) => a + c[k], 0) : undefined);
// Fixed-width "used/allowed" so cpu and mem line up row to row; allowed is the limit or the node ("node").
const amounts = (h, u, cpuMax, memMax) =>
  `cpu ${h.pad(`${fmtCpu(u.cpu ?? 0)}/${cpuMax ? fmtCpu(cpuMax) : "node"}`, 11)} mem ${h.pad(`${fmtMem(u.mem ?? 0)}/${memMax ? fmtMem(memMax) : "node"}`, 14)}`;
const limits = (c) => [c.cpuReq && `req ${fmtCpu(c.cpuReq)}/${fmtMem(c.memReq || 0)}`, c.cpuLimit || c.memLimit ? `lim ${c.cpuLimit ? fmtCpu(c.cpuLimit) : "–"}/${c.memLimit ? fmtMem(c.memLimit) : "–"}` : "no limits"].filter(Boolean).join(" ");
const containerNodes = (p, h, store) => (p.containers ?? []).map((c) => ({
  id: `ctr:${p.ns}/${p.name}/${c.name}`, bad: !c.ready && !c.init,
  cells: (() => { const u = usage(store, p, c.name); return [c.init ? `${c.name} (init)` : c.name, h.status(c.state), yes(h, c.ready),
    res(h, u.cpu, c.cpuLimit, nodeCap(store, p.node, "cpu")), res(h, u.mem, c.memLimit, nodeCap(store, p.node, "mem")),
    h.fg("dim", `${amounts(h, u, c.cpuLimit, c.memLimit)} · ${limits(c)} · ${c.restarts ? `↻${c.restarts} · ` : ""}${c.image.replace(/^.*\//, "")}`)]; })(),
}));
const podNode = (p, h, info, store) => {
  const u = usage(store, p), cs = p.containers.filter((c) => !c.init), cl = lim(cs, "cpuLimit"), ml = lim(cs, "memLimit");
  return {
  id: `pod:${p.ns}/${p.name}`, bad: !p.ready,
  cells: [p.name, h.status(p.status), yes(h, p.ready), res(h, u.cpu, cl, nodeCap(store, p.node, "cpu")), res(h, u.mem, ml, nodeCap(store, p.node, "mem")),
    h.fg("dim", `${amounts(h, u, cl, ml)} · ${info} · ${p.restarts ? `↻${p.restarts} · ` : ""}${h.age(p.ageMs)}`)],
  children: () => containerNodes(p, h, store),
  };
};
module.exports = { amounts, nodeUsage, USAGE, usage, fmtCpu, fmtMem, res, short, pct, gb, live, yes, COLS, podNode };
