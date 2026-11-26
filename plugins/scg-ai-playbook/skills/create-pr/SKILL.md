---
name: create-pr
description: GitHub の Pull Request を作成するとき、または差分と PR テンプレートからタイトルと本文の下書きを作成するときに使う。
compatibility: git リポジトリであること。PR 作成にはインターネット接続と gh CLI または GitHub MCP が必要。未コミット変更のコミットには同一プラグイン内の create-commit スキルを使う。
license: Apache-2.0
---

# GitHub Pull Request の作成

現在のブランチから GitHub の Pull Request（以下 PR）を作成する。

- PR 作成（Draft PR を含む）: 手順 1〜6 を実行する。
- タイトル・本文の作成のみ: ローカルの Git だけで手順 2〜5 を実行し、タイトルと本文を提示して終了する。

## 前提条件と共通ルール

- 利用ツール（PR 作成時）: `gh --version` が成功すれば gh CLI、失敗すれば GitHub MCP を使う。どちらも使えなければ停止する。
- gh CLI の認証（PR 作成時）: `gh auth status` で確認し、未認証ならユーザーに `gh auth login` を依頼する。完了後に `gh auth status` を再確認してから進む。
- ユーザー確認: 質問ツールが使える環境では質問ツール、使えない環境ではチャットで聞く。
- `<skill-dir>`: この `SKILL.md` のディレクトリを指す。
- fork 構成（作成元と作成先のリモートが異なる場合）: `<skill-dir>/references/fork-workflow.md` に従ってリモート指定と API 呼び出しを読み替える。

## 手順

### 1. ブランチと未コミット変更の準備（PR 作成時）

1. `git status --untracked-files=all` と `git branch --show-current` で状態を確認する。
2. 現在のブランチに応じて分岐する。
   - 空（detached HEAD）: コミット前に新規ブランチを作成する。
   - `main`、`release/*`、`epic/*`: 「新規ブランチを作成しますか？」と必ず確認し、不要ならそのまま進む。
3. 新規ブランチは変更内容から `create-branch` の規則（`feat/`、`fix/`、`release/`、`epic/`）で命名し、現在の `HEAD` から作成する。
   - ローカル（`git branch -a`）と `origin` に同名ブランチがなければ確認せず `git checkout -b <ブランチ名>` を実行する。
   - 重複すれば別名候補を提示し、承認を得た名前でのみ作成する。
4. 未コミット変更があれば `<skill-dir>/../create-commit/SKILL.md` に従ってコミットする（未導入なら導入または事前コミットを案内して停止）。分類後、次のいずれかに該当する場合は最初の `git add` の前に承認を得て、該当しなければ確認せずコミットする。
   - 2つ以上のグループに分かれた場合（各グループを示す）。
   - `secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` など機微情報のパスを含む場合（該当ファイルを示す）。

### 2. ベースブランチと関連情報の確認

1. ベースブランチが未指定なら、次を実行して候補を調べる。

   ```bash
   git branch -a
   bash <skill-dir>/scripts/estimate-base-branches.sh
   ```

   出力は有力な候補順である。実行できなければ `git branch -a` から判断する。

2. 未指定の項目をユーザーに確認する。
   - ベースブランチ: 上位候補を質問ツールで表示できる件数だけブランチ名のみで提示する（未コミット変更のみのときは既定ブランチも含め、詳細数値は内部判断に使う）。候補が定まらなければ既定ブランチ（不明なら `main`）を既定候補にする。推定結果だけで決め打ちしない。
   - チケット ID または関連リンク。

### 3. 差分と状態の検証

1. 比較対象の `<base-ref>` を決める。
   - PR 作成: 現在のブランチとベースが同じならブランチ作成かベース選択へ戻る。`git fetch origin <base-branch>` で実在確認と最新取得を行い、直後の `git rev-parse FETCH_HEAD` の SHA を `<base-ref>` に固定する。
   - タイトル・本文の作成のみ: `origin/<base-branch>` を優先し、なければローカルの `<base-branch>` を使う。

2. 状態と差分を確認する。

   ```bash
   git status --untracked-files=all
   git branch --show-current
   git log <base-ref>..HEAD --oneline
   git diff <base-ref>...HEAD --stat
   git remote get-url origin
   ```

