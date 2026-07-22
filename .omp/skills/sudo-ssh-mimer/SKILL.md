---
type: skill
tags: [mimer, ubuntu, ssh, tailscale, llama, llm]
status: active
updated: 2026-07-22
---

# Mimer (Klaus)

Ecoray GPU server running llama.cpp inference.

## Prerequisites

Env vars must be exported (set in `nix/common/shell/aliases.nix`):

- `ECORAY_MIMER_USER` — SSH user (`ecoray-admin`)
- `ECORAY_MIMER_IP` — Tailscale IP

The `mimer` shell alias expands to `ssh "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP"`.

## SSH

```bash
ssh "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP"
# or: mimer
```

## LLM server

llama.cpp serving Qwen3.5-122B-A10B-Q4_K_M.gguf (MoE, 122B total / 10B active) on port 8080.

### Status

```bash
curl -s http://localhost:8080/health          # {"status":"ok"}
curl -s http://localhost:8080/v1/models       # list loaded models
```

But since it's remote, tunnel or SSH-port-forward first:

```bash
ssh -L 8080:localhost:8080 "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP"
```

### Process management

Runs inside a tmux session named `qwen-server`. To inspect:

```bash
ssh "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP" tmux capture-pane -t qwen-server -p
```

Server binary: `/home/ecoray-admin/llama.cpp/build/bin/llama-server`
Model path: `/home/ecoray-admin/llama.cpp/models/Qwen3.5-122B-A10B-Q4_K_M.gguf`
Log: `/tmp/llama-server.log`

## Mimer hardware

| Thing | Path |
|-------|------|
| SSH | `ssh "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP"` |
| Hostname | Klaus |
| OS | Ubuntu 24.04.4 LTS |
| CPU | AMD Ryzen 7 9700X (8-core) |
| GPU | NVIDIA RTX PRO 6000 Blackwell, 96 GB VRAM, driver 580 |
| RAM | 123 GB |
| ESP | `/dev/nvme0n1p1` → `/boot/efi` (511M) |
| Root | `/dev/nvme0n1p2` (908 GB, 717G free) |
