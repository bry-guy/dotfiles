# lab — live homelab dashboard for pi

`/lab` opens a live panel above the editor; keep prompting pi while it runs.
`/lab next` · `/lab prev` · `/lab <view>` (tab-completes) · `/lab height 40` · `/lab off`

Driving: `ctrl+shift+l` (or `/lab focus`, or click a row) gives the dashboard the keyboard and the screen; only `ctrl+shift+l` hands it back (`esc` just clears a filter or pending key) to the prompt and the widget stays above it.

| keys | |
|---|---|
| `j`/`k` (counts: `5j`), `ctrl-d`/`ctrl-u`, `gg`/`G` | move the row cursor |
| `enter` / `-` | expand / collapse the row (`-` on a child collapses its parent) |
| `h`/`l` | column cursor (scrolls wide tables sideways) |
| `/` | filter this level (`enter` keeps it, `esc` clears) |
| `tab` / `shift-tab` | next/prev view, carrying the selected object (a pod in `hosts` lands on the same pod in `apps`) |
| `w` / `W` | time window 1h → 1d → 1w → 1m (traffic and logs; click it in the header too) |
| `r` | refresh queries |

Mouse (pi fullscreen mode): click a row to select, click it again (or double-click) to expand/collapse, click a breadcrumb to jump to that ancestor, click a tab to switch, wheel to move.

Trees: `hosts` = Proxmox host › VM (k3s node when names match) › pod › container; `apps` = Argo app › workload › pod › container. Proxmox data uses the read-only token from infra `mise run selfhost:proxmox:lab-token:apply` (1Password `bry-guy/LAB_PROXMOX_TOKEN`; override with `LAB_PVE_URL` / `LAB_PVE_TOKEN_REF`).

Views: **deploys** (Argo apps × pods × latest CI) · **topology** (node → namespace → pods, CPU/mem bars + 30m sparklines)
· **ci** (Actions runs) · **traffic** (Caddy req/s, 5xx, p95 per host) · **logs** (Loki errors/warnings, repeats grouped).

## Adding a view (what to ask pi)
"Add a /lab view that shows …". pi should check data with the `lab_snapshot` tool (it can also test a
PromQL/LogQL query), then write `views/<n>-<name>.js`. Saved views reload within a second; a broken
view shows its error in the panel instead of breaking pi.

```js
module.exports = {
  title: "name",
  prom: { key: "PromQL" },   // optional: polled every 15s over the last 30m while this view is visible
  loki: { key: "LogQL" },    // optional: polled every 3s over the last 15m while this view is visible
  render({ store, width, h, theme }) { return ["line", ...]; }, // lines are truncated to width
};
```

- `store.nodes`, `store.pods` (with `argoApp`, `status`, `restarts`), `store.deployments` (with `argoApp`, `rolling`),
  `store.apps` (Argo: `sync`, `health`, `revision`, `repo`), `store.runs` (gh Actions),
  `store.prom[key]` = `[{ labels, values[], last }]`, `store.logs[key]` = `[{ ts, line, labels }]` (newest first), `store.errors`.
- `h`: `table(cols, rows)`, `pad(s,w)`, `status(s)` (colors by state), `bar(pct,w)`, `spark(values,w,max?)`, `num(x,digits)`,
  `age(ms)`, `fg(color,s)`, `bold(s)`. Colors: `accent success warning error muted dim text`.
- Views are CommonJS and may `require` node built-ins. `render` runs on every change and once a second: keep it pure and fast.

## Data sources (index.ts)
- Cluster: `kubectl get <kind> -A --watch` streams for nodes, pods, deployments, statefulsets, daemonsets, Argo applications (auto-resumes).
- Prometheus and Loki in `observability`, reached through the Kubernetes API proxy (no port-forward).
  Use kubelet/cAdvisor + kube-state-metrics for node/pod usage: node-exporter is only scraped on worker-0.
- GitHub: `gh run list` for every `bry-guy/*` repo Argo deploys; every 5s while a run is in progress, else 20s.
- `LAB_KUBECONFIG` overrides the kubeconfig (default `~/.kube/selfhost-platform-7049-1.yaml`).

Check: `node test.mjs` (parser/helper tests) or `node test.mjs deploys logs` (renders views on live data).
