# Agentic.nvim + pi-acp grievances

This started as a working list of rough edges discovered while trying `agentic.nvim` with `pi-acp` as the ACP provider for Pi. It now also includes the updated plan after checking existing Pi ecosystem extensions: reuse Pi extensions where possible, improve `pi-acp` as the bridge, and keep Agentic focused on Neovim UI/context.

## Primary grievances

- Diff previewing is not good enough yet.
  - `pi-acp` can emit a structured ACP diff after a Pi `edit` by snapshotting the file before/after the edit.
  - This is post-apply, not a pre-apply accept/reject flow.
  - Agentic's stronger diff preview path appears tied to ACP permission requests, and `pi-acp` does not currently emit permission requests before file edits.
  - `write`/new-file/full-file replacement behavior may be less complete than `edit` because the snapshot/diff path is focused on `edit`.

- Extension slash commands are not surfaced completely.
  - `pi-acp` advertises commands after session creation, but currently excludes extension commands in the preferred `pi getCommands()` path.
  - File prompt templates work better than extension-provided commands.
  - Agentic slash command completion depends on provider-advertised ACP `available_commands_update`, so missing provider commands are invisible in Neovim.

- Session sharing is unsafe and underspecified.
  - Pi session files are append-only JSONL with no obvious active-session lock/lease.
  - Restoring an idle existing session is useful.
  - Restoring and prompting into a session that another Pi process is actively using risks concurrent writes and confusing history.
  - There is no guard/warning that a selected session is active elsewhere.
  - There is no first-class safe sharing model: read-only attach, follow/tail, fork-before-prompt, handoff, or explicit takeover.

- Session restore is fragile.
  - Restore lists sessions by exact `cwd`, so path differences like `~/lumora/...` vs `~/dev/lumora/...` split history.
  - Restore picker can be empty for non-obvious reasons because of exact cwd filtering.
  - Historical replay can expose ACP shape mismatches, e.g. `rawInput = null` from `pi-acp` decoding to Neovim userdata and crashing Agentic.
  - `session_info_update` from `pi-acp` is not handled by Agentic and causes warning spam unless patched locally.

- Neovim context integration is too manual and too coarse.
  - The useful editor context is often “what I am looking at right now”, not just the current file or current visual selection.
  - Agentic should make it easy to include all buffers visible in the current Neovim tab, including window-local cursor positions and visible ranges.
  - Diagnostics should be composable with context. A single action should be able to include visible buffers plus their diagnostics, rather than separate “add file/selection” and “add diagnostics” flows.
  - Context primitives should exist for different levels of detail: whole file, current viewport, visual selection, diagnostics, Tree-sitter symbols/captures, LSP symbols, quickfix/location-list entries, and maybe git hunks.
  - The current mapping model (`add selection/current file`, `add diagnostics`) does not reflect richer context bundles the user actually wants to send.

- `pi-acp` is not aware enough of the Neovim session.
  - Pi should silently receive basic Neovim state by default, at minimum: buffer list, visible windows in the current tab, current file, cursor positions, cwd, and diagnostics summary.
  - This editor state should be available as context without forcing the user to paste or manually add every file.
  - Pi should be able to reason about the editor session as a live workspace, not just a project directory plus explicit file links.

- Agentic/Pi cannot co-drive Neovim with the user.
  - The agent should be able to move or suggest the user's view to relevant files, lines, symbols, diagnostics, or hunks while talking.
  - Useful actions include opening a file, jumping to a location, focusing an existing window, setting quickfix/location lists, highlighting ranges, and showing references.
  - This should feel like collaborative navigation, not just chat plus file edits.
  - There is no clear ACP/Agentic primitive yet for safe UI navigation requests from `pi-acp` into Neovim.

- Agentic theming/layout is not configurable enough for a Pi/Claude Code-like full-screen experience.
  - Existing right/left/bottom widget layouts are useful, but not the same as a dedicated full-screen tab.
  - Styling is split across filetypes, markdown rendering, headers, icons, statusline/winbar integration, and highlight groups.
  - It should be possible to make Agentic look like Pi/Claude Code in a whole-screen tab without ad hoc local patches.

## Ecosystem research update

Existing Pi extensions already cover many of the Pi-side behaviors that were initially listed as gaps. The conclusion is that `pi-acp` should bridge Pi proper and Pi extensions into ACP rather than reimplementing those features.

- `pi-show-diffs` is the strongest candidate for pre-apply edit review.
  - It hooks Pi tool calls for `edit`, `hashline_edit`, and `write` and presents a diff approval flow before changes are applied.
  - This should be treated as the preferred Pi-side answer for diff approval experiments.
  - The missing ACP piece is not the diff logic; it is translating Pi extension UI requests into ACP/Agentic permission or dialog UI.

