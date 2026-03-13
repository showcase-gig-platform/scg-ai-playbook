#!/usr/bin/env bash
set -euo pipefail

current_branch=$(git branch --show-current 2>/dev/null || true)
max_candidates=${ESTIMATE_BASE_BRANCHES_MAX_CANDIDATES:-100}

git for-each-ref --sort=-committerdate --count="$max_candidates" --format='%(refname) %(refname:short)' refs/remotes/origin |
	while IFS=' ' read -r full_ref ref; do
		[ -n "$ref" ] || continue
		[ "$full_ref" = "refs/remotes/origin/HEAD" ] && continue

		branch=${ref#origin/}
		[ -n "$branch" ] || continue
		[ "$branch" = "$current_branch" ] && continue

		merge_base=$(git merge-base HEAD "$ref" 2>/dev/null) || continue
		[ -n "$merge_base" ] || continue

		base_date=$(git show -s --format='%ci' "$merge_base" 2>/dev/null) || continue
		ahead=$(git rev-list --count "$merge_base..HEAD" 2>/dev/null) || continue
		behind=$(git rev-list --count "$merge_base..$ref" 2>/dev/null) || continue

		printf '%s | ahead=%s | behind=%s | %s\n' "$base_date" "$ahead" "$behind" "$branch"
	done |
	sort -r |
	awk 'NR <= 10 { print }'
