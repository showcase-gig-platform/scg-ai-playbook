---
name: create-pr
description: GitHub の Pull Request（Draft PR を含む）の作成、または差分と PR テンプレートからのタイトル・本文作成に使う。「PR を作って」「PR 本文を作って」といった依頼に適用する。
compatibility: git リポジトリであること。PR 作成には gh CLI または GitHub MCP が必要。同一プラグイン内の create-branch・create-commit スキルと連携する。
license: Apache-2.0
---

# GitHub Pull Request の作成

- PR 作成（Draft PR を含む）: 手順 1〜6 を実行する。
- タイトル・本文のみ: ローカルの Git だけで手順 2〜5 を実行し、タイトルと本文を提示して終了する。

## 共通ルール

- ツール（PR 作成時）: gh CLI を優先し（`gh --version` と `gh auth status` を確認。未認証なら `gh auth login` を依頼）、使えなければ GitHub MCP を使う。両方不可なら停止する。
- 確認手段: ユーザーへの確認は質問ツールを優先する。
- `<skill-dir>`: この `SKILL.md` があるディレクトリ。
- fork 構成（PR 作成時）: 別リポジトリが作成先、または gh CLI 利用時に `gh repo view --json nameWithOwner` が `origin` の `owner/repo` と一致しない場合は作成先を確認し、fork なら `<skill-dir>/references/fork-workflow.md` に従う。

## 手順

### 1. ブランチとコミットの準備（PR 作成時）

1. `git status --untracked-files=all` と `git branch --show-current` で状態を確認する。
2. ブランチ名が空（detached HEAD）ならコミット前に新規ブランチを作る。`main`、`release/*`、`epic/*` のいずれかなら「新規ブランチを作成しますか？」と必ず確認し、不要ならそのまま進む。
3. 新規ブランチは現在の `HEAD` から `<skill-dir>/../create-branch/SKILL.md` の規則で命名する。`create-branch` は名前確認を必須とするが、ここではローカルと `origin`（`git ls-remote --heads origin "refs/heads/<branch>"`）に重複がなければ確認せず作成し、重複時のみ別名候補の承認を得る。
4. 未コミット変更は `<skill-dir>/../create-commit/SKILL.md` でコミットする（未導入なら案内して停止）。`create-commit` の自動分割より優先し、複数グループに分かれる場合や機微情報を示すパス（`secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` 等）を含む場合は、最初の `git add` 前に該当箇所を示して承認を得る。

### 2. ベースブランチと関連情報の確認

1. ベースブランチが未指定なら `bash <skill-dir>/scripts/estimate-base-branches.sh` で有力候補を調べる。
2. 未指定の項目を確認する。ベースブランチは上位候補をブランチ名だけで提示し、推定結果だけで決め打ちしない（タイトル・本文のみでは既定ブランチも常に候補に含め、定まらなければ既定ブランチまたは `main` を候補にする）。あわせてチケット ID または関連リンクの有無を確認する。

### 3. 差分と状態の検証

1. PR 作成時は `origin` URL から作成先 `<owner/repo>` を確定する（取れなければ停止）。現在ブランチとベースブランチが同じなら確認してブランチ作成かベース選択へ戻る。`git fetch origin <base-branch>` 直後の `FETCH_HEAD` SHA を `<base-ref>` に固定する（タイトル・本文のみは `origin/<base-branch>` 優先、なければローカル参照）。
2. `git log <base-ref>..HEAD --oneline` と三点 diff `git diff <base-ref>...HEAD` で変更を確認し、参照解決や `merge-base` の失敗を「差分なし」と誤認せず停止する。履歴または差分が空なら停止する（タイトル・本文のみで未コミット変更を対象にする場合を除く）。
3. 未コミット変更が残る場合、PR 作成時は手順 1 に戻す（コミット不可なら停止）。タイトル・本文のみは含めるか確認し、含めるなら `git diff --merge-base <base-ref>` と未追跡ファイルも読む。
4. PR 作成時は `gh pr list --repo <owner/repo> --head <branch> --state open --json url,baseRefName,isCrossRepository`（または GitHub MCP）で `isCrossRepository == false` の開いている PR を照会する。
   - 同じベースブランチの PR あり: URL を示し既存 PR へ push してよいか確認する。承認時は対象 SHA を確定して手順 4〜5 を省き手順 6 の push と URL 共有のみ行い、拒否時は停止する。
   - 別のベースブランチの PR あり: push でその PR も更新される旨を確認し、承認後に続行する。

### 4. PR テンプレートとタイトル・本文の作成

1. 既定ブランチ（PR 作成時はベースと同じなら `<base-ref>`、異なれば fetch した SHA。タイトル・本文のみは手元の `origin/HEAD`）を `<default-ref>` として PR テンプレート（大文字小文字不問）を一覧する。コマンド失敗は「テンプレートなし」と誤認せず報告する。参照がないタイトル・本文のみでは、1 行目をリポジトリルートでの `git ls-files --cached --others --exclude-standard` に替える。

   ```bash
   files=$(git -c core.quotePath=false ls-tree -r --full-tree --name-only <default-ref>) || exit 1
   printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   ```

2. 一覧と同じ参照から内容を読む。優先順はユーザー指定（0 件・複数一致は確認）→ 単一候補 → `PULL_REQUEST_TEMPLATE/` 外の単一テンプレート（`.github/`、ルート、`docs/` 順）→ ディレクトリ内から変更内容で 1 件選択（絞れなければ確認）→ `<skill-dir>/references/default-pr-template.md` とする。
3. タイトルは Conventional Commits 形式（`type(scope): summary`。単一 `scope` に絞れなければ `type: summary`）で、目的または利用者視点の結果が一読で分かる短い文にする。
4. 本文を作成する。固有テンプレートは見出し、順序、HTML コメント、チェックリストを維持し、差分から判断できない項目だけ確認する。初めて見るレビュワー向けに完成状態のレビュー要約として「なぜ必要か」「何が変わるか」「どこに影響するか」を短い段落か数個の箇条書きにまとめ、該当しない必須項目は「なし」とする。図が明確な場合だけ `mermaid` を使い、書き終えたら不要な説明を削る。

### 5. 作成内容の確認

作成先（PR 作成時）、ベースブランチ、現在ブランチ、対象 SHA（PR 作成時）、タイトル、本文を提示し、修正依頼があれば反映して再提示する。タイトル・本文のみはここで終了し、PR 作成は承認後に手順 6 へ進む。

### 6. push と PR 作成（PR 作成時）

1. `git rev-parse HEAD` が承認済み SHA と異なれば手順 3 へ戻り再確認・再承認する（新規 PR なら本文も更新）。
2. `git push origin <approved-sha>:refs/heads/<branch>` を実行する（拒否・失敗時は強制 push せず停止）。追跡先が未設定なら `git branch --set-upstream-to=origin/<branch>` で設定する（既存設定は上書きせず、失敗しても続行）。
3. 手順 3 で既存 PR への反映を選んでいれば、push 成功後に既存 PR の URL を共有して終了する。
4. 新規 PR を作成して URL を共有する（Draft PR なら `--draft` / ドラフト指定）。gh CLI は `gh pr create --repo <owner/repo> --base <base-branch> --head <branch> --title "$title" --body-file <body-file>` を使い（タイトルは変数、本文は一時ファイルで渡し後で削除）、使えなければ GitHub MCP で作成する。