- `pi-bash-confirm` / `ai-permission-gate` cover dangerous shell-command confirmation.
  - These are good examples of policy as a Pi extension.
  - `pi-acp` should surface their `ctx.ui` prompts instead of inventing a parallel shell permission system.

- `pi-mcp-adapter` covers Pi-native MCP tool discovery and proxying.
  - `pi-acp` currently accepts/stores ACP `mcpServers` but does not meaningfully hand them to Pi.
  - A useful bridge would either translate ACP MCP config into `pi-mcp-adapter` config or document that Pi-side MCP should be configured through Pi settings.

- `pi-lsp-extension` and `pi-lens` cover Pi-side diagnostics, symbols, lint/format feedback, and language-server awareness.
  - Prefer `pi-lsp-extension` for low-risk experiments.
  - Treat `pi-lens` carefully because its auto-install/tool-management behavior can conflict with the preference that external tools are already on `PATH` and managed by Brew/mise, not by Neovim or an editor plugin.

- Plannotator, `@ifi/pi-plan`, `pi-subagents`, and related packages cover plans, review workflows, and delegated work.
  - These are better Pi-extension features than Agentic-specific reimplementations.
  - Agentic should provide good UI for commands/status/results once `pi-acp` exposes them.

- `pi-rewind` and oh-pi git/worktree helpers cover checkpoint/rewind and guarded file restoration.
  - These overlap with Zed-style checkpoints more than the base `pi-acp` MVP does.
  - `pi-acp` should surface checkpoint commands/status where possible, but full checkpoint semantics should stay in Pi extensions unless ACP requires a standardized edit transaction.

- `pi-context`, `pi-context-prune`, and `pi-continue` cover context pruning and long-run continuation.
  - These improve Pi sessions in every client.
  - Agentic should not own compaction/continuation logic; it should expose status and commands cleanly.

- `pi-nvim` proves a Neovim-to-Pi socket bridge pattern.
  - It is useful prior art for editor context and session discovery.
  - It is not a direct replacement for Agentic + ACP because it sends prompts into a separate running Pi terminal session rather than providing an embedded ACP client workflow.

- `pi-intercom`, `@ifi/pi-web-remote`, `team`, and similar packages cover multi-session communication/collaboration.
  - These are adjacent to safe session sharing, but do not replace an explicit active-session lease/restore warning model for `pi-acp` + Agentic.

## Revised ownership model

- Pi core should remain responsible for sessions, transcript/runtime state, tool execution, model/thinking/compaction behavior, extension lifecycle hooks, and RPC events.
- Pi extensions should own reusable agent behavior: permission gates, pre-apply edit review, checkpoints/rewind, plan/TODO flows, MCP proxying, context management, session collaboration, and language-server feedback.
- `pi-acp` should be a faithful bridge from Pi/RPC/extensions to ACP:
  - translate Pi messages/tool calls/session state into ACP updates;
  - handle `extension_ui_request` / `extension_ui_response` so extension UI does not hang in RPC mode;
  - expose extension commands through ACP `available_commands_update` once extension UI is safe;
  - normalize historical/replayed session shapes so Agentic does not crash;
  - optionally map ACP client capabilities, MCP config, and `_meta.piAcp` escape hatches into Pi-native equivalents.
- `agentic.nvim` should own Neovim-side UX:
  - buffers, tabs, windows, viewport, cursor, diagnostics, quickfix/location-list, Tree-sitter, and LSP context bundles;
  - diff/permission/dialog rendering using ACP-native structures first;
  - full-screen layout/theming, session pickers, restore warnings, and safe navigation/follow UI;
  - optional Neovim co-driving primitives such as open file, jump to location, focus window, highlight ranges, and populate quickfix.

## Updated plan

1. Bridge Pi extension UI in `pi-acp` before enabling more commands.
   - Implement `extension_ui_request` handling for confirm/select/input/editor/notify/status/widget/title/editor-text flows.
   - Map simple confirms/selects to ACP permission/dialog flows when possible.
   - Use `_meta.piAcp` only for Pi-specific UI details that ACP cannot represent.
   - This is the prerequisite for `pi-show-diffs`, permission gates, `pi-ask`, Plannotator, and many oh-pi overlays.

2. Expose Pi extension slash commands through `pi-acp`.
   - Stop excluding extension commands from the preferred `getCommands()` path once extension UI is bridged.
   - Convert Pi command metadata into ACP `available_commands_update` entries.
   - Add provenance or grouping so Agentic can distinguish built-in Pi commands, file prompt templates, and extension commands.

