---
name: create-pr
description: GitHub の Pull Request を作成するとき、または差分と PR テンプレートからタイトルと本文の下書きを作成するときに使う。
compatibility: git リポジトリであること。PR 作成にはインターネット接続と gh CLI または GitHub MCP が必要。未コミット変更をコミットする場合は同一プラグイン内の create-commit スキルを利用する。
license: Apache-2.0
---

# GitHub Pull Request の作成

現在のブランチから GitHub の Pull Request（以下 PR）を作成する。

- PR の新規作成（Draft PR を含む）: 手順 1〜6 を実行する。
- 下書き作成のみ: ローカルの Git だけで完結し、手順 2〜5 で提示して終了する（GitHub 認証、ブランチ作成、コミット、push、PR 作成は行わない）。

## 前提条件と共通ルール

- 利用ツール（PR 作成時）: `gh --version` が通れば `gh CLI`、通らなければ `GitHub MCP` を使う。どちらも使えなければ停止する。
- `gh CLI` の認証（PR 作成時）: 事前に `gh auth status` で認証を確認する。未認証なら `gh auth login` の実行をユーザーに依頼し、完了後に `gh auth status` を再確認してから進む。
- ユーザー確認: 質問ツールが使える環境では質問ツール、使えない環境ではチャットで聞く。
- `<skill-dir>`: この `SKILL.md` があるディレクトリを指す。

## 手順

### 1. ブランチと未コミット変更の準備（PR 作成時）

1. `git status --untracked-files=all` と `git branch --show-current` で状態を確認する。
2. 現在のブランチに応じて分岐する（新規ブランチは現在の `HEAD` から作成する）。
   - ブランチ名が空（detached HEAD）: コミット前に新規ブランチを作成する。
   - `main`、`release/*`、`epic/*` のいずれか: 「新規ブランチを作成しますか？」と必ず確認する。不要ならそのまま進む。
   - 新規ブランチの作り方: 変更内容から `create-branch` と同じプレフィックス規則（`feat/`、`fix/`、`release/`、`epic/`）で名前を決める。ローカル（`git branch -a`）と push 先リモートに同名ブランチがなければ確認せず `git checkout -b <ブランチ名>` を実行する。重複する場合は別名候補を提示し、承認を得た名前でのみ作成する。
3. 未コミットの変更がある場合は、`create-commit` スキル（`<skill-dir>/../create-commit/SKILL.md`）に従ってコミットする。スキルが見つからなければ導入または事前コミットを案内して停止する。`create-commit` の自動実行より次の確認条件を優先し、分類後・最初の `git add` 前に承認を得る。
   - 変更が2つ以上のグループに分かれた場合（各グループを示す）。
   - `secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` など機微情報とみなせるパスが含まれる場合（該当ファイルを示す）。
   - どちらにも該当しなければ確認せずコミットする。

### 2. ベースブランチと関連情報の確認

1. ベースブランチが未指定なら、次を実行して候補を調べる（マージ先リモートが `origin` 以外なら引数にリモート名を渡す）。明示済みなら省略してよい。

   ```bash
   git branch -a
   bash <skill-dir>/scripts/estimate-base-branches.sh [target-remote]
   ```

   スクリプトは指定リモートの新しい最大100ブランチから、`ahead > 0` を優先して共通祖先が新しい順に最大10件を出力する。実行できなければ `git branch -a` から判断する。

2. 未指定の項目をユーザーに確認する。
   - ベースブランチ（PR のマージ先）: `ahead > 0` の上位候補を優先し（未コミット変更のみの下書きでは既定ブランチも含める）、質問ツールで表示できる件数だけブランチ名のみで提示する（詳細数値は内部判断に使う）。有力な候補がなければ既定ブランチ（不明なら `main`）を既定候補にする。推定結果だけで決め打ちしない。
   - チケット ID または関連リンク。

### 3. 差分とコミット履歴の確認

1. 比較対象の参照 `<base-ref>` を決める。
   - PR 作成時: 作成先リモート（通常 `origin`、fork なら `upstream` など）でベースブランチの実在を確認し、`git fetch <target-remote> <base-branch>` の `FETCH_HEAD` を `<base-ref>` とする。作成元とマージ先が同一リポジトリ上の同じブランチなら進まず、ブランチ作成またはベース選択へ戻る。
   - 下書き作成のみ: 手元のマージ先リモート参照を優先し、なければローカルの `<base-branch>` を使う。

2. 以下を実行して状態を確認する。

   ```bash
   git status
   git branch --show-current
   git log <base-ref>..HEAD --oneline
   git diff <base-ref>...HEAD --stat
   git remote get-url <target-remote>
   ```

3. 停止・対処条件を確認する。
   - `<base-ref>` の解決や `merge-base` 算出に失敗した: 「差分なし」と誤認せずエラーを報告して停止する。
   - 未コミットの変更が残っている: PR 作成時は手順 1 に戻ってコミットする（不可なら停止）。下書き作成のみなら、本文へ含めるかユーザーに確認する。
   - コミット履歴または差分が空: 停止する（下書き作成のみで未コミット変更を対象にする場合を除く）。
   - 作成先リモートの URL が取得できない: PR 作成時は停止する。

