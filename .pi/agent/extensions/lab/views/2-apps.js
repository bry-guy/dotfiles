// Delivery tree: Argo app ▸ workload ▸ pod ▸ container.
const { USAGE, live, COLS, podNode } = require("./_shared.js");
module.exports = {
  title: "apps",
  prom: USAGE,
  tree({ store, h }) {
    return {
      cols: COLS,
      nodes: store.apps.map((a) => {
        const pods = live(store).filter((p) => p.argoApp === a.name), ready = pods.filter((p) => p.ready).length;
        const run = store.runs.find((r) => r.repo === a.repo && /publish|^ci$/i.test(r.workflow));
        const health = store.deployments.some((d) => d.argoApp === a.name && d.rolling) ? "Progressing" : a.health;
        const groups = new Map();
        for (const p of pods) { const k = `${p.ns}/${p.workload}`; groups.set(k, [...(groups.get(k) ?? []), p]); }
        for (const d of store.deployments.filter((d) => d.argoApp === a.name)) if (!groups.has(`${d.ns}/${d.name}`)) groups.set(`${d.ns}/${d.name}`, []);
        const ci = run ? ` · ci ${run.status === "completed" ? run.conclusion : run.status} ${run.sha} ${h.age(run.ageMs)}` : "";
        return {
          id: `app:${a.name}`, bad: health !== "Healthy" || a.sync !== "Synced",
          cells: [a.name, h.status(health), `${ready}/${pods.length}`, "", "", `${h.status(a.sync)} ${h.fg("dim", `${a.revision} · ${a.repo.replace(/^bry-guy\//, "").replace(/^https?:\/\/([^/]+).*/, "$1")} · synced ${h.age(a.deployedAgoMs)}${ci}`)}`],
          children: () => [...groups].sort().map(([k, ps]) => {
            const d = store.deployments.find((d) => `${d.ns}/${d.name}` === k), r = ps.filter((p) => p.ready).length, want = d?.desired ?? ps.length;
            return {
              id: `wl:${k}`, bad: r < want,
              cells: [k.split("/")[1], h.status(r < want ? "Progressing" : "Ready"), `${r}/${want}`, "", "", h.fg("dim", `${k.split("/")[0]} · ${(d?.image ?? ps[0]?.image ?? "").replace(/^.*\//, "")}`)],
              children: () => ps.sort((x, y) => x.name.localeCompare(y.name)).map((p) => podNode(p, h, p.node, store)),
            };
          }),
        };
      }).sort((x, y) => Number(y.bad) - Number(x.bad)),
    };
  },
};
