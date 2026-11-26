#!/usr/bin/env bash
set -euo pipefail

current_branch=$(git branch --show-current 2>/dev/null || true)
target_remote=${1:-origin}
max_candidates=${ESTIMATE_BASE_BRANCHES_MAX_CANDIDATES:-100}
dirty=$(git status --porcelain 2>/dev/null || true)

target_url=$(git remote get-url "$target_remote" 2>/dev/null) || {
	printf 'Remote not found: %s\n' "$target_remote" >&2
	exit 1
}

push_remote=""
if [ -n "$current_branch" ]; then
	push_remote=$(git config --get "branch.$current_branch.pushRemote" 2>/dev/null || true)
	[ -z "$push_remote" ] && push_remote=$(git config --get remote.pushDefault 2>/dev/null || true)
	[ -z "$push_remote" ] && push_remote=$(git config --get "branch.$current_branch.remote" 2>/dev/null || true)
fi
[ -z "$push_remote" ] && push_remote="origin"
push_url=$(git remote get-url "$push_remote" 2>/dev/null || true)

same_repo=0
if [ "$target_remote" = "$push_remote" ] || { [ -n "$push_url" ] && [ "$target_url" = "$push_url" ]; }; then
	same_repo=1
fi

git for-each-ref --sort=-committerdate --count="$max_candidates" --format='%(refname) %(refname:short)' "refs/remotes/$target_remote" |
	while IFS=' ' read -r full_ref ref; do
		[ -n "$ref" ] || continue
		[ "$full_ref" = "refs/remotes/$target_remote/HEAD" ] && continue

		branch=${ref#"$target_remote"/}
		[ -n "$branch" ] || continue
		[ "$same_repo" -eq 1 ] && [ "$branch" = "$current_branch" ] && continue

		merge_base=$(git merge-base HEAD "$ref" 2>/dev/null) || continue
		[ -n "$merge_base" ] || continue

		base_info=$(git show -s --format='%ct	%ci' "$merge_base" 2>/dev/null) || continue
		base_ts=${base_info%%	*}
		base_date=${base_info#*	}
		ahead=$(git rev-list --count "$merge_base..HEAD" 2>/dev/null) || continue
		behind=$(git rev-list --count "$merge_base..$ref" 2>/dev/null) || continue

		has_ahead=0
		{ [ "$ahead" -gt 0 ] || [ -n "$dirty" ]; } && has_ahead=1

		printf '%s\t%s\t%s\t%s | ahead=%s | behind=%s | %s\n' "$has_ahead" "$base_ts" "$behind" "$base_date" "$ahead" "$behind" "$branch"
	done |
	LC_ALL=C sort -t'	' -k1,1nr -k2,2nr -k3,3n |
	cut -f4- |
	awk 'NR <= 10 { print }'
