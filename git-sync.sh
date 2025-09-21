#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./git-sync.sh "commit message"
# If you omit the message, a timestamped one is used.

# 1) Make sure we're inside a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not a git repo (run inside your project)"; exit 1;
}

# 2) Determine branch and remote
branch="$(git rev-parse --abbrev-ref HEAD)"
remote="origin"

# 3) Build commit message
msg="${1:-chore: sync $(date -u +'%Y-%m-%d %H:%M:%SZ')}"

# 4) Stage everything that isn't ignored
git add -A

# 5) If there’s nothing to commit, skip the commit step
if git diff --staged --quiet; then
  echo "Nothing to commit (working tree clean)."
else
  git commit -m "$msg"
fi

# 6) Ensure remote exists
git remote get-url "$remote" >/dev/null 2>&1 || {
  echo "Remote '$remote' not set. Add one like:"
  echo "  git remote add origin git@github.com:<you>/<repo>.git"
  exit 1
}

# 7) If no upstream is set, set it on first push
if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  echo "No upstream for '$branch'. Setting upstream on first push…"
  git push -u "$remote" "$branch"
  exit 0
fi

# 8) Rebase-pull to avoid merge commits, auto-stash local changes if any
git pull --rebase --autostash "$remote" "$branch"

# 9) Push
git push "$remote" "$branch"

echo "✅ Synced: $branch → $remote"
