---
type: skill
tags: [freyr, nixos, ssh, sudo, tailscale]
status: active
updated: 2026-07-21
---

# Sudo over SSH + Freyr

## Sudo over Tailscale SSH

Tailscale SSH chokes on interactive sudo prompts (hangs forever). Always pipe the password:

```bash
echo <psw> | sudo -S <command> 2>&1
```

Never run `sudo <cmd>` without `-S` and piped password — it will time out.

## Long-running commands (nixos-rebuild)

Background builds and poll the log — foreground commands time out:

```bash
# Start build
tailscale ssh lucas@freyr 'echo <psw> | sudo -S nixos-rebuild boot --flake ~/config#freyr --impure > /tmp/build.log 2>&1 &'

# Wait, then check
sleep 30 && tailscale ssh lucas@freyr 'tail -5 /tmp/build.log'
```

"Done. The new configuration is ..." → success.

## Tailscale daemon stability

If ALL commands time out (even `hostname`) — daemon crashed. User runs locally on Freyr:

```bash
sudo pkill -9 tailscaled
sudo /home/lucas/.nix-profile/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &
sleep 2
```

Then `tailscale set --ssh` if needed.

## NixOS-specific gotchas

- `/etc` is **read-only** — `systemctl mask`, `cp` to `/etc/systemd/`, `tee /etc/...` all fail silently or with "Read-only file system"
- Display manager service: `display-manager`, **not** `sddm`
- Shebangs: `#!/usr/bin/env bash`, **not** `#!/bin/bash` (NixOS has no `/bin/bash`)
- SDDM + plasma6: don't set `services.displayManager.sddm` AND `services.xserver.desktopManager.plasma6.enable` — plasma6 brings its own SDDM, duplicate causes build error

## Freyr hardware

| Thing | Path |
|-------|------|
| SSH | `tailscale ssh lucas@freyr` |
| ESP | `/dev/nvme0n1p1` → `/boot` (vfat) |
| Root | `/dev/nvme0n1p2` (ext4, UUID `84f85783-...`) |
| Swap | None |
| GPU | NVIDIA RTX 3070 |
| CPU | AMD 5800X |

## Boot generations

- Gen 1: KDE Plasma, nixos-install, fallback (always boots)
- Gen 2+: flake builds via `nixos-rebuild boot`
- Gen 2 boots → task done. Desktop config may need follow-up.