4. 内容や影響範囲の把握に差分本体が必要なら `git diff <base-ref>...HEAD` を確認する。下書き作成のみで未コミット変更を含める場合は、`git diff --merge-base <base-ref>` と未追跡ファイル（ルート基準の `git ls-files --others --exclude-standard`）の内容も必ず確認する。

### 4. PR テンプレートの選択とタイトル・本文の作成

1. リポジトリルート基準でファイル一覧 `files` を取得し、GitHub が認識する PR テンプレート（大文字小文字不問）を抽出する。参照取得や Git コマンド自体が失敗した場合は「テンプレートなし」と誤認せず報告する。
   - 既定ブランチ参照がある場合（PR 作成時は作成先リポジトリの既定ブランチ参照を使う）: `git -c core.quotePath=false ls-tree -r --full-tree --name-only <default-branch-ref>` で取得する。
   - 既定ブランチ参照がない場合: `git -C "$(git rev-parse --show-toplevel)" -c core.quotePath=false ls-files` で取得する。

   ```bash
   printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   ```

2. 次の優先順でテンプレートを決め、列挙した参照と同じ場所から本文を読む。
   - ユーザー指定がある場合は一致する1件を採用する（0件または複数一致なら候補を示して確認）。
   - 候補が1件だけならそれを採用する。
   - 複数ある場合、単一テンプレート（`PULL_REQUEST_TEMPLATE/` 外）があれば `.github/`、ルート、`docs/` の順で優先する。ディレクトリ配下の候補だけなら変更内容から1つに絞り、絞れなければ候補を示して確認する。
   - 見つからなければ `<skill-dir>/references/default-pr-template.md` を使う。

3. タイトルは Conventional Commits 形式（`type(scope): summary`。単一 `scope` に絞れなければ `type: summary`）で、変更の目的または利用者から見た結果が一読で分かる短い文にする。

4. 本文を作成する。
   - リポジトリ固有のテンプレートを使う場合は見出し、順序、HTML コメント、チェックリストを維持し、自動推測できない項目だけを追加確認する。
   - 完成した差分に対するレビュー要約として書き、初見のレビュー担当者が「なぜ必要か」「何が変わるか」「どこに影響するか」を短時間で判断できる内容にする。
   - 各項目は短い段落または数個の箇条書きにまとめ、必須で該当がない項目は「なし」とする。
   - 処理フローや状態遷移が文章より図で明確になる場合だけ `mermaid` を使う。
   - 書き終えたら不要な説明を削り、タイトルと本文だけで上の3点が伝わるか確認する。

### 5. 作成内容の確認

ベースブランチ、現在のブランチ、タイトル、本文を提示する（PR 作成時は作成先リポジトリ、push 先ブランチ、対象コミット SHA も示す）。

- 下書き作成のみ: 提示して終了する（修正依頼があれば反映して再提示）。
- PR 作成: push と PR 作成の承認を得る（修正依頼があれば反映して再提示し、承認後に手順 6 へ進む）。

### 6. ブランチの push と PR 作成（PR 作成時）

1. push 前に、作成先リポジトリで同じ作成元リポジトリ・ブランチから開いている PR がないか照会する（`gh CLI` なら `gh api --method GET repos/<owner>/<repo>/pulls -f state=open -f head="<head-owner>:<branch>"` で応答の `head.repo.full_name` を照合）。1件以上あれば push せず全件の URL とベースブランチを示し、既存 PR にコミットを反映してよいか確認する（反映しないなら停止）。

2. 現在の `HEAD` が手順 5 で承認した SHA と一致することを確認する（ずれていれば手順 5 に戻る）。リモートにブランチがないか承認済み SHA より古ければ、`git push <head-remote> <approved-sha>:refs/heads/<branch>` を実行する。リモートが先行・分岐している場合や push 失敗時は、強制 push せず停止して報告する。既存 PR への反映が選択済みなら、リモートの SHA 一致を確認した時点で既存 PR の URL を共有して終了する。

3. 新規 PR を作成する。タイトルはシェル展開・引用崩れが起きない形で渡し、本文は一時ファイル経由などでそのまま渡す（Draft PR ならドラフト指定を付ける）。
   - `gh CLI`: `--repo`、`--base`、`--head`、`--title "$title"`、`--body-file <本文ファイル>` を指定して `gh pr create` を実行する（組織所有 fork など `--head` 非対応の環境では `gh api repos/<owner>/<repo>/pulls` で作成し、同一組織の別リポジトリなら `head_repo` も指定する）。実行後に一時ファイルを削除する。
   - `GitHub MCP`: 確認済みの作成先リポジトリ、ベースブランチ、作成元ブランチ、タイトル、本文を指定して作成する。

4. 失敗時はエラーを報告して停止する。成功したら PR の URL を共有する。
