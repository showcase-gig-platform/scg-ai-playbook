---
name: create-pr
description: GitHub の Pull Request（Draft PR を含む）を作成するとき、または差分と PR テンプレートからタイトルと本文だけを作成するときに使う。「PR を作って」「PR 本文を作って」といった依頼に適用する。
compatibility: git リポジトリであること。PR 作成にはインターネット接続と gh CLI または GitHub MCP が必要。新規ブランチ命名には create-branch スキル、未コミット変更のコミットには create-commit スキル（いずれも同一プラグイン内）を使う。
license: Apache-2.0
---

# GitHub Pull Request の作成

現在のブランチから GitHub の Pull Request（以下 PR）を作成する。

- PR 作成（Draft PR を含む）: 手順 1〜6 を実行する。
- タイトル・本文のみ: ローカルの Git だけで手順 2〜5 を実行し、タイトルと本文を提示して終了する。

## 前提条件と共通ルール

- 利用ツール（PR 作成時）: `gh --version` が成功すれば gh CLI、失敗すれば GitHub MCP を使う。どちらも使えなければ停止する。
- gh CLI の認証（PR 作成時）: `gh auth status` で確認し、未認証ならユーザーに `gh auth login` を依頼する。完了後に `gh auth status` を再確認してから進む。
- ユーザー確認: 質問ツールが使える環境では質問ツール、使えない環境ではチャットで聞く。
- `<skill-dir>`: この `SKILL.md` のディレクトリを指す。
- fork 構成（PR 作成時）: ユーザーが別リポジトリを作成先に指定した場合は、`<skill-dir>/references/fork-workflow.md` に従って読み替える。gh CLI 利用時に `gh repo view --json nameWithOwner` が `origin` の `owner/repo` と一致しない場合も、作成先を確認してから進める。

## 手順

### 1. ブランチと未コミット変更の準備（PR 作成時）

1. `git status --untracked-files=all` と `git branch --show-current` で状態を確認する。
2. 現在のブランチに応じて分岐する。
   - 空（detached HEAD）: コミット前に新規ブランチを作成する。
   - `main`、`release/*`、`epic/*`: 「新規ブランチを作成しますか？」と必ず確認し、不要ならそのまま進む。
3. 新規ブランチは `<skill-dir>/../create-branch/SKILL.md` の命名規則に従って現在の `HEAD` から作成する（未導入なら導入を案内するか、変更内容に合う短い小文字ハイフン区切り名にする）。`create-branch` は名前の確認を必須とするが、このスキルでは同名ブランチがなければ確認を省く。
   - `git branch -a` と `git ls-remote --heads origin "refs/heads/<branch>"` で重複がなければ `git checkout -b <branch>` を実行する。
   - 重複すれば別名候補を提示し、承認を得た名前でのみ作成する。
4. 未コミット変更があれば `<skill-dir>/../create-commit/SKILL.md` に従ってコミットする（未導入なら導入または事前コミットを案内して停止する）。`create-commit` は確認なしで分割するが、このスキルでは次のいずれかに該当する場合に限り、分類後・最初の `git add` の前に承認を得る。該当しなければ確認せずコミットする。
   - 2つ以上のグループに分かれた場合（各グループを示す）。
   - `secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` など機微情報を示すパスを含む場合（該当ファイルを示す）。

### 2. ベースブランチと関連情報の確認

1. ベースブランチが未指定なら、次を実行して候補を調べる。

   ```bash
   git branch -a
   bash <skill-dir>/scripts/estimate-base-branches.sh
   ```

   出力は有力な候補順である。実行できなければ `git branch -a` から判断する。

2. 未指定の項目をユーザーに確認する。
   - ベースブランチ: 上位候補を質問ツールで表示できる件数だけブランチ名で提示し、詳細数値は内部判断に使う。タイトル・本文のみの経路では既定ブランチも常に候補に含める。候補が定まらなければ既定ブランチ（不明なら `main`）を候補にし、推定結果だけで決め打ちしない。
   - 関連情報: チケット ID または関連リンクの有無を確認する。

### 3. 差分と状態の検証

1. 作成先リポジトリ `<owner/repo>` と比較対象の `<base-ref>` を決める。
   - PR 作成の場合は次を順に実行する。
     - `git remote get-url origin` から `<owner/repo>` を確定し、取れなければ停止する。
     - 現在のブランチとベースブランチが同じなら、ユーザーに確認してブランチ作成かベースブランチ選択へ戻る。
     - `git fetch origin <base-branch>` で実在確認と最新取得を行い、直後の `git rev-parse FETCH_HEAD` の SHA を `<base-ref>` に固定する。
   - タイトル・本文のみ: `origin/<base-branch>` を優先し、なければローカルの `<base-branch>` を使う。

2. 状態と差分を確認する。

   ```bash
   git status --untracked-files=all
   git branch --show-current
   git log <base-ref>..HEAD --oneline
   git diff <base-ref>...HEAD --stat
   ```

