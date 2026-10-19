/**
 * /lab — live homelab dashboard widget above the editor.
 * Cluster state streams from `kubectl get --watch`; metrics/logs come from Prometheus/Loki queries
 * that views declare themselves; CI runs come from gh. Views (views/*.js) hot-reload on save.
 */
import { type ChildProcess, execFile, spawn } from "node:child_process";
import { mkdtempSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { Type } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const VIEWS_DIR = join(homedir(), ".pi/agent/extensions/lab/views");
const KUBECONFIG = process.env.LAB_KUBECONFIG ?? join(homedir(), ".kube/selfhost-platform-7049-1.yaml");
const PROM = "/api/v1/namespaces/observability/services/kube-prometheus-stack-prometheus:9090/proxy/metrics";
const LOKI = "/api/v1/namespaces/observability/services/loki:3100/proxy";
const KINDS = ["nodes", "pods", "deployments", "statefulsets", "daemonsets", "applications.argoproj.io"];
// Read-only Proxmox token (PVEAuditor), created by infra `mise run selfhost:proxmox:lab-token:apply`.
const PVE_URL = (process.env.LAB_PVE_URL ?? "https://brain-7049-pve-sffpc.tail9e13b.ts.net:8006").replace(/\/$/, "");
const PVE_TOKEN_REF = process.env.LAB_PVE_TOKEN_REF ?? "op://bry-guy/LAB_PROXMOX_TOKEN/password";
const PVE_MS = 10000, PROM_MS = 15000, LOKI_MS = 3000, GH_IDLE_MS = 20000, GH_BUSY_MS = 5000;

type Store = Record<string, any>;
const store: Store = { hosts: [], vms: [], nodes: [], pods: [], deployments: [], apps: [], runs: [], prom: {}, logs: {}, errors: {}, live: false, updatedAt: 0 };
const raw = new Map<string, Map<string, any>>(KINDS.map((k) => [k, new Map()]));
const env = { ...process.env, KUBECONFIG };

function run(cmd: string, args: string[]): Promise<string> {
	return new Promise((resolve, reject) =>
		execFile(cmd, args, { env, maxBuffer: 64 << 20, timeout: 20000 }, (err, out, errOut) =>
			err ? reject(new Error((errOut || err.message).trim().split("\n")[0])) : resolve(out)));
}
async function guard(key: string, fn: () => Promise<void>) {
	try { await fn(); delete store.errors[key]; } catch (e: any) { store.errors[key] = e.message; }
}
const age = (t?: string) => (t ? Date.now() - Date.parse(t) : 0);

/** Splits a stream of concatenated JSON documents (kubectl -w -o json) into objects. */
export function jsonStream(onDoc: (doc: any) => void) {
	let buf = "", depth = 0, inStr = false, esc = false, start = -1;
	return (chunk: string) => {
		const base = buf.length; buf += chunk;
		for (let i = base; i < buf.length; i++) {
			const c = buf[i];
			if (inStr) { if (esc) esc = false; else if (c === "\\") esc = true; else if (c === '"') inStr = false; continue; }
			if (c === '"') inStr = true;
			else if (c === "{") { if (depth++ === 0) start = i; }
			else if (c === "}" && --depth === 0) { onDoc(JSON.parse(buf.slice(start, i + 1))); buf = buf.slice(i + 1); i = -1; start = -1; }
		}
		if (depth === 0 && !inStr) buf = "";
	};
}

// ---- streaming cluster state ----
let watchers: ChildProcess[] = [], watching = false, onChange = () => {};
function watchKind(kind: string) {
	if (!watching) return;
	const objs = raw.get(kind)!;
	const p = spawn("kubectl", ["get", kind, "-A", "--watch", "--output-watch-events", "-o", "json"], { env });
	watchers.push(p);
	let fresh = true;
	p.stdout.setEncoding("utf8").on("data", jsonStream((ev) => {
		if (fresh) { objs.clear(); fresh = false; } // a (re)started watch replays the full list as ADDED
		const o = ev.object, key = `${o.metadata.namespace ?? ""}/${o.metadata.name}`;
		if (ev.type === "DELETED") objs.delete(key); else if (ev.type !== "ERROR" && ev.type !== "BOOKMARK") objs.set(key, o);
		delete store.errors[kind]; scheduleDerive();
	}));
	let errText = "";
	p.stderr.setEncoding("utf8").on("data", (d) => (errText = String(d).trim().split("\n")[0]));
	p.on("exit", () => {
		watchers = watchers.filter((w) => w !== p);
		if (!watching) return;
		if (errText) store.errors[kind] = errText;
		setTimeout(() => watchKind(kind), 2000); // watches expire server-side; resume
	});
}
let deriveTimer: ReturnType<typeof setTimeout> | undefined;
function scheduleDerive() { if (!deriveTimer) deriveTimer = setTimeout(() => { deriveTimer = undefined; derive(); store.updatedAt = Date.now(); onChange(); }, 100); }

// Kubernetes quantities ("500m", "1Gi", "2") to cores / bytes; undefined when unset.
const cores = (q?: string) => (q == null ? undefined : q.endsWith("m") ? parseFloat(q) / 1000 : parseFloat(q));
const UNITS: Record<string, number> = { Ki: 2 ** 10, Mi: 2 ** 20, Gi: 2 ** 30, Ti: 2 ** 40, k: 1e3, M: 1e6, G: 1e9, T: 1e12 };
const bytes = (q?: string) => { if (q == null) return undefined; const m = /^([\d.]+)([A-Za-z]*)$/.exec(q); return m ? parseFloat(m[1]) * (UNITS[m[2]] ?? 1) : undefined; };

function derive() {
	const list = (k: string) => [...raw.get(k)!.values()];
	// Argo labels the workloads it owns (app.kubernetes.io/instance), not their pods; map pods to apps via their owner.
	const ownerApp = new Map<string, string>();
	for (const w of [...list("deployments"), ...list("statefulsets"), ...list("daemonsets")]) {
		const app = w.metadata.labels?.["app.kubernetes.io/instance"];
		if (app) ownerApp.set(`${w.metadata.namespace}/${w.metadata.name}`, app);
	}
	store.nodes = list("nodes").map((n) => ({
		name: n.metadata.name,
		ready: n.status.conditions?.find((c: any) => c.type === "Ready")?.status === "True",
		roles: Object.keys(n.metadata.labels ?? {}).filter((l) => l.startsWith("node-role.kubernetes.io/")).map((l) => l.split("/")[1]),
		cpu: n.status.capacity?.cpu, mem: n.status.capacity?.memory,
	})).sort((a, b) => a.name.localeCompare(b.name));
	store.pods = list("pods").map((p) => {
		const cs = p.status.containerStatuses ?? [];
		const waiting = cs.map((c: any) => c.state?.waiting?.reason ?? c.state?.terminated?.reason).find(Boolean);
		const owner = p.metadata.ownerReferences?.[0]?.name ?? "";
		const spec = new Map([...(p.spec.initContainers ?? []), ...(p.spec.containers ?? [])].map((c: any) => [c.name, c.resources ?? {}]));
		const st = (c: any) => ({ name: c.name, image: c.image, ready: !!c.ready, restarts: c.restartCount ?? 0,
			cpuLimit: cores(spec.get(c.name)?.limits?.cpu), memLimit: bytes(spec.get(c.name)?.limits?.memory),
			cpuReq: cores(spec.get(c.name)?.requests?.cpu), memReq: bytes(spec.get(c.name)?.requests?.memory),
			state: c.state?.waiting?.reason ?? c.state?.terminated?.reason ?? (c.state?.running ? "Running" : "?") });
		const containers = [...(p.status.initContainerStatuses ?? []).map((c: any) => ({ ...st(c), init: true })), ...cs.map(st)];
		return {
			ns: p.metadata.namespace, name: p.metadata.name, node: p.spec.nodeName ?? "", phase: p.status.phase,
			status: p.metadata.deletionTimestamp ? "Terminating" : waiting ?? p.status.phase,
			ready: cs.length > 0 && cs.every((c: any) => c.ready), restarts: cs.reduce((a: number, c: any) => a + (c.restartCount ?? 0), 0),
			ageMs: age(p.status.startTime), owner, containers,
			workload: p.metadata.ownerReferences?.[0]?.kind === "ReplicaSet" ? owner.replace(/-[a-z0-9]{6,10}$/, "") : owner,
			argoApp: ownerApp.get(`${p.metadata.namespace}/${owner}`) ?? ownerApp.get(`${p.metadata.namespace}/${owner.replace(/-[a-z0-9]{8,10}$/, "")}`) ?? "",
			app: p.metadata.labels?.["app.kubernetes.io/name"] ?? p.metadata.labels?.app ?? "",
			image: p.spec.containers?.[0]?.image ?? "",
		};
	});
	store.deployments = list("deployments").map((d) => ({
		ns: d.metadata.namespace, name: d.metadata.name, argoApp: d.metadata.labels?.["app.kubernetes.io/instance"] ?? "",
		desired: d.spec.replicas ?? 0, ready: d.status.readyReplicas ?? 0, updated: d.status.updatedReplicas ?? 0,
		rolling: (d.status.updatedReplicas ?? 0) < (d.spec.replicas ?? 0) || (d.status.replicas ?? 0) > (d.spec.replicas ?? 0),
		image: d.spec.template.spec.containers?.[0]?.image ?? "",
	}));
	store.apps = list("applications.argoproj.io").map((a) => ({
		name: a.metadata.name, repo: (a.spec.source?.repoURL ?? "").replace(/^.*github\.com[:/]/, "").replace(/\.git$/, ""),
		path: a.spec.source?.path ?? "", ns: a.spec.destination?.namespace ?? "",
		sync: a.status?.sync?.status ?? "?", health: a.status?.health?.status ?? "?",
		revision: (a.status?.sync?.revision ?? "").slice(0, 7), operation: a.status?.operationState?.phase ?? "",
		deployedAgoMs: age(a.status?.history?.at(-1)?.deployedAt),
	}));
	store.live = KINDS.every((k) => raw.get(k)!.size > 0 || k === "statefulsets" || k === "daemonsets");
}

// ---- queries declared by views: { prom: { key: promql }, loki: { key: logql } } ----
// Time window shared by every view: `w` cycles it. `range` is PromQL/LogQL duration syntax; `step` is one graph bucket.
export const WINDOWS = [{ k: "1h", s: 3600, range: "1h" }, { k: "1d", s: 86400, range: "1d" }, { k: "1w", s: 604800, range: "7d" }, { k: "1m", s: 2592000, range: "30d" }];
let winIdx = 0;
export const win = () => { const w = WINDOWS[winIdx]; const step = Math.max(120, Math.floor(w.s / 240)); return { ...w, step, stepRange: `${step}s` }; }; // ≥2 scrapes per bucket, or increase() is empty
type Queries = Record<string, string | { instant: string }> | ((w: ReturnType<typeof win>) => Record<string, string | { instant: string }>);
const resolve = (q: Queries) => (typeof q === "function" ? q(win()) : q);
async function pollProm(queries0: Queries) {
	const queries = resolve(queries0), w = win();
	const end = Math.floor(Date.now() / 1000), start = end - w.s;
	await Promise.all(Object.entries(queries).map(([key, q]) => guard(`prom:${key}`, async () => {
		if (typeof q !== "string") { // instant: one value per series, e.g. a total over the whole window
			const res = JSON.parse(await run("kubectl", ["get", "--raw", `${PROM}/api/v1/query?${new URLSearchParams({ query: q.instant, time: String(end) })}`]));
			if (res.status !== "success") throw new Error(res.error ?? "query failed");
			store.prom[key] = res.data.result.map((r: any) => ({ labels: r.metric, values: [Number(r.value[1])], last: Number(r.value[1]) }));
			return;
		}
		const qs = new URLSearchParams({ query: q, start: String(start), end: String(end), step: String(w.step) });
		const res = JSON.parse(await run("kubectl", ["get", "--raw", `${PROM}/api/v1/query_range?${qs}`]));
		if (res.status !== "success") throw new Error(res.error ?? "query failed");
		store.prom[key] = res.data.result.map((r: any) => ({ labels: r.metric, values: r.values.map((v: any) => Number(v[1])), last: Number(r.values.at(-1)?.[1]) }));
	})));
}
async function pollLoki(queries0: Queries) {
	const queries = resolve(queries0) as Record<string, string>, w = win();
	const end = Date.now() * 1e6, start = end - w.s * 1e9;
	await Promise.all(Object.entries(queries).map(([key, q]) => guard(`loki:${key}`, async () => {
		const qs = new URLSearchParams({ query: q, start: String(start), end: String(end), limit: "1000", direction: "backward" });
		const res = JSON.parse(await run("kubectl", ["get", "--raw", `${LOKI}/loki/api/v1/query_range?${qs}`]));
		store.logs[key] = res.data.result.flatMap((s: any) => s.values.map(([ts, line]: [string, string]) => ({ ts: Number(ts) / 1e6, line, labels: s.stream })))
			.sort((a: any, b: any) => b.ts - a.ts);
	})));
}
async function pollGh() {
	for (let i = 0; i < 50 && !store.apps.length; i++) await new Promise((r) => setTimeout(r, 200)); // repos come from Argo apps
	await guard("gh", async () => {
		const repos = [...new Set(store.apps.map((a: any) => a.repo).filter((r: string) => r.startsWith("bry-guy/")))] as string[];
		const lists = await Promise.all(repos.map(async (repo) =>
			JSON.parse(await run("gh", ["run", "list", "-R", repo, "-L", "5", "--json", "databaseId,workflowName,status,conclusion,headSha,displayTitle,event,createdAt,headBranch"]))
				.map((r: any) => ({ repo, id: r.databaseId, workflow: r.workflowName, status: r.status, conclusion: r.conclusion ?? "", sha: r.headSha.slice(0, 7), title: r.displayTitle, branch: r.headBranch, event: r.event, ageMs: age(r.createdAt) }))));
		store.runs = lists.flat().sort((a, b) => a.ageMs - b.ageMs);
	});
}

let pveHeader: string | undefined; // curl -H @file, so the token never sits in process arguments
async function pollPve() {
	await guard("pve", async () => {
		if (!pveHeader) {
			const token = (await run("op", ["read", "--no-newline", PVE_TOKEN_REF])).trim();
			const dir = mkdtempSync(join(tmpdir(), "lab-pve-")); pveHeader = join(dir, "h");
			writeFileSync(pveHeader, `Authorization: PVEAPIToken=${token}\n`, { mode: 0o600 });
		}
		const res = JSON.parse(await run("curl", ["-sk", "--max-time", "8", "-H", `@${pveHeader}`, `${PVE_URL}/api2/json/cluster/resources`])).data;
		if (!Array.isArray(res)) throw new Error("Proxmox returned no data (token?)");
		store.hosts = res.filter((r: any) => r.type === "node").map((r: any) => ({ name: r.node, status: r.status, cpu: r.cpu ?? 0, maxcpu: r.maxcpu ?? 0, mem: r.mem ?? 0, maxmem: r.maxmem ?? 0, uptime: r.uptime ?? 0 }))
			.sort((a: any, b: any) => a.name.localeCompare(b.name));
		store.vms = res.filter((r: any) => r.type === "qemu" || r.type === "lxc").map((r: any) => ({ vmid: r.vmid, name: r.name, host: r.node, status: r.status, cpu: r.cpu ?? 0,
			maxcpu: r.maxcpu ?? 0, mem: r.mem ?? 0, maxmem: r.maxmem ?? 0, tags: r.tags ?? "", template: !!r.template })).filter((v: any) => !v.template);
	});
}

// ---- views (CommonJS), hot-reloaded by mtime. module.exports = { title, prom?, loki?, and one of:
//   tree({ store, h, width, win }) -> { cols, nodes: [{ id, cells, bad?, children?: () => nodes }], empty? }  (expand/collapse)
//   rows({ store, h, width, win }) -> { cols: [{h, w}], rows: [{ id, cells, bad? }], empty? }                  (flat list)
//   render({ store, h, width, theme, win }) -> string[]                                                       (scroll only)
//   prom/loki: { key: query } or (win) => { key: query }; a prom value { instant: q } runs once at "now".
//   Object ids (pod:ns/name, vm:310, …) are shared across trees, so tab keeps the selection.
// Files starting with "_" are shared modules, not views.
type View = { name: string; title: string; prom?: Queries; loki?: Queries; render?: (ctx: any) => string[]; rows?: (ctx: any) => any; tree?: (ctx: any) => any };
const viewCache = new Map<string, { mtime: number; view: View }>();
function loadViews(): View[] {
	let files: string[] = [];
	try { files = readdirSync(VIEWS_DIR).filter((f) => f.endsWith(".js") && !f.startsWith("_")).sort(); } catch {}
	return files.map((f) => {
		const path = join(VIEWS_DIR, f), mtime = statSync(path).mtimeMs, name = f.replace(/\.js$/, "").replace(/^\d+-/, "");
		let c = viewCache.get(path);
		if (!c || c.mtime !== mtime) {
			let view: View;
			try {
				const m: any = { exports: {} };
				const rq0 = createRequire(path); Object.keys(rq0.cache).filter((k) => k.startsWith(VIEWS_DIR)).forEach((k) => delete rq0.cache[k]);
				new Function("module", "exports", "require", readFileSync(path, "utf8"))(m, m.exports, rq0);
				if (!["render", "rows", "tree"].some((k) => typeof m.exports[k] === "function")) throw new Error("module.exports needs tree(), rows() or render()");
				view = { name, title: m.exports.title ?? name, prom: m.exports.prom, loki: m.exports.loki, render: m.exports.render, rows: m.exports.rows, tree: m.exports.tree };
			} catch (e: any) { const msg = e.message; view = { name, title: name, render: ({ h }: any) => [h.fg("error", `view ${f} failed to load: ${msg}`)] }; }
			c = { mtime, view }; viewCache.set(path, c);
		}
		return c.view;
	});
}

const fmtAge = (ms: number) => { const s = Math.max(0, Math.floor(ms / 1000)); return s < 60 ? `${s}s` : s < 3600 ? `${Math.floor(s / 60)}m` : s < 86400 ? `${Math.floor(s / 3600)}h` : `${Math.floor(s / 86400)}d`; };
const SPARK = "▁▂▃▄▅▆▇█";
export function helpers(theme: any) {
	const pad = (s: any, w: number) => { const t = truncateToWidth(String(s ?? ""), w, "…"); return t + " ".repeat(Math.max(0, w - visibleWidth(t))); };
	const status = (s: string) => {
		const good = /^(Healthy|Synced|Running|Succeeded|success|Ready)$/i, bad = /(Degraded|Failed|failure|Error|CrashLoop|ImagePull|Missing|OutOfSync|NotReady|OOMKilled|cancelled|timed_out)/i, busy = /(Progressing|Pending|Terminating|ContainerCreating|in_progress|queued|waiting|action_required)/i;
		return theme.fg(good.test(s) ? "success" : bad.test(s) ? "error" : busy.test(s) ? "warning" : "muted", s);
	};
	const bar = (pct: number, w: number) => { const p = Math.min(100, Math.max(0, pct || 0)), n = Math.round((p / 100) * w); return theme.fg(p > 85 ? "error" : p > 60 ? "warning" : "success", "█".repeat(n)) + theme.fg("dim", "░".repeat(w - n)); };
	const spark = (values: number[], w: number, max?: number) => {
		const v = (values ?? []).filter(Number.isFinite).slice(-w); if (!v.length) return theme.fg("dim", "·".repeat(w));
		const hi = max ?? Math.max(...v), lo = max === undefined ? Math.min(...v) : 0;
		return " ".repeat(w - v.length) + v.map((x) => SPARK[hi === lo ? 0 : Math.min(7, Math.floor(((x - lo) / (hi - lo)) * 7.999))]).join("");
	};
	const table = (cols: { h: string; w: number }[], rows: any[][]) =>
		[theme.fg("muted", cols.map((c) => pad(c.h, c.w)).join(" ")), ...rows.map((r) => cols.map((c, i) => pad(r[i], c.w)).join(" "))];
	const num = (x: number, digits = 1) => (Number.isFinite(x) ? (Math.abs(x) >= 100 ? x.toFixed(0) : x.toFixed(digits)) : "?");
	return { pad, status, bar, spark, table, num, age: fmtAge, fg: (c: string, s: string) => theme.fg(c, s), bold: (s: string) => theme.bold(s) };
}

const plainText = (x: any) => String(x ?? "").replace(/\x1b\[[0-9;]*m/g, "");
const labelOf = (id: string, store: Store) => {
	const [k, r] = [id.slice(0, id.indexOf(":")), id.slice(id.indexOf(":") + 1)];
	if (k === "vm") { const v = store.vms.find((x: any) => String(x.vmid) === r); return v ? `${v.name} (${r})` : r; }
	return k === "pod" || k === "wl" ? r.split("/")[1] : k === "ctr" ? r.split("/")[2] : r;
};

export default function (pi: ExtensionAPI) {
	let active = 0, height = 24, focused = false, open = false, timers: ReturnType<typeof setTimeout>[] = [];
	let rerender = () => {};
	onChange = () => rerender();
	// Per-view cursor state. Selection is remembered by row id, so live re-sorting keeps the cursor on the same object.
	type Nav = { open: Set<string>; sel: string; col: number; colStart: number; scroll: number; filter: string };
	const navs: Record<string, Nav> = {};
	const nav = (v: View) => (navs[v.name] ??= { open: new Set(), sel: "", col: 0, colStart: 0, scroll: 0, filter: "" });
	let pending = "", typing = false; // count prefix / "g", and whether "/" is collecting a filter
	// Last frame's clickable regions (rows relative to the component's top line).
	let layout = { win: { x0: 0, x1: 0 }, crumbIds: [] as string[], tabs: [] as { x0: number; x1: number; i: number }[], crumbs: [] as { x0: number; x1: number; depth: number }[], tabY: 0, crumbY: 1, rowY: 0, ids: [] as string[], room: 1 };

	const activeView = () => { const v = loadViews(); return v.length ? v[((active % v.length) + v.length) % v.length] : undefined; };
	const loop = (fn: () => Promise<void>, ms: () => number) => { const go = async () => { await fn(); rerender(); if (open) timers.push(setTimeout(go, ms())); }; go(); };
	const start = () => {
		watching = true; KINDS.forEach(watchKind);
		// Only the visible view's queries run, so hidden views cost nothing.
		loop(async () => { const q = activeView()?.prom; if (q) await pollProm(q); }, () => PROM_MS);
		loop(async () => { const q = activeView()?.loki; if (q) await pollLoki(q); }, () => LOKI_MS);
		loop(pollGh, () => (store.runs.some((r: any) => r.status !== "completed") ? GH_BUSY_MS : GH_IDLE_MS));
		loop(pollPve, () => PVE_MS);
		timers.push(setInterval(() => rerender(), 1000) as any); // ages tick, views hot-reload
	};
	const stop = () => { open = false; watching = false; timers.forEach((t) => { clearTimeout(t); clearInterval(t as any); }); timers = []; watchers.forEach((w) => w.kill()); watchers = []; };
	const refreshQueries = () => { const v = activeView(); if (v?.prom) pollProm(v.prom).then(() => rerender()); if (v?.loki) pollLoki(v.loki).then(() => rerender()); };

	// The visible rows of a view: a tree flattened through its expanded nodes, or a flat list; filtered; plus the cursor.
	const level = (v: View, h: any, width = 160) => {
		const n = nav(v), ctx = { store, h, width, win: win() };
		let r: any, rows: any[] = [];
		try {
			if (v.tree) {
				r = v.tree(ctx) ?? { cols: [], nodes: [] };
				const walk = (nodes: any[], depth: number, parent?: any) => {
					for (const x of nodes ?? []) {
						const kids = typeof x.children === "function", open = kids && n.open.has(x.id);
						const row = { ...x, depth, parent, kids, open };
						row.cells = [`${"  ".repeat(depth)}${kids ? (open ? "▾ " : "▸ ") : "  "}${x.cells[0] ?? ""}`, ...x.cells.slice(1)];
						rows.push(row);
						if (open) { let c: any[] = []; try { c = x.children(); } catch {} walk(c, depth + 1, row); }
					}
				};
				walk(r.nodes, 0);
			} else { r = v.rows!(ctx) ?? { cols: [], rows: [] }; rows = r.rows; }
		} catch (e: any) { r = { cols: [], empty: `view ${v.name} threw: ${e.message}` }; rows = []; }
		const f = n.filter.toLowerCase();
		if (f) rows = rows.filter((x: any) => x.cells.some((c: any) => plainText(c).toLowerCase().includes(f)));
		let i = rows.findIndex((x: any) => x.id === n.sel);
		if (i < 0) i = 0;
		return { ...r, rows, i };
	};
	const select = (v: View, id?: string) => { if (id) nav(v).sel = id; };
	// Ancestor ids of an object in a tree view (searching unexpanded children too), for tab and the breadcrumb.
	const findPath = (v: View, id: string): string[] | undefined => {
		if (!v.tree) return undefined;
		let nodes: any[] = []; try { nodes = v.tree({ store, h: h0(), width: 160, win: win() }).nodes; } catch { return undefined; }
		const dfs = (xs: any[], up: string[]): string[] | undefined => {
			for (const x of xs ?? []) {
				if (x.id === id) return up;
				if (typeof x.children === "function") { let c: any[] = []; try { c = x.children(); } catch {} const r = dfs(c, [...up, x.id]); if (r) return r; }
			}
		};
		return dfs(nodes, []);
	};

	const frame = (width: number, theme: any, rows: number) => {
		const views = loadViews(), h = helpers(theme);
		if (!views.length) return [theme.fg("warning", `lab: no views in ${VIEWS_DIR}`)];
		const v = activeView()!, n = nav(v);
		// header: tabs
		let x = visibleWidth("◉ lab "), tabs = "";
		layout.tabs = views.map((t, i) => {
			const label = t === v ? `[${t.title}]` : ` ${t.title} `, x0 = x; x += visibleWidth(label);
			tabs += t === v ? theme.bold(theme.fg("accent", label)) : theme.fg("dim", label);
			return { x0, x1: x, i };
		});
		const state = !store.updatedAt ? theme.fg("warning", "connecting…") : store.live ? theme.fg("success", "● live") : theme.fg("warning", "◐ partial");
		const hint = !focused ? "ctrl+shift+l to drive"
			: typing ? "type to filter · enter keep · esc clear"
			: v.tree ? "j/k move · enter expand · - collapse · h/l column · / filter · w window · tab view · ctrl+shift+l exit"
			: v.rows ? "j/k move · h/l column · / filter · w window · tab view · ctrl+shift+l exit" : "j/k scroll · w window · tab view · ctrl+shift+l exit";
		const winLabel = `⏱ ${WINDOWS.map((w, i) => (i === winIdx ? `[${w.k}]` : w.k)).join(" ")}`;
		layout.win = { x0: visibleWidth(`◉ lab ${plainText(tabs)}  `), x1: 0 }; layout.win.x1 = layout.win.x0 + visibleWidth(winLabel);
		const head = `${theme.fg("accent", "◉ lab")} ${tabs}  ${theme.fg("accent", winLabel)}  ${state} ${theme.fg("dim", "· " + hint)}${pending ? theme.fg("warning", " " + pending) : ""}`;
		// breadcrumb (clickable: each segment pops back to that depth)
		x = 0; let crumb = "";
		const lv0 = v.rows || v.tree ? level(v, h, width) : undefined, chain: any[] = [];
		for (let r = lv0?.rows[lv0.i]?.parent; r; r = r.parent) chain.unshift(r);
		const segs = [v.title, ...chain.map((r) => labelOf(r.id, store))]; layout.crumbIds = ["", ...chain.map((r) => r.id)];
		layout.crumbs = segs.map((label, depth) => {
			const sep = depth ? " › " : "", x0 = x + visibleWidth(sep); x = x0 + visibleWidth(label);
			crumb += theme.fg("dim", sep) + (depth === segs.length - 1 ? theme.bold(label) : theme.fg("accent", label));
			return { x0, x1: x, depth };
		});
		if (n.filter || typing) crumb += theme.fg("warning", `   /${n.filter}${typing ? "▏" : ""}`);
		const errs = Object.entries(store.errors).slice(0, 3).map(([k, e]) => theme.fg("error", `✖ ${k}: ${e}`));
		const top = [head, crumb, ...errs];
		layout.tabY = 0; layout.crumbY = 1;
		const room = Math.max(1, rows - top.length - 1); layout.room = room;

		if (!v.rows && !v.tree) { // render-only view: line scrolling
			let body: string[];
			try { body = v.render!({ store, width, h, theme, win: win() }) ?? []; } catch (e: any) { body = [theme.fg("error", `view ${v.name} threw: ${e.message}`)]; }
			n.scroll = Math.max(0, Math.min(n.scroll, body.length - room));
			layout.rowY = top.length; layout.ids = [];
			const shown = body.slice(n.scroll, n.scroll + room + 1);
			if (body.length > n.scroll + shown.length) shown[shown.length - 1] = theme.fg("dim", `… ${body.length - n.scroll - shown.length + 1} more`);
			return [...top, ...shown].map((l) => truncateToWidth(l, width));
		}

		const lv = lv0!;
		const cols = lv.cols as { h: string; w: number }[];
		n.col = Math.max(0, Math.min(n.col, cols.length - 1));
		// horizontal window: keep the column cursor visible
		const fits = (s0: number) => { let w = 2; for (let c = s0; c <= n.col; c++) w += cols[c].w + 1; return w <= width; };
		if (n.colStart > n.col) n.colStart = n.col;
		while (n.colStart < n.col && !fits(n.colStart)) n.colStart++;
		const vis: number[] = []; { let w = 2; for (let c = n.colStart; c < cols.length; c++) { if (vis.length && w + cols[c].w > width) break; vis.push(c); w += cols[c].w + 1; } }
		const more = (vis[0] ?? 0) > 0 ? "‹" : " ";
		const header = more + " " + vis.map((c) => (c === n.col && focused ? theme.bold(theme.fg("accent", h.pad(cols[c].h, cols[c].w))) : theme.fg("muted", h.pad(cols[c].h, cols[c].w)))).join(" ")
			+ (vis.at(-1)! < cols.length - 1 ? theme.fg("dim", " ›") : "");
		// vertical window around the cursor
		const bodyRoom = room - 1;
		n.scroll = Math.max(0, Math.min(n.scroll, Math.max(0, lv.rows.length - bodyRoom)));
		if (lv.i < n.scroll) n.scroll = lv.i; else if (lv.i >= n.scroll + bodyRoom) n.scroll = lv.i - bodyRoom + 1;
		const slice = lv.rows.slice(n.scroll, n.scroll + bodyRoom);
		layout.rowY = top.length + 1; layout.ids = slice.map((r: any) => r.id);
		const lines = slice.map((r: any, k: number) => {
			const mark = r.bad ? theme.fg("error", "▌") : " ";
			const line = `${mark} ` + vis.map((c) => h.pad(r.cells[c], cols[c].w)).join(" ");
			return n.scroll + k === lv.i ? theme.bg("selectedBg", h.pad(line, width)) : line;
		});
		if (!lv.rows.length) lines.push(theme.fg("dim", lv.empty || (n.filter ? `nothing matches /${n.filter}` : "empty")));
		const pos = lv.rows.length ? theme.fg("dim", `${lv.i + 1}/${lv.rows.length}${lv.rows.length > bodyRoom ? ` · ${lv.rows.length - slice.length} off screen` : ""}`) : "";
		return [...top, header, ...lines, pos].map((l) => truncateToWidth(l, width));
	};

	// ---- navigation verbs (shared by keys and mouse) ----
	const h0 = () => helpers({ fg: (_c: string, t: string) => t, bold: (t: string) => t, bg: (_c: string, t: string) => t });
	const move = (d: number) => {
		const v = activeView(); if (!v) return;
		if (!v.rows && !v.tree) { nav(v).scroll = Math.max(0, nav(v).scroll + d); return; }
		const lv = level(v, h0()); if (!lv.rows.length) return;
		select(v, lv.rows[Math.max(0, Math.min(lv.rows.length - 1, lv.i + d))].id);
	};
	const enter = () => { // toggle the selected node
		const v = activeView(); if (!v?.tree) return;
		const lv = level(v, h0()), row = lv.rows[lv.i]; if (!row?.kids) return;
		const o = nav(v).open; o.has(row.id) ? o.delete(row.id) : o.add(row.id); select(v, row.id);
	};
	const out = () => { // collapse the selected node, or jump to its parent and collapse that
		const v = activeView(); if (!v?.tree) return;
		const lv = level(v, h0()), row = lv.rows[lv.i]; if (!row) return;
		const target = row.open ? row : row.parent; if (!target) return;
		nav(v).open.delete(target.id); select(v, target.id);
	};
	const cycleWindow = (d: number) => { winIdx = (((winIdx + d) % WINDOWS.length) + WINDOWS.length) % WINDOWS.length; refreshQueries(); };
	const switchView = (to: number) => {
		const views = loadViews(), from = activeView(); if (!views.length) return;
		const target = views[((to % views.length) + views.length) % views.length];
		// Carry the selected object across trees: expand its ancestors in the target and select it.
		const fl = from && (from.rows || from.tree) ? level(from, h0()) : undefined, id = fl?.rows[fl.i]?.id;
		const up = id && findPath(target, id);
		if (up) { up.forEach((a) => nav(target).open.add(a)); nav(target).sel = id!; nav(target).filter = ""; }
		active = views.indexOf(target); refreshQueries();
	};
	const column = (d: number) => { const v = activeView(); if (v?.rows || v?.tree) nav(v).col = Math.max(0, nav(v).col + d); };

	const click = (ev: any, ctx: any) => {
		if (ev.type === "wheel") { move(Math.sign(ev.wheelDelta || 0) * Math.max(1, Math.abs(ev.wheelDelta || 1))); return { handled: true }; }
		if (ev.type !== "click" || ev.button !== "left") return undefined;
		if (ev.y === layout.tabY) {
			if (ev.x >= layout.win.x0 && ev.x < layout.win.x1) { cycleWindow(1); return { handled: true }; }
			const t = layout.tabs.find((t) => ev.x >= t.x0 && ev.x < t.x1); if (t) switchView(t.i); return { handled: true };
		}
		if (ev.y === layout.crumbY) { const c = layout.crumbs.find((c) => ev.x >= c.x0 && ev.x < c.x1), v = activeView(); if (c && v && layout.crumbIds[c.depth]) select(v, layout.crumbIds[c.depth]); return { handled: true }; }
		const id = layout.ids[ev.y - layout.rowY], v = activeView();
		if (id && v) {
			const already = nav(v).sel === id;
			select(v, id); if (already || (ev.clickCount ?? 1) >= 2) enter();
			if (!focused && ctx) void focus(ctx);
			return { handled: true };
		}
		return undefined;
	};

	let lastCtx: any;
	const show = (ctx: any) => { lastCtx = ctx; ctx.ui.setWidget("lab", (tui: any, theme: any) => {
		rerender = () => tui.requestRender();
		return {
			invalidate() {}, dispose() { rerender = () => {}; },
			render: (width: number) => frame(width, theme, height),
			handleMouse: (ev: any) => { const r = click(ev, lastCtx); if (r) tui.requestRender(); return r; },
		};
	}); };

	// Driving mode: the dashboard takes the keyboard and the screen until q/esc (or ctrl+shift+l), then the
	// passive widget returns above the prompt.
	const focus = async (ctx: any) => {
		if (focused || ctx.mode !== "tui") return;
		if (!open) { open = true; start(); }
		focused = true; pending = ""; typing = false; ctx.ui.setWidget("lab", undefined);
		await ctx.ui.custom((tui: any, theme: any, _kb: any, done: (v?: unknown) => void) => {
			rerender = () => tui.requestRender();
			const rows = () => tui.terminal?.rows ?? process.stdout.rows ?? 40;
			return {
				invalidate() {},
				// Paint every terminal row so nothing underneath shows through.
				render: (width: number) => { const r = rows(), l = frame(width, theme, r); return [...l, ...Array(Math.max(0, r - l.length)).fill("")].slice(0, r); },
				handleMouse: (ev: any) => click(ev, undefined),
				handleInput(data: string) {
					const v = activeView(); if (!v) return done();
					const n = nav(v), count = Math.max(1, parseInt(pending) || 1), half = Math.max(1, Math.floor(layout.room / 2));
					if (typing) {
						if (matchesKey(data, "escape")) { n.filter = ""; typing = false; }
						else if (matchesKey(data, "enter")) typing = false;
						else if (matchesKey(data, "backspace")) n.filter = n.filter.slice(0, -1);
						else if (data.length === 1 && data >= " ") n.filter += data;
						return tui.requestRender();
					}
					if (matchesKey(data, "ctrl+shift+l")) return done(); // the only way out; esc is pressed too often
					if (matchesKey(data, "escape")) { pending = ""; n.filter = ""; return tui.requestRender(); }
					if (pending === "g") { pending = ""; if (data === "g") move(-1e6); return tui.requestRender(); }
					if (/^[0-9]$/.test(data) && (pending || data !== "0")) { pending += data; return tui.requestRender(); }
					if (data === "g") { pending = "g"; return tui.requestRender(); }
					pending = "";
					if (data === "j" || matchesKey(data, "down")) move(count);
					else if (data === "k" || matchesKey(data, "up")) move(-count);
					else if (matchesKey(data, "ctrl+d")) move(half * count);
					else if (matchesKey(data, "ctrl+u")) move(-half * count);
					else if (data === "G") move(1e6);
					else if (matchesKey(data, "enter")) enter();
					else if (data === "-") out();
					else if (data === "l" || matchesKey(data, "right")) column(count);
					else if (data === "h" || matchesKey(data, "left")) column(-count);
					else if (matchesKey(data, "tab")) switchView(active + count);
					else if (matchesKey(data, "shift+tab")) switchView(active - count);
					else if (data === "/") { typing = true; n.filter = ""; }
					else if (data === "r") refreshQueries();
					else if (data === "w") cycleWindow(count);
					else if (data === "W") cycleWindow(-count);
					tui.requestRender();
				},
			};
		}, { overlay: true, overlayOptions: { anchor: "top-left", width: "100%", maxHeight: "100%", margin: 0 } });
		focused = false; pending = ""; typing = false;
		if (open) show(ctx);
	};
	pi.registerShortcut(Key.ctrlShift("l"), { description: "Drive the /lab dashboard (keyboard + full screen)", handler: focus });

	pi.registerCommand("lab", {
		description: "Live homelab dashboard: /lab [focus|next|prev|<view>|height N|off]",
		getArgumentCompletions: (prefix: string) =>
			["focus", "next", "prev", "off", "height", ...loadViews().map((v) => v.name)].filter((x) => x.startsWith(prefix)).map((value) => ({ value, label: value })),
		handler: async (args, ctx) => {
			const a = (args ?? "").trim();
			if (a === "off") { ctx.ui.setWidget("lab", undefined); stop(); return; }
			if (a === "focus") return focus(ctx);
			const views = loadViews();
			if (a === "next") switchView(active + 1); else if (a === "prev") switchView(active - 1);
			else if (a.startsWith("height")) height = Math.max(5, parseInt(a.split(/\s+/)[1]) || height);
			else if (a) { const i = views.findIndex((v) => v.name === a || v.title.toLowerCase() === a.toLowerCase()); if (i < 0) return ctx.ui.notify(`lab: no view "${a}" (have: ${views.map((v) => v.name).join(", ")})`, "warning"); active = i; }
			if (!open) { open = true; start(); show(ctx); } else { refreshQueries(); rerender(); }
		},
	});
	pi.on("session_shutdown", () => stop());

	pi.registerTool(defineTool({
		name: "lab_snapshot",
		label: "Lab snapshot",
		description: `Inspect /lab data so you can write or fix views (read ${VIEWS_DIR}/../README.md first). With no args returns the store (lists truncated). Pass prom or loki to test a query the way a view would declare it.`,
		parameters: Type.Object({
			key: Type.Optional(Type.String({ description: "Only this store key: hosts, vms, nodes, pods, deployments, apps, runs, prom, logs, errors" })),
			prom: Type.Optional(Type.String({ description: "PromQL to run over the last 30m (step 30s)" })),
			loki: Type.Optional(Type.String({ description: "LogQL to run over the last 15m" })),
		}),
		async execute(_id, p) {
			let out: any;
			if (p.prom) { await pollProm({ _probe: p.prom }); out = store.errors["prom:_probe"] ?? store.prom._probe; delete store.prom._probe; }
			else if (p.loki) { await pollLoki({ _probe: p.loki }); out = store.errors["loki:_probe"] ?? store.logs._probe?.slice(0, 20); delete store.logs._probe; }
			else {
				if (!store.updatedAt) { // not open: take one snapshot without starting watches
					await guard("k8s", async () => { for (const k of KINDS) { const m = raw.get(k)!; m.clear(); for (const o of JSON.parse(await run("kubectl", ["get", k, "-A", "-o", "json"])).items) m.set(`${o.metadata.namespace ?? ""}/${o.metadata.name}`, o); } derive(); });
					await pollGh(); await pollPve();
				}
				out = p.key ? { [p.key]: store[p.key] } : store;
			}
			delete store.errors["prom:_probe"]; delete store.errors["loki:_probe"];
			const text = JSON.stringify(out, (_k, v) => (Array.isArray(v) && v.length > 8 ? [...v.slice(0, 8), `…${v.length - 8} more`] : v), 1);
			return { content: [{ type: "text", text: text ?? "null" }], details: {} };
		},
	}));
}
