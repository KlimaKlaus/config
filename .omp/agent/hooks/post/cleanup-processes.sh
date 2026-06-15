#!/bin/bash
# OMP post-session hook: kill orphaned child processes spawned by this session.
# Runs after the session exits. $1 = workdir.
set -euo pipefail

WORKDIR="${1:-$(pwd)}"
[[ -z "$WORKDIR" ]] && exit 0

# Find orphaned processes (PPID=1) whose command line contains this worktree path.
# These are children of the session's bash tool that outlived their parent.
matches=$(ps -eo pid,ppid,command -ww 2>/dev/null | awk -v wd="$WORKDIR" '
  NR > 1 && $2 == 1 && index($0, wd) > 0 { print $1 }
')

if [[ -n "$matches" ]]; then
  echo "[omp-cleanup] Killing orphaned processes in $WORKDIR: $matches"
  echo "$matches" | xargs kill -9 2>/dev/null || true
fi
