#!/bin/bash
# Slavs - runs at the start of every session (hook in .claude/settings.json).
# Brings a clean `master` checkout up to date so work never starts on stale files.
# Its output is shown to Claude, so a problem is reported instead of hidden.
echo "Slavs: at the start of any file-heavy or multi-step work invoke the token-saver skill (anthropic-skills:token-saver) - see CLAUDE.md, section Tokens."
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0
branch=$(git branch --show-current)
if ! git fetch -q origin 2>/dev/null; then
  echo "Slavs git: fetch failed (offline?) - could not check whether this copy is current."
  exit 0
fi
if [ "$branch" != "master" ]; then
  echo "Slavs git: on branch '$branch', not master - not pulling. master is the shared state."
  exit 0
fi
if [ -n "$(git status --porcelain)" ]; then
  echo "Slavs git: master has uncommitted local changes - not pulling. Commit or stash first."
  exit 0
fi
behind=$(git rev-list --count HEAD..origin/master 2>/dev/null || echo 0)
ahead=$(git rev-list --count origin/master..HEAD 2>/dev/null || echo 0)
if [ "$behind" != "0" ] && [ "$ahead" != "0" ]; then
  echo "Slavs git: master DIVERGED ($ahead local, $behind on GitHub). Do not work until this is resolved; tell Pavel."
elif [ "$behind" != "0" ]; then
  git pull -q --ff-only origin master && echo "Slavs git: pulled $behind new commit(s) from GitHub. Up to date."
elif [ "$ahead" != "0" ]; then
  echo "Slavs git: $ahead local commit(s) are not on GitHub yet - push them (git push origin master)."
else
  echo "Slavs git: master is up to date with GitHub."
fi
exit 0
