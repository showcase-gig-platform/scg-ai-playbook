---
name: create-pr
description: プロジェクトのPRテンプレートに従ってGitHub Pull Requestを作成する。git差分・コミット履歴からPR本文を生成し、PRを作成する必要があるときに使用する。
compatibility: Requires gh CLI or GitHub MCP, git, and access to the internet. The target directory must be a git repository.
license: Apache-2.0
---

# Create a GitHub Pull Request

## Step 1: 必須確認

- ベースブランチを確認する。指定がなければ `main` を既定値として扱う。
- チケットIDまたは関連リンクを確認する。

## Step 2: 実行前チェックと分岐

以下を実行して状態を確認する。

```bash
gh --version
gh auth status
git status
git branch --show-current
git log <base-branch>..HEAD --oneline
git diff <base-branch> --stat
git remote get-url origin
```

- `gh --version` と `gh auth status` が成功したら `gh` CLI を使う。
- `gh` が使えない、または未認証でも GitHub MCP が使えるなら MCP に切り替える。
- `gh` と GitHub MCP の両方が使えなければ停止する。
- 未コミットの変更があれば停止する。
- `git log <base-branch>..HEAD --oneline` が空なら停止する。
- `git diff <base-branch> --stat` が空なら停止する。
- `origin` が取得できなければ停止する。
- ブランチが未 push なら `git push -u origin <branch>` を実行し、失敗したら停止する。

## Step 3: テンプレート選択と本文生成

以下の優先順でテンプレートを探す。

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `references/default-pr-template.md`

- 見つかったテンプレートの見出し、順序、HTMLコメント、チェックリストを維持する。
- リポジトリ固有テンプレートがあれば常に優先する。
- リポジトリ固有テンプレートがなければ `references/default-pr-template.md` を使う。
- テンプレート項目のうち自動推測できないものだけを追加確認する。
- PRタイトルはブランチ名を優先し、不適切ならコミットの要約を用いる。
- 本文はテンプレートの各項目を実際の差分とコミット履歴に基づいて埋める。項目名や粒度はテンプレートに合わせる。
- 影響範囲は `git diff <base-branch> --stat` をもとに整理する。

## Step 4: プレビュー

- タイトルと本文をユーザーに提示する。
- 修正依頼があれば反映してから作成に進む。

## Step 5: PR作成

- push 済みかつ差分とコミットがある状態でのみ次に進む。
- `gh` CLI を使う場合は `gh pr create` を実行する。
- `gh` が使えない場合は GitHub MCP の PR 作成機能を使う。
- 作成後にPRのURLを共有する。
