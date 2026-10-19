// Logs: error/warning lines from app namespaces over the selected window, grouped by pod + message; expand a group for each occurrence.
const { short } = require("./_shared.js");
const NS = "pi-web|pi-workspaced|pi-sync|finances|castaway|homepage|acquisition|argocd";
module.exports = {
  title: "logs",
  loki: { errors: `{namespace=~"${NS}"} |~ "(?i)(error|panic|fatal|exception|warn)"` },
  tree({ store, h, win }) {
    const lines = store.logs.errors;
    const cols = [{ h: "PATTERN", w: 70 }, { h: "COUNT", w: 6 }, { h: "LAST", w: 9 }, { h: "NAMESPACE", w: 14 }, { h: "POD", w: 28 }];
    if (!lines) return { cols, nodes: [], empty: "waiting for Loki…" };
    if (!lines.length) return { cols, nodes: [], empty: `no errors or warnings in the last ${win.k}` };
    const groups = new Map();
    for (const l of lines) {
      const msg = l.line.replace(/\s+/g, " ").trim();
      const key = `${l.labels.namespace}|${short(l.labels.pod || "")}|${msg.replace(/\d{4}-\d\d-\d\dT[\d:.]+(Z|[+-]\d\d:\d\d)?|\b[0-9a-f]{7,}\b|\d+/g, "#")}`;
      const g = groups.get(key); if (g) g.items.push(l); else groups.set(key, { key, msg, l, items: [l] });
    }
    const t = (ts) => new Date(ts).toTimeString().slice(0, 8);
    const lvl = (s) => (/error|panic|fatal|exception/i.test(s) ? "error" : "warning");
    return {
      cols, empty: "",
      nodes: [...groups.values()].map((g) => ({
        id: `log:${g.key}`, bad: lvl(g.msg) === "error",
        cells: [h.fg(lvl(g.msg), g.msg), `×${g.items.length}`, t(g.l.ts), g.l.labels.namespace, short(g.l.labels.pod || g.l.labels.app || "")],
        children: () => g.items.slice(0, 50).map((l, i) => ({ id: `log:${g.key}#${i}`, cells: [l.line.replace(/\s+/g, " ").trim(), "", t(l.ts), "", l.labels.pod || ""] })),
      })),
    };
  },
};
