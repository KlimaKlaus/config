#!/bin/bash
# OMP pre-session hook: kill abandoned processes from prior OMP sessions.
# Runs before a new session starts. $1 = workdir.
set -euo pipefail

WORKDIR="${1:-$(pwd)}"

# Pass 1: Kill orphans in ANY .worktree/ directory running >10 min.
# These are leftovers from crashed/closed sessions whose post-hook didn't fire.
worktree_orphans=$(ps -eo pid,ppid,etimes,command -ww 2>/dev/null | awk '
  NR > 1 && $2 == 1 && $3 > 600 {
    cmd = substr($0, index($0, $4))
    if (cmd ~ /\.worktree\//) { print $1 }
  }
')

if [[ -n "$worktree_orphans" ]]; then
  echo "[omp-cleanup-pre] Killing orphaned worktree processes: $worktree_orphans"
  echo "$worktree_orphans" | xargs kill -9 2>/dev/null || true
fi

# Pass 2: Kill orphans in THIS workdir, regardless of age.
# Catches processes from a session that just ended in the same directory.
if [[ -n "$WORKDIR" ]]; then
  local_orphans=$(ps -eo pid,ppid,command -ww 2>/dev/null | awk -v wd="$WORKDIR" '
    NR > 1 && $2 == 1 && index($0, wd) > 0 { print $1 }
  ')
  if [[ -n "$local_orphans" ]]; then
    echo "[omp-cleanup-pre] Killing orphaned processes in $WORKDIR: $local_orphans"
    echo "$local_orphans" | xargs kill -9 2>/dev/null || true
  fi
fi
