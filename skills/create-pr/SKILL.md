---
name: create-pr
description: GitHub Pull Request を作成するときに使う。ユーザーが PR を作りたい、PR本文やタイトルのドラフトを差分から作りたい、既存の PR テンプレートに沿って内容を埋めたいと言ったときに適用する。ブランチ、コミット履歴、差分、リポジトリの PR テンプレートを確認して、レビューしやすいタイトルと本文を組み立ててから PR を作成する。ユーザーが単に「PR 作って」「PR本文を考えて」と依頼した場合でも、この作業が必要なら使う。
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

GitHub のサポート対象に合わせて、以下の順でテンプレートを探す。

1. 単一テンプレートを探す。
   - `pull_request_template.*`
   - `docs/pull_request_template.*`
   - `.github/pull_request_template.*`
2. 複数テンプレート用ディレクトリを探す。
   - `PULL_REQUEST_TEMPLATE/`
   - `docs/PULL_REQUEST_TEMPLATE/`
   - `.github/PULL_REQUEST_TEMPLATE/`
3. リポジトリ固有テンプレートが見つからなければ `references/default-pr-template.md` を使う。

- GitHub ではファイル名の大文字小文字を区別しない前提で探索する。
- 単一テンプレートが見つかったら、そのテンプレートを採用する。
- 複数テンプレート用ディレクトリしか見つからない場合は、ユーザーがテンプレート名を指定していればそれを優先する。
- 複数テンプレート候補があり、ユーザー指定も推測材料もない場合は、候補一覧を示して選択を確認してから進める。
- 選んだテンプレートの見出し、順序、HTMLコメント、チェックリストを維持する。
- リポジトリ固有テンプレートがあれば常に優先する。
- テンプレート項目のうち自動推測できないものだけを追加確認する。
- PRタイトルは Conventional Commits 形式の `type(scope): summary` で作り、`scope` を決められない場合は `type: summary` を使う。
- `type`、`scope`、`summary` は差分とコミット履歴から総合的に決定する。PR の範囲が広いなど、単一の `scope` に絞れない場合は `scope` を省略する。
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
