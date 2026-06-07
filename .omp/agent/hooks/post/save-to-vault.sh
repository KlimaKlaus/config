#!/bin/bash
set -euo pipefail
VAULT="$HOME/vault"
PROJECTS="$VAULT/projects"
WORKDIR="${1:-$(pwd)}"

# ── Detect project ──────────────────────────────────────────
BRANCH=$(git -C "$WORKDIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
REMOTE=$(git -C "$WORKDIR" remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE" ]; then
  PROJECT=$(echo "$REMOTE" | sed -E 's|.*[:/]([^/]+/[^/]+)(\.git)?$|\1|')
else
  PROJECT="_local/$(basename "$WORKDIR")"
fi
PROJECT="${PROJECT%.git}"

# ── Find latest session JSONL ───────────────────────────────
MATCH_DIR=$(find "$HOME/.omp/agent/sessions" -maxdepth 1 -type d -name "*$(basename "$WORKDIR")*" 2>/dev/null | head -1)
LATEST_JSONL=$(ls -t "$MATCH_DIR"/*.jsonl 2>/dev/null | head -1)
if [ -z "$LATEST_JSONL" ] || [ ! -f "$LATEST_JSONL" ]; then
  echo "[vault] No session JSONL found, skipping"
  exit 0
fi

# ── Extract session metadata ────────────────────────────────
SESSION_TITLE=$(python3 -c "
import json
with open('$LATEST_JSONL') as f:
    for line in f:
        d = json.loads(line)
        if d.get('type') == 'session':
            print(d.get('title',''))
            break
" 2>/dev/null)

FIRST_USER_MSG=$(python3 -c "
import json
with open('$LATEST_JSONL') as f:
    for line in f:
        d = json.loads(line)
        msg = d.get('message') or d
        if d.get('type') == 'message' and msg.get('role') == 'user':
            content = msg.get('content','')
            if isinstance(content, list):
                content = ' '.join(p.get('text','') for p in content if p.get('type')=='text')
            print(content[:500])
            break
" 2>/dev/null)

MSG_COUNT=$(python3 -c "
import json
with open('$LATEST_JSONL') as f:
    print(sum(1 for line in f if json.loads(line).get('type') == 'message'))
" 2>/dev/null)

# ── Summarize via DeepSeek ──────────────────────────────────
SUMMARY=""
CONVO=$(python3 -c "
import json
with open('$LATEST_JSONL') as f:
    lines = []
    for line in f:
        d = json.loads(line)
        msg = d.get('message') or d
        if d.get('type') == 'message':
            role = msg.get('role','?')
            content = msg.get('content','')
            if isinstance(content, list):
                content = ' '.join(p.get('text','') for p in content if p.get('type')=='text')
            lines.append(f'{role}: {content[:300]}')
    print('\n'.join(lines[-40:]))
" 2>/dev/null)

if [ -n "$CONVO" ]; then
  DS_KEY=$(sqlite3 "$HOME/.omp/agent/agent.db" \
    "SELECT json_extract(data, '$.key') FROM auth_credentials WHERE provider='deepseek' LIMIT 1;" 2>/dev/null || echo "")
  if [ -n "$DS_KEY" ]; then
    SUMMARY=$(python3 -c "
import json, sys
convo = sys.stdin.read()
payload = json.dumps({
    'model': 'deepseek-chat',
    'messages': [
        {'role': 'system', 'content': 'Summarize this coding session in 3-5 bullet points. Focus on: what was done, files changed, decisions made, issues fixed. Be concise.'},
        {'role': 'user', 'content': convo}
    ],
    'max_tokens': 300,
    'temperature': 0.3
})
print(payload)
" <<< "$CONVO" 2>/dev/null | curl -s https://api.deepseek.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DS_KEY" \
      -d @- 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d['choices'][0]['message']['content'])
except: pass
" 2>/dev/null)
  fi
fi

# ── Write vault note ────────────────────────────────────────
DIR="$PROJECTS/$PROJECT/$BRANCH"
FILE="$DIR/$(date +%Y-%m-%d-%H%M).md"
mkdir -p "$DIR"

{
  echo "---"
  echo "project: $PROJECT"
  echo "branch: $BRANCH"
  echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "tags: [$PROJECT, $BRANCH]"
  echo "---"
  echo ""
  echo "# $PROJECT — $BRANCH — $(date "+%Y-%m-%d %H:%M")"
  echo ""

  if [ -n "$SESSION_TITLE" ]; then
    echo "**Session:** $SESSION_TITLE"
    echo ""
  fi

  if [ -n "$FIRST_USER_MSG" ]; then
    echo "## Goal"
    echo ""
    echo "$FIRST_USER_MSG"
    echo ""
  fi

  if [ -n "$SUMMARY" ]; then
    echo "## Summary"
    echo ""
    echo "$SUMMARY"
    echo ""
  fi

  if [ -n "$MSG_COUNT" ]; then
    echo "*$MSG_COUNT messages — auto-summarized at $(date +%H:%M)*"
  fi
} > "$FILE"

echo "[vault] $FILE"
[ -n "$SESSION_TITLE" ] && echo "[vault]   $SESSION_TITLE"
[ -n "$SUMMARY" ] && echo "[vault]   summarized"
