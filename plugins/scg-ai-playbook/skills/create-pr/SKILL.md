---
name: create-pr
description: GitHub Pull Request を作成するときに使う。PRの作成、差分からのタイトル・本文ドラフト、既存PRテンプレートの適用を依頼された場合に適用する。
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

   - **Yes** の場合: 変更内容（`git diff` / `git diff --cached`）から create-branch と同様のプレフィックス規則（feat/fix/release/epic）でブランチ名を提案する。**既存ブランチと重複しない場合**は確認を取らず `git checkout -b <ブランチ名>` を実行する。**重複する場合**は、別名候補（例: サフィックス付き）を決め、その候補をユーザーに提示し「この名前で作成してよいですか？」と必ず確認する。ユーザーが承認した場合のみ `git checkout -b <承認された名前>` を実行する。重複時に別名を確認なしで自動採用して checkout してはならない。
   - **No** の場合: そのまま次へ（main/release/epic から直接 PR する想定）。

3. **未コミットの変更がある場合**

   普段は質問せず、**create-commit スキル**（`plugins/scg-ai-playbook/skills/create-commit`）のワークフローに従ってコミットする。ただし、このPR作成フローでは次の安全確認を上書きする。

   - create-commit が変更を複数グループに分類した場合は、各グループを示してコミット前にユーザー確認を取る。
   - 変更パスが `secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` などの機微パターンに該当する場合は、対象を示してコミット前にユーザー確認を取る。

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

### 3. PRテンプレート確認と本文生成

GitHub のサポート対象に合わせてリポジトリ固有のPRテンプレートを確認し、本文を生成する。

1. 以下のコマンドを実行してリポジトリ内のPRテンプレートファイルを一覧する。

   ```bash
   git ls-files --cached --others --exclude-standard | rg -i '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   ```

2. 本文の形式を決める。
   - リポジトリ固有のテンプレートが見つかったらそれを採用する。
   - 複数テンプレート用ディレクトリしか見つからない場合は、ユーザー指定のテンプレート名を優先する。
   - 複数のテンプレート候補があり、ユーザー指定も推測材料もない場合は、候補一覧を示して選択を確認してから進める。
   - リポジトリ固有のテンプレートがなければ `references/default-pr-template.md` を使う。
3. 本文を生成する。
   - リポジトリ固有のテンプレートを使う場合は、見出し、順序、HTMLコメント、チェックリストを維持し、自動推測できない項目だけを追加確認する。
   - PR は**完成状態のレビュー要約**にする。完成した差分を初めて見るレビュワーが、変更の目的・結果・影響を短時間で判断できる内容にする。
   - PRタイトルは Conventional Commits 形式で、変更の目的または利用者から見た結果が一読で分かる短い文にする。`type`、`scope`、`summary` は差分とコミット履歴から決め、単一の `scope` に絞れない場合は `type: summary` を使う。
   - 各項目は短い段落または数個の箇条書きで、レビュー判断に必要な完成状態の情報だけを記載する。テンプレート上必須だが該当しない項目は「なし」とする。
   - ロジックや処理フローの変更が文章より図で明確になる場合だけ、GitHub が描画できる `mermaid` コードブロックを使う。
   - 生成後に削れる説明を削り、タイトルと本文だけで「なぜ必要か」「何が変わるか」「どこに影響するか」が把握できれば完了とする。

### 4. プレビュー

- タイトルと本文をユーザーに提示する。
- 修正依頼があれば反映してから作成に進む。

### 5. PR作成

- push 済みかつ差分とコミットがある状態でのみ次に進む。
- `gh` CLI を使う場合は `gh pr create` を実行する。
- `gh` が使えない場合は GitHub MCP の PR 作成機能を使う。
- 作成後にPRのURLを共有する。
