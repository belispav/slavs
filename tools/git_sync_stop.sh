#!/bin/bash
# Slavs - runs when Claude is about to finish (Stop hook in .claude/settings.json).
# Blocks ONCE if work is uncommitted or unpushed, so the PC and GitHub never drift apart.
input=$(cat)
echo "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0
dirty=$(git status --porcelain | head -1)
upstream=$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null)
ahead=0
[ -n "$upstream" ] && ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
if [ -n "$dirty" ] || [ "$ahead" != "0" ]; then
  echo "Slavs: there is uncommitted or unpushed work. Commit it and push it to GitHub (master on the PC; the designated branch in a cloud session) before finishing, so every session starts from the same state." >&2
  exit 2
fi
exit 0
