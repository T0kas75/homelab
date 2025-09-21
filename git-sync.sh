#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./git-sync.sh -m "your message"
#   ./git-sync.sh         # auto message with timestamp

# go to repo root (no matter where you run it)
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repo." >&2
  exit 1
fi
cd "$repo_root"

# default commit message
msg="${1:-}"
if [[ "$msg" == "-m" ]]; then
  shift || true
  msg="${1:-}"
fi
if [[ -z "$msg" ]]; then
  msg="chore: sync $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
fi

# stage changes (including new/removed files)
git add -A

# nothing to commit?
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "$msg"
fi

# pick current branch
branch="$(git rev-parse --abbrev-ref HEAD)"

# make sure remote exists
remote="origin"
if ! git remote get-url "$remote" >/dev/null 2>&1; then
  echo "Remote 'origin' is missing. Add it with:"
  echo "  git remote add origin <url>"
  exit 1
fi

# push (set upstream automatically if needed)
if git rev-parse --symbolic-full-name --verify "refs/remotes/$remote/$branch" >/dev/null 2>&1; then
  git push "$remote" "$branch"
else
  git push -u "$remote" "$branch"
fi

