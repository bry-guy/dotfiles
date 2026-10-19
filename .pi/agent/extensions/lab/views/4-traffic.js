// Traffic: requests per hostname through the shared Caddy ingress over the selected window; the graph fills the width.
const sel = '{host!="_other"}';
// Gatus (pi-zero witness) checks these hosts once a minute; its own counters are subtracted so the view shows real use.
// shortcut: endpoint→host map mirrors selfhost/images/pi-zero-witness-fedora-bootc/config/gatus/config.yaml; update both together.
const GATUS = { "home-page": "home.bry-guy.net", "admin-grafana": "admin.bry-guy.net", "pi-ez-web": "pi.bry-guy.net" };
const gsel = `{name=~"${Object.keys(GATUS).join("|")}"}`;
module.exports = {
  title: "traffic",
  prom: (w) => ({
    total: { instant: `sum by (host) (increase(caddy_http_requests_total${sel}[${w.range}]))` },
    errs: { instant: `sum by (host) (increase(caddy_http_request_duration_seconds_count{host!="_other",code=~"5.."}[${w.range}]))` },
    p95: { instant: `histogram_quantile(0.95, sum by (host, le) (increase(caddy_http_request_duration_seconds_bucket${sel}[${w.range}])))` },
    gTotal: { instant: `sum by (name) (increase(gatus_results_total${gsel}[${w.range}]))` },
    gGraph: `sum by (name) (increase(gatus_results_total${gsel}[${w.stepRange}]))`,
    graph: `sum by (host) (increase(caddy_http_requests_total${sel}[${w.stepRange}]))`, // requests per bucket
  }),
  rows({ store, h, width, win }) {
    const by = (k) => Object.fromEntries((store.prom[k] || []).map((s) => [s.labels.host, s]));
    let total = by("total"), graph2; const errs = by("errs"), p95 = by("p95"),
      graph = by("graph");
    const minus = (k, into, vec) => { for (const g of store.prom[k] || []) { const s = into[GATUS[g.labels.name]]; if (!s) continue;
      if (vec) s.values = s.values.map((v, i) => Math.max(0, v - (g.values[i - s.values.length + g.values.length] || 0)));
      else s.last = Math.max(0, s.last - g.last); } };
    minus("gTotal", total = Object.fromEntries(Object.entries(total).map(([k, v]) => [k, { ...v }])), false);
    minus("gGraph", graph2 = Object.fromEntries(Object.entries(graph).map(([k, v]) => [k, { ...v }])), true);
    const fixed = [{ h: "HOST", w: 30 }, { h: `REQ ${win.k}*`, w: 9 }, { h: "5XX", w: 7 }, { h: "P95", w: 7 }];
    const gw = Math.max(10, width - fixed.reduce((a, c) => a + c.w + 1, 0) - 3);
    const fmt = (n) => (!Number.isFinite(n) ? "–" : n >= 1e6 ? `${h.num(n / 1e6)}M` : n >= 1e3 ? `${h.num(n / 1e3)}k` : h.num(n, 0));
    // Stretch or squeeze the series to exactly the graph width.
    const fit = (v) => (v?.length ? Array.from({ length: gw }, (_, i) => v[Math.floor((i * v.length) / gw)]) : []);
    const hosts = [...new Set([...Object.keys(total), ...Object.keys(graph)])].sort((a, b) => (total[b]?.last || 0) - (total[a]?.last || 0));
    const rows = hosts.map((host) => {
      const e = errs[host]?.last || 0, lat = p95[host]?.last;
      return { id: `ingress:${host}`, bad: e > 0, cells: [host, fmt(total[host]?.last), e > 0 ? h.fg("error", fmt(e)) : h.fg("dim", "0"),
        Number.isFinite(lat) ? (lat > 1 ? h.fg("warning", `${h.num(lat * 1000, 0)}ms`) : `${h.num(lat * 1000, 0)}ms`) : h.fg("dim", "–"),
        h.fg("accent", h.spark(fit(graph2[host]?.values), gw))] };
    });
    return { note: "excludes gatus checks", cols: [...fixed, { h: `REQUESTS / ${win.step >= 3600 ? `${win.step / 3600}h` : `${Math.round(win.step / 60)}m`} OVER ${win.k}`, w: gw }], rows, empty: "waiting for Prometheus…" }; // * = gatus checks excluded
  },
};
