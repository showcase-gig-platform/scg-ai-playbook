---
name: create-pr
description: GitHub Pull Request を作成するときに使う。ユーザーが PR を作りたい、PR本文やタイトルのドラフトを差分から作りたい、既存の PR テンプレートに沿って内容を埋めたいと言ったときに適用する。実行時に新規ブランチや add/commit が必要な場合もこのスキル内で行う。カレントが main または release/* または epic/* のときは、新規ブランチを作る必要があるか必ずユーザーに聞く。それ以外は普段は質問せず、必要ならブランチ作成・コミット・プッシュしてから PR を作成する。ベースブランチは origin のリモートブランチから候補を推定してユーザー確認を取る。
compatibility: Requires gh CLI or GitHub MCP, git, and access to the internet. The target directory must be a git repository. コミットメッセージ生成には create-commit スキル（同一プラグイン内 skills/create-commit）を利用する。
license: Apache-2.0
---

# Create a GitHub Pull Request

## 前提条件

- GitHub CLI か GitHub MCP が使えること。
- `gh --version` が成功したら GitHub CLI を使い、使えない場合は GitHub MCP を使用する。両方使えなければ停止する。
- GitHub CLIを使う場合、認証されていることを確認するために `gh auth status` を実行する。認証されていない場合はそのまま続行せず、ユーザーに `gh auth login` を実行するように依頼する。（そして `gh auth status` を再実行する）
- この skill 内で示す相対パスは `SKILL.md` がある skill ディレクトリ基準で解決する。

## ワークフロー

### 0. 事前準備（ブランチ・コミット）

PR 作成前に、必要なら新規ブランチの作成と未コミット変更のコミットを行う。

1. **状態確認**

   ```bash
   git status
   git branch --show-current
   ```

2. **main / release/* / epic/* にいる場合**

   カレントブランチが `main` または `release/*` または `epic/*` のときは、**必ず**ユーザーに「新規ブランチを作成しますか？」と聞く。ユーザーへの質問ツールが使える場合は必ずそれを使う。

   - **Yes** の場合: 変更内容（`git diff` / `git diff --cached`）から create-branch と同様のプレフィックス規則（feat/fix/release/epic）でブランチ名を提案し、**確認は取らずその名前を採用**して `git checkout -b <ブランチ名>` を実行する。既存ブランチと同名の場合は別名を自動で決めて作成する。
   - **No** の場合: そのまま次へ（main/release/epic から直接 PR する想定）。

3. **未コミットの変更がある場合**

   普段は質問せず、**create-commit スキル**（`plugins/scg-ai-playbook/skills/create-commit`）のワークフローに従ってコミットする。

   - create-commit の手順: `git status` / `git diff` / `git diff --cached` で変更を把握 → 変更を意味的なグループに分類（複数目的が混在する場合は複数コミットに分ける）→ グループごとにステージ・what/why を含むコミットメッセージ生成・`git commit` を実行。単一の目的の変更のみの場合は一括で `git add -A` のうえ 1 コミット。
   - コミットメッセージは create-commit のフォーマット（prefix: 概要、why:、what:）に従う。ユーザーにコミットメッセージの確認を取る必要はない（依頼があれば確認する）。

4. 以上のあと、ステップ 1 に進む。

---

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

- 未コミットの変更が残っていれば、ステップ 0 に戻るか停止する（通常はステップ 0 でコミット済み）。
- `git log <base-branch>..HEAD --oneline` が空なら停止する。
- `git diff <base-branch> --stat` が空なら停止する。
- `origin` が取得できなければ停止する。
- ブランチが未 push なら `git push -u origin <branch>` を実行し、失敗したら停止する。

### 3. PRテンプレート選択と本文生成

GitHub のサポート対象に合わせて、次の手順でPR本文のテンプレートを選び、本文を生成する。

1. 以下のコマンドを実行してリポジトリ内のPRテンプレートファイルを一覧する。

   ```bash
   git ls-files --cached --others --exclude-standard | rg -i '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   ```

2. テンプレートを選ぶ。
   - リポジトリ固有のテンプレートが見つかったらそれを採用する。
   - 複数テンプレート用ディレクトリしか見つからない場合は、ユーザー指定のテンプレート名を優先する。
   - 複数のテンプレート候補があり、ユーザー指定も推測材料もない場合は、候補一覧を示して選択を確認してから進める。
   - リポジトリ固有のテンプレートが見つからなければ `references/default-pr-template.md` を使う。
3. 本文を生成する。
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

- **ステップ 0** を常に最初に実行する。新規ブランチが必要な場合・未コミットの変更がある場合もここで対応する。main / release/* / epic/* のときだけ「新規ブランチを作成しますか？」と必ず聞く。それ以外のブランチでは質問せず、未コミットがあればそのまま add/commit する。
- ユーザーへの確認が必要な時、ユーザーに質問をするためのツール（AskQuestion/AskUserQuestionなど）が使える場合は優先して使用する。ユーザーに質問をするためのツールが利用できない場合はチャットで質問する。
- `<skill-dir>/scripts/estimate-base-branches.sh` の出力は新しい共通祖先日時順の候補一覧として扱い、上位数件だけを要約して見せる。
- 推定スクリプトは `committerdate` が新しいリモートブランチから順に確認する想定で、必要なら `ESTIMATE_BASE_BRANCHES_MAX_CANDIDATES` で確認件数を調整してよい。
