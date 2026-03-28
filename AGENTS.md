# Agent Notes

- `yadm` is the target dotfiles manager for this repo.
- This repository is being migrated to a home-layout structure suitable for `yadm`.
- Tracked files should now be edited at their real home-relative paths inside the repo (for example `.gitconfig`, `.config/nvim/...`, `.ssh/config`).
- Machine-local identity and secret files should remain untracked.
- `script/` is part of the tracked home layout and is expected to exist as `~/script` on managed machines.
- The documentation in `README.md` and `docs/plans/` should stay aligned with the actual config.
- When changing Brew profiles/manifests, setup/bootstrap behavior, identity flows, or tracked file layout, explicitly check for documentation drift and update the docs in the same change when needed.
- If current behavior and docs disagree, call it out clearly instead of silently preserving stale documentation.