3. 停止・確認条件を判定する。
   - `<base-ref>` の解決や `merge-base` 算出に失敗: 「差分なし」と誤認せずエラーを報告して停止する。
   - 未コミット変更あり: PR 作成時は手順 1 に戻る（コミットできなければ停止する）。タイトル・本文のみなら本文に含めるか確認し、含める場合は `git diff --merge-base <base-ref>` と未追跡ファイルも読む。
   - 履歴または差分が空: 停止する（タイトル・本文のみで未コミット変更を対象にする場合を除く）。
   - 開いている既存 PR（PR 作成時）: 次のコマンド（gh CLI がなければ GitHub MCP）で照会し、`isCrossRepository` が `false` の PR だけを対象にする。

     ```bash
     gh pr list --repo <owner/repo> --head <branch> --state open --json url,baseRefName,isCrossRepository
     ```

     - 同じベースブランチの PR がある場合: URL を示して既存 PR へ push してよいか確認する。承認されれば対象 SHA を確定して手順 4〜5 を省き、手順 6 の push と URL 共有のみ行う。拒否されれば停止する。
     - 別のベースブランチの PR がある場合: push でその PR も更新される旨を確認し、承認後に続行する。

4. 必要なら `git diff <base-ref>...HEAD` で差分本体を読む。

### 4. PR テンプレートの選択とタイトル・本文の作成

1. リポジトリルート基準で PR テンプレート（大文字小文字不問）を一覧する。コマンド失敗は「テンプレートなし」と誤認せず報告する。
   - PR 作成時: 既定ブランチ `<default-branch>`（`origin/HEAD` または `gh repo view <owner/repo> --json defaultBranchRef` で特定）がベースブランチと同じなら `<base-ref>`、異なれば `git fetch origin <default-branch>` 直後の `FETCH_HEAD` を `<default-ref>` にする。

     ```bash
     files=$(git -c core.quotePath=false ls-tree -r --full-tree --name-only <default-ref>) || exit 1
     printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
     ```

   - タイトル・本文のみ: 手元に `origin/HEAD` があれば上と同じコマンド（`<default-ref>` は `origin/HEAD`）を使う。なければ次で一覧する。

     ```bash
     files=$(git -C "$(git rev-parse --show-toplevel)" -c core.quotePath=false ls-files --cached --others --exclude-standard) || exit 1
     printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
     ```

2. 一覧と同じ参照から内容を読む（`<default-ref>` なら `git show <default-ref>:<path>`）。採用順は次のとおり。
   - ユーザー指定あり: 一致する1件を採用する。0件または複数一致なら候補を示して確認する。
   - 候補が1件: それを採用する。
   - 複数候補: `PULL_REQUEST_TEMPLATE/` 外の単一テンプレートがあれば `.github/`、ルート、`docs/` の順で優先する。ディレクトリ配下のみなら変更内容から1つに絞り、絞れなければ確認する。
   - 候補なし: `<skill-dir>/references/default-pr-template.md` を使う。

3. タイトルは Conventional Commits 形式（`type(scope): summary`。単一 `scope` に絞れなければ `type: summary`）で、目的または利用者から見た結果が一読で分かる短い文にする。

4. PR 本文を作成する。
   - 固有テンプレートの見出し、順序、HTML コメント、チェックリストは維持し、差分から判断できない項目だけ確認する。
   - 初めて見るレビュワー向けに、完成状態のレビュー要約として「なぜ必要か」「何が変わるか」「どこに影響するか」を短い段落か数個の箇条書きでまとめる。該当しない必須項目は「なし」とする。
   - 処理フローや状態遷移が図で明確になる場合だけ `mermaid` を使う。
   - 書き終えたら不要な説明を削り、タイトルと本文だけで上の3点が伝わるか確認する。

### 5. 作成内容の確認

作成先リポジトリ（PR 作成時）、ベースブランチ、現在のブランチ、対象コミット SHA（PR 作成時）、タイトル、本文を提示する。修正依頼があれば反映して再提示する。

- タイトル・本文のみ: 提示して終了する。
- PR 作成: push と PR 作成の承認を得て手順 6 へ進む。

### 6. ブランチの push と PR 作成（PR 作成時）

1. `HEAD` 確認: `git rev-parse HEAD` が承認済み SHA と一致するか確認する。ずれていれば手順 3 へ戻り、差分を再確認して再承認を得る（新規 PR なら本文も更新する）。
2. push: `git push origin <approved-sha>:refs/heads/<branch>` を実行する。拒否や失敗時は強制 push せず停止して報告する。
3. 追跡先設定: push 後、現在のブランチに追跡先が未設定なら `git branch --set-upstream-to=origin/<branch>` で設定する（既存設定は上書きしない。失敗しても PR 作成は続行する）。
4. PR 作成: 手順 3 で既存 PR への反映を選んでいれば、push が成功した時点で既存 PR の URL を共有して終了する。新規作成は次で実行する。
   - gh CLI: タイトルは変数、本文は一時ファイルで渡し、実行後に一時ファイルを削除する（Draft PR なら `--draft` を付ける）。

     ```bash
     gh pr create --repo <owner/repo> --base <base-branch> --head <branch> --title "$title" --body-file <body-file>
     ```

   - GitHub MCP: 作成先リポジトリ、ベースブランチ、現在のブランチ、タイトル、本文を指定して作成する（Draft PR ならドラフト指定を付ける）。
5. 結果共有: 失敗時はエラーを報告して停止し、成功したら PR の URL を共有する。
