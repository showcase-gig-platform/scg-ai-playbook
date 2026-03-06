---
name: gh-pr-summary-update
description: Analyze the GitHub pull request for the current branch and update its title and structured summary with gh CLI. Use when the user asks to update a PR title, rewrite a PR summary, polish a pull request description, refresh review notes, align PR text with recent changes, or convert branch changes into a reviewer-friendly PR body.
compatibility: Requires gh CLI, GitHub authentication, and a git repository whose current branch already has a pull request.
license: Apache-2.0
---

# GitHub PR Summary Update

## Purpose

- Resolve the pull request for the current branch
- Analyze the PR title, body, files, commits, and diff when needed
- Rewrite the title in Conventional Commits style
- Rewrite the PR body into a reviewer-friendly structured summary
- Update the PR safely with `gh pr edit`

## When To Use

Use this skill when the user asks for any of the following:

- Update or rewrite a GitHub PR title
- Refresh a PR summary after code changes
- Improve a pull request description for reviewers
- Rewrite a PR body in a standard template
- Convert recent branch changes into a structured PR summary

## Preconditions

Before doing any PR update work, confirm these conditions:

- `gh` CLI is installed and authenticated
- The current working directory is a git repository connected to GitHub
- The current branch already has an open pull request
- The agent has permission to edit that pull request

If any precondition fails, stop and explain the blocker instead of guessing.

## Required Workflow

1. Resolve the current branch PR with `gh pr view --json number`.
2. If no PR is found, stop immediately and tell the user that there is no PR for the current branch.
3. Read the existing PR metadata with `gh pr view <number> --json title,body,files`.
4. Read commit history with `gh pr view <number> --json commits`.
5. Read `gh pr diff <number>` only if the title, files, and commits are not enough to infer the change accurately.
6. Infer the following before writing:
   - the primary change
   - why the change exists
   - impact scope
   - the most important review points
7. Draft a Conventional Commits style title in Japanese.
8. Draft the PR body with the template in this skill.
9. If related issue numbers, test results, or reviewer focus points are unclear, ask the user or leave an explicit placeholder instead of inventing details.
10. Update the PR using `gh pr edit`.
11. Verify the final result with `gh pr view <number>`.

## Title Rules

- Format: `<type>: <summary>`
- Use one of: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`
- Prefer Japanese for the summary
- Keep it concise and centered on the most important change
- If multiple unrelated changes exist, title the PR around the highest-impact change rather than listing everything

## PR Body Rules

- Write for reviewers, not as an internal implementation memo
- Prefer concrete wording over vague summaries
- Do not claim tests passed unless you have evidence
- Do not invent issue numbers, review concerns, or external dependency changes
- Keep the summary aligned with the actual diff, not only the latest commit message

## PR Body Template

Use this structure:

```markdown
## 概要
<!-- 2-3文で変更内容の全体像を説明 -->

## 変更意図
- **[観点1]**: 説明
- **[観点2]**: 説明

## 主な変更点
### 1. [カテゴリ1]
- 変更内容の詳細
- 実装上の要点

### 2. [カテゴリ2]
- 変更内容の詳細
- 実装上の要点

## 影響範囲
- **[機能/モジュール名]**: 影響内容

## 関連Issue
closes #<issue番号 or TODO>

## セルフレビュー
- [x] セルフレビューを実行した
- [ ] 補足のレビュー項目があれば記載

## テスト結果
- [ ] 実施したテストを記載
- [ ] 未実施なら理由を記載

## レビュー観点
- [重要な観点1]
- [重要な観点2]

## 備考
<!-- 補足があれば記載 -->
```

## Update Method

When updating the body, use a multiline-safe method such as a heredoc. This avoids broken formatting and shell escaping issues in large PR summaries.

## Failure Conditions

Stop and report clearly when:

- the current branch has no pull request
- `gh` is not authenticated
- the repository is not linked to GitHub
- pull request edit permissions are missing
- the change is too ambiguous to summarize without user clarification

## Example Requests

**Example 1**

Input:
`現在のブランチの PR タイトルと本文を最新差分に合わせて更新して`

Expected behavior:
- inspect the current branch PR
- analyze files and commits
- update the title and body

**Example 2**

Input:
`PR summary をレビューしやすい形に整えて`

Expected behavior:
- keep the summary reviewer-oriented
- preserve unknown facts as placeholders or ask follow-up questions

**Example 3**

Input:
`PR タイトルを conventional commits 形式にして、本文も書き直して`

Expected behavior:
- choose the best title type
- rewrite the body using the structured template
