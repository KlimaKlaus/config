---
name: syncing-vps-dotfiles
description: Use when the user asks to update, sync, or push their VPS bashrc/vimrc gists, or mentions keeping VPS dotfiles in sync with the Nix config
---

# Syncing VPS Dotfiles

## Overview

Canonical config lives in this Nix repo (`~/config`). Two portable gists are derived from it for Linux VPS use. When the Nix config changes, the gists may need updating.

## Gist → Source Mapping

| Gist | ID | Canonical Source |
|------|----|------------------|
| `.vimrc` | `881ef84c819f25f5b25ea307df0e0970` | `nix/common/vim.nix` `extraConfig` block |
| `.bashrc` | `3c0bbabf75b2d17ffd616aae58bd67f7` | `nix/common/shell/aliases.nix`, `nix/common/git.nix` |

## Workflow

1. **Read the canonical source** — `nix/common/vim.nix` for vimrc, `nix/common/shell/aliases.nix` + `nix/common/git.nix` for bashrc
2. **Read the current gist** — fetch via `read` with the raw URL
3. **Derive the portable version** — strip Nix wrappers, translate zsh→bash where needed, skip macOS/zsh-specific items
4. **Update the gist** — use `gh gist edit` with the new content

## Vimrc Translation

The `extraConfig` string in `vim.nix` is already raw vimscript. Extract everything between the opening `''` and closing `''` (the `extraConfig` block content), keeping the header comment block from the gist.

The gist header (`# Portable vimrc — Catppuccin Mocha themed` through install instructions) should be preserved unless outdated. The `call plug#begin()` / `call plug#end()` wrapper wraps the plugin list; the Nix `plugins` list maps to `Plug` lines inside that block.

## Bashrc Translation

The Nix config is **zsh**. The bashrc gist is **bash 3.2+**. Filter aggressively:

### Always port (shell-agnostic)
- Git aliases from `aliases.nix` (`gup`, etc.) — ensure they exist in the gist's alias section
- General aliases from the gist's existing list (don't drop what's already there unless Nix removed it)
- New git aliases found in `aliases.nix` that aren't in the gist yet

### Never port (macOS/zsh/secret-dependent)
- SSH aliases (`ssh-termux`, `ecoray-*`) — depend on `nix_secrets` env vars
- `heic2tiff` — macOS-only (`sips`)
- `omp` wrapper — macOS-only
- `yt-dlp` / `repolicense` — local binaries
- `direnv`, `zoxide`, `fzf` init — zsh-specific
- `alias-tips` — zsh-specific
- Mole/Opencode completions — zsh-specific + tool-specific
- `TIMEFMT` — zsh-specific
- `MULTICA_*` — work-specific
- `nrs`, `nix-search`, `nix-which`, `nix-update`, `nix-rollback` — NixOS/darwin-specific
- PATH exports — macOS-specific paths

### Judgment calls
- Git `delta` pager: gist already omits it (delta unlikely on VPS). Keep omitted.
- `lg` (lazygit): already in gist with fallback. Keep.
- Starship prompt: gist uses a hand-rolled PS1 instead. Keep the hand-rolled PS1.

## Updating a Gist

```bash
gh gist edit <GIST_ID> - <<'EOF'
<full new content>
EOF
```

Or write to a temp file first, then:
```bash
gh gist edit <GIST_ID> /tmp/gist-content
```

The `gh gist edit` command opens `$EDITOR` by default — always pipe or pass a file to avoid interactive editor.

## After Updating

Confirm the raw URL renders correctly:
```bash
curl -sL https://gist.githubusercontent.com/lucasfth/<GIST_ID>/raw/ | head -5
```
