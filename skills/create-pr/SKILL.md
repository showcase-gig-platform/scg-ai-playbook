---
name: create-pr
description: GitHub Pull Request を作成するときに使う。ユーザーが PR を作りたい、PR本文やタイトルのドラフトを差分から作りたい、既存の PR テンプレートに沿って内容を埋めたいと言ったときに適用する。ブランチ、コミット履歴、差分、リポジトリの PR テンプレートを確認して、レビューしやすいタイトルと本文を組み立ててから PR を作成する。ベースブランチは origin のリモートブランチから候補を推定してユーザー確認を取る。ユーザーが単に「PR 作って」「PR本文を考えて」と依頼した場合でも、この作業が必要なら使う。
compatibility: Requires gh CLI or GitHub MCP, git, and access to the internet. The target directory must be a git repository.
license: Apache-2.0
---

# Create a GitHub Pull Request

## 前提条件

- GitHub CLI か GitHub MCP が使えること。
- `gh --version` が成功したら GitHub CLI を使い、使えない場合は GitHub MCP を使用する。両方使えなければ停止する。
- GitHub CLIを使う場合、認証されていることを確認するために `gh auth status` を実行する。認証されていない場合はそのまま続行せず、ユーザーに `gh auth login` を実行するように依頼する。（そして `gh auth status` を再実行する）
- この skill 内で示す相対パスは `SKILL.md` がある skill ディレクトリ基準で解決する。

## ワークフロー

### 1. ユーザーへの確認

作業開始時はカレントブランチとベースブランチ候補を確認し、必要事項をユーザーに確認する。ユーザーへの質問ツールが使える場合は必ずそれを使う。

- 以下をこの順で実行する。

```bash
git branch --show-current
git branch -a
bash <skill-dir>/scripts/estimate-base-branches.sh
```

- `<skill-dir>/scripts/estimate-base-branches.sh` が存在する場合は必ず実行し、出力された上位候補をベースブランチ確認の材料にする。
- 推定結果は参考情報として扱い、ベースブランチはユーザーに最終確認する。

- ベースブランチ: PRのマージ先ブランチ
  - 上位候補を優先して提示する。
  - 候補が弱い場合だけ `main` を既定候補として提示する。必要なら `git branch -a` や推定結果の詳細は内部判断に使う。
  - 候補が得られた場合は、表示可能な件数の範囲で上位候補をブランチ名だけ見せる。
- チケットIDまたは関連リンク

### 2. Gitの状態を確認

以下を実行して状態を確認する。

```bash
git status
git branch --show-current
git log <base-branch>..HEAD --oneline
git diff <base-branch> --stat
git remote get-url origin
```

- 未コミットの変更があれば停止する。
- `git log <base-branch>..HEAD --oneline` が空なら停止する。
- `git diff <base-branch> --stat` が空なら停止する。
- `origin` が取得できなければ停止する。
- ブランチが未 push なら `git push -u origin <branch>` を実行し、失敗したら停止する。

### 3. テンプレート選択と本文生成

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

- GitHub ではファイル名の大文字小文字を区別しない前提で探索し、リポジトリ固有テンプレートが見つかったらそれを採用する。
- 複数テンプレート用ディレクトリしか見つからない場合は、ユーザー指定のテンプレート名を優先する。
- 複数テンプレート候補があり、ユーザー指定も推測材料もない場合は、候補一覧を示して選択を確認してから進める。
- 選んだテンプレートの見出し、順序、HTMLコメント、チェックリストを維持する。
- テンプレート項目のうち自動推測できないものだけを追加確認する。
- PRタイトルは Conventional Commits 形式で作り、`type`、`scope`、`summary` は差分とコミット履歴から総合的に決定する。単一の `scope` に絞れない場合は `type: summary` を使う。
- 本文はテンプレートの各項目を実際の差分とコミット履歴に基づいて埋め、影響範囲は `git diff <base-branch> --stat` をもとに整理する。

### 4. プレビュー

- タイトルと本文をユーザーに提示する。
- 修正依頼があれば反映してから作成に進む。

### 5. PR作成

- push 済みかつ差分とコミットがある状態でのみ次に進む。
- `gh` CLI を使う場合は `gh pr create` を実行する。
- `gh` が使えない場合は GitHub MCP の PR 作成機能を使う。
- 作成後にPRのURLを共有する。

## 作業時のルール

- ユーザーへの確認が必要な時、ユーザーに質問をするためのツール（AskQuestion/AskUserQuestionなど）が使える場合は優先して使用する。ユーザーに質問をするためのツールが利用できない場合はチャットで質問する。
- `<skill-dir>/scripts/estimate-base-branches.sh` の出力は新しい共通祖先日時順の候補一覧として扱い、上位数件だけを要約して見せる。
- 推定スクリプトは `committerdate` が新しいリモートブランチから順に確認する想定で、必要なら `ESTIMATE_BASE_BRANCHES_MAX_CANDIDATES` で確認件数を調整してよい。
