#!/usr/bin/env bash
set -euo pipefail

current_branch=$(git branch --show-current 2>/dev/null || true)
target_remote=${1:-${ESTIMATE_BASE_BRANCHES_REMOTE:-origin}}
max_candidates=${ESTIMATE_BASE_BRANCHES_MAX_CANDIDATES:-100}

git for-each-ref --sort=-committerdate --count="$max_candidates" --format='%(refname) %(refname:short)' "refs/remotes/$target_remote" |
	while IFS=' ' read -r full_ref ref; do
		[ -n "$ref" ] || continue
		[ "$full_ref" = "refs/remotes/$target_remote/HEAD" ] && continue

		branch=${ref#"$target_remote"/}
		[ -n "$branch" ] || continue
		[ "$branch" = "$current_branch" ] && continue

		merge_base=$(git merge-base HEAD "$ref" 2>/dev/null) || continue
		[ -n "$merge_base" ] || continue

		base_info=$(git show -s --format='%ct	%ci' "$merge_base" 2>/dev/null) || continue
		base_ts=${base_info%%	*}
		base_date=${base_info#*	}
		ahead=$(git rev-list --count "$merge_base..HEAD" 2>/dev/null) || continue
		behind=$(git rev-list --count "$merge_base..$ref" 2>/dev/null) || continue

		has_ahead=0
		[ "$ahead" -gt 0 ] && has_ahead=1

		printf '%s\t%s\t%s | ahead=%s | behind=%s | %s\n' "$has_ahead" "$base_ts" "$base_date" "$ahead" "$behind" "$branch"
	done |
	LC_ALL=C sort -t'	' -k1,1nr -k2,2nr |
	cut -f3- |
	awk 'NR <= 10 { print }'