3. 停止・確認条件を判定する。
   - `<base-ref>` の解決や `merge-base` 算出に失敗: 「差分なし」と誤認せずエラーを報告して停止する。
   - 未コミット変更あり: PR 作成時は手順 1 に戻る（不可なら停止）。タイトル・本文の作成のみなら含めるか確認し、含める場合は `git diff --merge-base <base-ref>` とルート基準の未追跡ファイル（`git ls-files --others --exclude-standard`）も読む。
   - 履歴または差分が空: 停止する（タイトル・本文の作成のみで未コミット変更を対象にする場合を除く）。
   - `origin` の URL が取れない: PR 作成時は停止する。
   - 開いている既存 PR（PR 作成時）: 次（または GitHub MCP）で照会する。

     ```bash
     gh pr list --head <branch> --state open --json url,baseRefName
     ```

     同ベースなら URL を示してコミット反映の可否を確認する（承認時は対象 SHA を確定して手順 4〜5 を省き、手順 6 の push と URL 共有のみ行う。拒否時は停止）。別ベースなら push でその PR も更新される旨を確認し、承認後に続行する。

4. 必要なら `git diff <base-ref>...HEAD` で差分本体を読む。

### 4. PR テンプレートの選択とタイトル・本文の作成

1. ルート基準で PR テンプレート（大文字小文字不問）を一覧する。PR 作成時は `origin` の既定ブランチ（`origin/HEAD` または `gh repo view --json defaultBranchRef` で特定し、ベースと異なれば fetch した SHA）を `<default-ref>` に指定する。コマンド失敗は「テンプレートなし」と誤認せず報告する。

   ```bash
   files=$(git -c core.quotePath=false ls-tree -r --full-tree --name-only <default-ref>) || exit 1
   printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   ```

   タイトル・本文の作成のみで `<default-ref>` がない場合は、1行目を `files=$(git -C "$(git rev-parse --show-toplevel)" -c core.quotePath=false ls-files --cached --others --exclude-standard) || exit 1` に置き換える。

2. 一覧と同じ参照から内容を読む（`<default-ref>` なら `git show <default-ref>:<path>`）。採用順は次のとおり。
   - ユーザー指定あり: 一致する1件（0件・複数一致なら候補を示して確認）。
   - 候補が1件: それを採用。
   - 複数候補: `PULL_REQUEST_TEMPLATE/` 外の単一テンプレートがあれば `.github/`、ルート、`docs/` の順で優先。ディレクトリ配下のみなら変更内容から1つに絞り、絞れなければ確認。
   - 候補なし: `<skill-dir>/references/default-pr-template.md`。

3. タイトルは Conventional Commits 形式（`type(scope): summary`。単一 `scope` に絞れなければ `type: summary`）で、目的または利用者から見た結果が一読で分かる短い文にする。

4. PR 本文を作成する。
   - 固有テンプレートの見出し、順序、HTML コメント、チェックリストは維持し、差分から判断できない項目だけ確認する。
   - 完成差分のレビュー要約として、「なぜ必要か」「何が変わるか」「どこに影響するか」を短い段落か数個の箇条書きでまとめる（必須で該当なしは「なし」）。
   - 処理フローや状態遷移が図で明確になる場合だけ `mermaid` を使う。
   - 書き終えたら不要な説明を削り、タイトルと本文だけで上の3点が伝わるか確認する。

### 5. 作成内容の確認

ベースブランチ、現在のブランチ、タイトル、本文を提示する（PR 作成時は対象コミット SHA も示す）。修正依頼があれば反映して再提示する。

- タイトル・本文の作成のみ: 提示して終了する。
- PR 作成: push と PR 作成の承認を得て手順 6 へ進む。

### 6. ブランチの push と PR 作成（PR 作成時）

1. `HEAD` 確認: `git rev-parse HEAD` が承認済み SHA と一致するか確認する（ずれていれば手順 5 へ戻る）。
2. push: リモートにブランチがないか承認済み SHA より古ければ、`git push origin <approved-sha>:refs/heads/<branch>` を実行する。リモートが先行・分岐している場合や失敗時は、強制 push せず停止する。
3. 追跡先設定: push 後、現在のブランチに追跡先が未設定なら `git branch --set-upstream-to=origin/<branch>` を設定する（既存設定は上書きしない）。
4. PR 作成: 手順 3 で既存 PR への反映を選んでいれば、リモートの SHA 一致を確認した時点で既存 PR の URL を共有して終了する。新規作成は次で実行する（Draft PR ならドラフト指定を付ける）。
   - gh CLI: タイトルは変数、本文は一時ファイルで渡し、実行後に一時ファイルを削除する。

     ```bash
     gh pr create --base <base-branch> --head <branch> --title "$title" --body-file <本文ファイル>
     ```

   - GitHub MCP: ベースブランチ、現在のブランチ、タイトル、本文を指定して作成する。
5. 失敗時はエラーを報告して停止し、成功したら PR の URL を共有する。
