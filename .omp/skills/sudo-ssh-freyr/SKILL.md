---
type: skill
tags: [freyr, nixos, ssh, sudo, tailscale, llama, ollama, llm, omp]
status: active
updated: 2026-07-23
---

# Sudo over SSH + Freyr

## Prerequisites

Env vars must be exported (set in `nix/common/shell/aliases.nix`):

- `ECORAY_FREYR_USER` — SSH user
- `ECORAY_FREYR_IP` — Tailscale IP

The `freyr` shell alias expands to `ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP"`.

## SSH

Regular SSH over Tailscale IP — Tailscale SSH is disabled on Freyr:

```bash
ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP"
# or: freyr
```

If `ControlMaster` socket errors: `ssh -o ControlMaster=no "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP"`

## Sudo

Regular SSH handles sudo prompts fine (unlike Tailscale SSH which hung). Password is known.

## Long-running commands (nixos-rebuild)

Background builds and poll the log:

```bash
ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP" 'echo <psw> | sudo -S nixos-rebuild boot --flake ~/config#freyr --impure > /tmp/build.log 2>&1 &'
sleep 30 && ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP" 'tail -5 /tmp/build.log'
```

"Done. The new configuration is ..." → success.

## NixOS-specific gotchas

- `/etc` is **read-only** — `systemctl mask`, `cp` to `/etc/systemd/`, `tee /etc/...` all fail silently
- Display manager service: `display-manager`, **not** `sddm`
- Shebangs: `#!/usr/bin/env bash`, **not** `#!/bin/bash`
- SDDM + plasma6: don't set both — plasma6 brings its own SDDM

## Freyr hardware

| Thing | Path |
|-------|------|
| SSH | `ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP"` |
| ESP | `/dev/nvme0n1p1` → `/boot` (vfat) |
| Root | `/dev/nvme0n1p2` (ext4, UUID `84f85783-...`) |
| Swap | None |
| GPU 0 | RTX 3070 (NVIDIA 595, CUDA 13.2, display) |
| GPU 1 | RTX 5070 Ti (headless, needs 570+ driver) |
| CPU | AMD 5800X |

## Boot generations

- Gen 1: KDE Plasma, nixos-install, fallback (always boots)
- Gen 25+: flake builds, Openbox + NVIDIA 3070, working

## LLM services

Freyr runs three inference services, all reachable directly via Tailscale from Lucas's Mac:

| Port | Service | Model | GPU |
|------|---------|-------|-----|
| 8083 | llama.cpp | Qwen2.5-VL-7B-Instruct (Q4_K_M) | GPU 1 (RTX 5070 Ti) |
| 11434 | Ollama | qwen2.5:7b-instruct | GPU 0 (RTX 3070) |

Also running: embedding server, reranker server, and `server2.py` (klaus-services).

### Vision model (port 8083)

```bash
curl -s http://$ECORAY_FREYR_IP:8083/v1/models
# → qwen25-vl-7b, multimodal
```

Server alias: `qwen25-vl-7b`. Runs inside a restart loop (`vision_server.sh`) inside tmux.

### Ollama (port 11434)

```bash
curl -s http://$ECORAY_FREYR_IP:11434/api/tags
# → qwen2.5:7b-instruct
```

## OMP integration

Freyr serves as the **vision** model role in OMP (`~/.omp/agent/config.yml`):

```yaml
modelRoles:
  vision: freyr-vision/qwen25-vl-7b
```

Provider defined in `~/.omp/agent/models.yml`:

```yaml
providers:
  freyr-vision:
    baseUrl: http://$ECORAY_FREYR_IP:8083
    auth: none
    api: openai-completions
    discovery:
      type: llama.cpp

  freyr-ollama:
    baseUrl: http://$ECORAY_FREYR_IP:11434
    api: openai-completions
    discovery:
      type: ollama
```

### Vision testing

Vision works via the `inspect_image` tool (default disabled) or when OMP's main loop passes an image to the vision model. Direct API test:

```bash
curl -s http://$ECORAY_FREYR_IP:8083/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen25-vl-7b","messages":[{"role":"user","content":[{"type":"text","text":"Describe this image"},{"type":"image_url","image_url":{"url":"data:image/png;base64,..."}}]}],"max_tokens":100}'
```