3. Trial existing extensions instead of building local clones.
   - First candidates: `pi-show-diffs`, `pi-mcp-adapter`, `pi-lsp-extension`, `pi-rewind`, and a bash permission gate.
   - Avoid or strictly configure extensions that auto-install tools unless they respect the existing Brew/mise/PATH policy.
   - Document which packages work cleanly through ACP after the bridge exists.

4. Harden `pi-acp` session and history behavior.
   - Normalize session updates and replayed raw input/output values.
   - Improve restore filtering beyond exact `cwd` where safe.
   - Surface Pi session status, stats, model/thinking state, queue/running state, and extension-derived status where possible.
   - Add an active-session lease/heartbeat extension if Pi core does not provide a first-class lock.

5. Improve Agentic UX on top of native ACP data.
   - Render diffs, permission requests, extension dialogs, command pickers, and status in Neovim-native UI.
   - Add full-screen Pi-like tab layout and better theming controls.
   - Add restore picker warnings for active/foreign/cross-cwd sessions.

6. Add Neovim context and co-driving last, in Agentic or a small companion bridge.
   - Context bundles: visible buffers, viewport ranges, diagnostics, symbols, quickfix/location-list, git hunks, current tab/window/cursor state.
   - Navigation/follow actions should start as suggest/confirm flows, not autonomous UI takeover.
   - Prefer ACP-native client tools/capabilities if available; otherwise use a small `_meta.piAcp` bridge that degrades gracefully.

7. Escalate to Pi core or ACP only for hard primitives.
   - Examples: transactional hunk-level pre-apply edit approvals, first-class session locks/leases, standardized extension UI, client terminal delegation, or generic editor navigation/follow primitives.
   - Do not move extension-sized behavior into Pi core just because Agentic needs to display it.

## Other gaps observed during setup

- Tool installation story is awkward.
  - `pi-coding-agent` is Brew-managed, but `pi-acp` is npm-only right now.
  - Local trial requires an untracked `~/.mise.local.toml` exception.
  - Neovim must be launched with a PATH that includes mise-provided `pi-acp`; GUI/non-interactive launches may not work.

- Health checks are shallow.
  - `:checkhealth agentic` verifies `pi-acp` is installed when Agentic is loaded.
  - It does not verify Pi auth, token validity, model availability, or that `pi-acp` can actually create a session.
  - If Agentic is lazy and not loaded, `:checkhealth agentic` reports no healthcheck.

- Agentic custom provider ergonomics are rough.
  - Built-in provider switching does not list custom providers like `pi-acp`, so provider switching was disabled locally.
  - Model/mode/thinking-level support depends on provider config/options and is not clearly validated for Pi.

- Closing vs stopping vs ending is unclear.
  - Closing Agentic hides the UI but leaves the session/provider alive.
  - Stopping generation cancels work but keeps the session active.
  - Starting a new session abandons the current UI session.
  - There is no obvious public, user-friendly lifecycle vocabulary for “hide chat”, “stop work”, “start fresh”, and “disconnect provider”.

- UI integration needed local patching.
  - Completion needed to be disabled in `AgenticInput`.
  - Lualine/statusline/winbar needed to be disabled for Agentic buffers.
  - Telescope `ui-select` could crash on empty pickers with `Invalid cursor line: out of range`.

- Context support is basic.
  - Agentic sends file context as resource links; `pi-acp` translates common content types, but embedded context is disabled by default.
  - Audio is unsupported in `pi-acp`.
  - File/context behavior should be verified against Pi's expectations for project-aware work.
  - Context is mostly explicit and prompt-local, not a persistent model of the Neovim tab/workspace.

- Restore/history rendering is lossy.
  - Historical tool calls are replayed synthetically.
  - Some raw inputs/outputs may be missing, null, or in shapes Agentic does not expect.
  - Tool calls from restored history should not trigger current edit hooks or buffer reload assumptions.

## Local patches/workarounds currently in the Neovim config

- CodeCompanion is disabled while trying Agentic.
- Agentic is configured with custom provider `pi-acp` and `PI_ACP_PI_COMMAND=/opt/homebrew/bin/pi`.
- `<leader>at` toggles Agentic between right and bottom layouts.
- Agentic completion is disabled in `AgenticInput`.
- Lualine is disabled for Agentic filetypes.
- Telescope `vim.ui.select` has an empty-list guard.
- Agentic is patched locally to ignore/handle `session_info_update`.
- Agentic is patched locally to normalize non-table `rawInput` during tool-call replay.
