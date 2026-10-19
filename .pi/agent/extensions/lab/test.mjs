// Headless harness: node test.mjs [focus | <view>...]  (fakes the pi host; talks to the live cluster)
import assert from "node:assert";
import { createJiti } from "/opt/homebrew/Cellar/pi-coding-agent/1.2.0/libexec/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/jiti/lib/jiti.mjs";
const root = "/opt/homebrew/Cellar/pi-coding-agent/1.2.0/libexec/lib/node_modules/@earendil-works/pi-coding-agent";
const jiti = createJiti(import.meta.url, { alias: {
	"@earendil-works/pi-coding-agent": `${root}/dist/index.js`,
	"@earendil-works/pi-tui": `${root}/node_modules/@earendil-works/pi-tui/dist/index.js`,
	"@earendil-works/pi-ai": `${root}/node_modules/@earendil-works/pi-ai/dist/index.js`,
} });
const lab = await jiti.import(new URL("./index.ts", import.meta.url).pathname);
const chunks = []; lab.jsonStream((d) => chunks.push(d))('{"a":"}"}{"b":{"c":1}}'); assert.deepEqual(chunks, [{ a: "}" }, { b: { c: 1 } }]);
console.log("ok: jsonStream");
const args = process.argv.slice(2); if (!args.length) process.exit(0);
const cmds = {}, keys = {}; let widget, comp, finished;
lab.default({ registerCommand: (n, c) => (cmds[n] = c), registerTool() {}, registerShortcut: (k, o) => (keys[k] = o), on() {} });
const theme = { fg: (_c, s) => s, bold: (s) => s, bg: (_c, s) => `«${s}»` };
const tui = { requestRender() {}, terminal: { rows: 30 } };
const ctx = { mode: "tui", ui: { notify: console.log, setWidget: (_k, f) => (widget = f && f(tui, theme)),
	custom: (factory) => new Promise((res) => { comp = factory(tui, theme, {}, (v) => { finished = true; res(v); }); }) } };
const plain = (l) => l.join("\n").replace(/\x1b\[[0-9;]*m/g, "");
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
if (args[0] === "focus") {
	const p = keys["ctrl+shift+l"].handler(ctx); await wait(7000);
	const scr = () => plain(comp.render(260)).split("\n");
	const crumb = () => scr()[1].trim(), sel = () => (scr().find((l) => l.includes("«")) ?? "").replace(/[«»]/g, "").trim();
	const press = (...k) => k.forEach((x) => comp.handleInput(x));
	assert.equal(widget, undefined, "widget hidden while driving");
	console.log(scr().slice(0, 8).join("\n"), "\n---");
	const row = (re) => scr().find((l) => re.test(l)) ?? "";
	const host0 = sel(); press("j"); assert.notEqual(sel(), host0, "j moves"); press("k"); assert.equal(sel(), host0);
	press("\r"); assert.match(sel(), /▾/, "enter expands"); const n0 = scr().length;
	press("/", ..."worker-0", "\r", "\r"); console.log("vm expanded:", sel().slice(0, 70)); assert.match(sel(), /▾ platform-worker-0/);
	press("\x1b", "j"); console.log("pod row:", sel().replace(/\s+/g, " ").slice(0, 120)); console.log(scr().filter((l) => /platform-/.test(l)).map((l) => l.replace(/\s+/g, " ").slice(0, 170)).join("\n")); assert.match(sel(), /\d+(m|c)\b.*\d+(Mi|Gi)/, "pod shows cpu+mem");
	press("\r", "j"); console.log("container row:", sel().replace(/\s+/g, " ").slice(0, 160)); press("k");
	press("\t"); console.log("tab →", crumb(), "|", sel().slice(0, 60)); assert.match(crumb(), /^apps › /);
	press("-"); console.log("- →", sel().slice(0, 60)); press("-"); press("-");
	press("\t", "\t", "w"); console.log(scr().slice(0, 6).map((l) => l.slice(0, 150)).join("\n"));
	press("\t"); await wait(5000); console.log(scr().slice(0, 7).map((l) => l.slice(0, 150)).join("\n"));
	press("\r"); console.log("log group expanded:", scr().length);
	comp.handleInput("\x1b"); comp.handleInput("q"); assert.ok(!finished, "esc/q stay"); comp.handleInput("\x1b[108;6u"); await p; assert.ok(finished && widget, "q returns to the prompt with the widget");
	console.log("focus ok"); await cmds.lab.handler("off", ctx); process.exit(0);
}
await cmds.lab.handler("height 40", ctx);
for (const v of args) { await cmds.lab.handler(v, ctx); await wait(6000); console.log(plain(widget.render(160))); console.log("-----"); }
await cmds.lab.handler("off", ctx); process.exit(0);
