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

- ツール（PR 作成時）: `gh --version` が成功すれば gh CLI を使い、事前に `gh auth status` で認証を確認する。未認証ならユーザーに `gh auth login` を依頼する。gh CLI が使えなければ GitHub MCP を使い、どちらも使えなければ停止する。
- 確認手段: ユーザーへの確認は質問ツールを優先する。
- `<skill-dir>`: この `SKILL.md` があるディレクトリを指す。
- fork 構成（PR 作成時）: 別リポジトリが作成先の場合、または gh CLI 利用時に `gh repo view --json nameWithOwner` が `origin` の `owner/repo` と一致しない場合や `gh repo view <origin の owner/repo> --json isFork,parent` が fork を示す場合は作成先を確認し、fork なら `<skill-dir>/references/fork-workflow.md` に従う。

## 手順

### 1. ブランチとコミットの準備（PR 作成時）

1. `git status --untracked-files=all` と `git branch --show-current` で状態を確認する。
2. ブランチ名が空（detached HEAD）ならコミット前に新規ブランチを作る。`main`、`release/*`、`epic/*` のいずれかなら「新規ブランチを作成しますか？」と必ず確認し、不要ならそのまま進む。
3. 新規ブランチは `<skill-dir>/../create-branch/SKILL.md` の規則で命名し、現在の `HEAD` から作成する。未導入なら変更内容から `feat/`、`fix/`、`release/`、`epic/` のプレフィックスで命名する。`create-branch` は名前確認を必須とするが、ここではローカルと `origin`（`git ls-remote --heads origin "refs/heads/<branch>"`）に重複がなければ確認せず作成し、重複時のみ別名候補の承認を得る。
4. 未コミットの変更は `<skill-dir>/../create-commit/SKILL.md` に従ってコミットする。未導入なら導入か事前コミットを案内して停止する。`create-commit` の自動分割より優先し、複数グループに分かれる場合や機微情報を示すパス（`secret`、`.env`、`credentials`、`key`、`password`、`token`、`.pem`、`.key` 等）を含む場合は、最初の `git add` 前に該当箇所を示して承認を得る。

### 2. ベースブランチと関連情報の確認

1. ベースブランチが未指定なら `bash <skill-dir>/scripts/estimate-base-branches.sh` で有力候補を調べる。
2. 未指定の項目を確認する。ベースブランチは上位候補をブランチ名だけで提示し（タイトル・本文のみでは既定ブランチも候補に含める）、候補が定まらなければ既定ブランチまたは `main` を候補にする。推定結果だけで決め打ちしない。あわせてチケット ID または関連リンクの有無を確認する。

### 3. 差分と状態の検証

1. PR 作成時は `origin` URL から作成先 `<owner/repo>` を確定し、取れなければ停止する。現在のブランチとベースブランチが同じならユーザーに確認してブランチ作成かベースブランチ選択へ戻る。`git fetch origin <base-branch>` 直後に `base_ref=$(git rev-parse FETCH_HEAD)` のように SHA へ解決して `<base-ref>` に固定する。タイトル・本文のみでは `origin/<base-branch>` を優先し、なければローカルの `<base-branch>` を `<base-ref>` にする。
2. `git log <base-ref>..HEAD --oneline` と三点 diff `git diff <base-ref>...HEAD` で変更を確認し、参照解決や `merge-base` の失敗を「差分なし」と誤認せず停止する。履歴または差分が空なら停止する（タイトル・本文のみで未コミットの変更を対象にする場合を除く）。
3. 未コミットの変更が残る場合、PR 作成時は手順 1 に戻し、コミットできなければ停止する。タイトル・本文のみでは本文に含めるか確認し、含めるなら `git diff --merge-base <base-ref>` と未追跡ファイルも読む。
4. PR 作成時は `gh pr list --repo <owner/repo> --head <branch> --state open --json url,baseRefName,isCrossRepository`（gh CLI が使えなければ GitHub MCP）で `isCrossRepository == false` の開いている PR を照会する。
   - 同じベースブランチの PR がある場合: URL を示し、既存 PR へ push してよいか確認する。承認されれば対象 SHA を確定して手順 4〜5 を省き、手順 6 の push と URL 共有のみ行う。拒否されれば停止する。
   - 別のベースブランチの PR がある場合: push するとその PR も更新される旨を確認し、承認を得てから続行する。

### 4. PR テンプレートとタイトル・本文の作成

1. リポジトリルート基準で PR テンプレート（大文字小文字不問）を一覧する。PR 作成時の `<default-ref>` は、既定ブランチがベースブランチと同じなら `<base-ref>`、異なれば既定ブランチを fetch した直後に `git rev-parse FETCH_HEAD` で得た SHA とする。タイトル・本文のみでは手元の `origin/HEAD` を使い、参照がなければ下の 1 行目の代入を `files=$(git -C "$(git rev-parse --show-toplevel)" -c core.quotePath=false ls-files --cached --others --exclude-standard)` に替える。コマンドの失敗は「テンプレートなし」と誤認せず報告する。

   ```bash
   if files=$(git -c core.quotePath=false ls-tree -r --full-tree --name-only <default-ref>); then
     printf '%s\n' "$files" | grep -Ei '^((docs|\.github)/)?pull_request_template(\.[^/]+|/.+)?$' || echo "No Pull Request templates found"
   else
     echo "ls-tree failed" >&2; false
   fi
   ```

2. 一覧と同じ参照からテンプレートの内容を読む。採用順はユーザー指定（0 件または複数一致なら確認）、単一候補、`PULL_REQUEST_TEMPLATE/` 外の単一テンプレート（`.github/`、ルート、`docs/` の順）、ディレクトリ内の候補から変更内容で 1 件選択（絞れなければ確認）、`<skill-dir>/references/default-pr-template.md` とする。
3. タイトルは Conventional Commits 形式（`type(scope): summary`。単一 `scope` に絞れなければ `type: summary`）で、目的または利用者視点の結果が一読で分かる短い文にする。
4. 本文を作成する。固有テンプレートは見出し、順序、HTML コメント、チェックリストを維持し、差分から判断できない項目だけ確認する。初めて見るレビュワー向けに完成状態のレビュー要約として「なぜ必要か」「何が変わるか」「どこに影響するか」を短い段落か数個の箇条書きにまとめ、該当しない必須項目は「なし」とする。文章より図のほうが明確な場合だけ `mermaid` を使う。PR 作成かつ gh CLI が `--attach` に対応している場合、レビュー判断に役立つスクリーンショットや録画のうち、ユーザー指定またはこのセッションで生成したファイルだけを添付対象にする（画像は本文へ `![説明](<path>)` で組み込める。機微情報を含むファイルは添付しない）。書き終えたら不要な説明を削る。

### 5. 作成内容の確認

作成先（PR 作成時）、ベースブランチ、現在のブランチ、対象 SHA（PR 作成時）、添付ファイル（あれば 1 件ごとに承認を確認）、タイトル、本文を提示し、修正依頼があれば反映して再提示する。タイトル・本文のみはここで終了し、PR 作成は承認を得てから手順 6 へ進む。

### 6. push と PR 作成（PR 作成時）

1. `git rev-parse HEAD` が承認済み SHA と異なれば手順 3 へ戻り、差分を再確認して再承認を得る（新規 PR なら本文も更新する）。
2. `git push origin <approved-sha>:refs/heads/<branch>` を実行し、拒否や失敗時は強制 push せず停止する。追跡先が未設定なら `git branch --set-upstream-to=origin/<branch>` で設定する（既存設定は上書きせず、失敗しても続行する）。
3. 手順 3 で既存 PR への反映を選んでいれば、push 成功後に既存 PR の URL を共有して終了する。
4. 新規 PR を作成して URL を共有する（Draft PR なら `--draft` またはドラフト指定を付ける）。gh CLI では `gh pr create --repo <owner/repo> --base <base-branch> --head <branch> --title "$title" --body-file <body-file>` を使い、添付ファイルがあれば `--attach <path>`（本文に参照を書かない画像は `'<path>#<alt>'`、録画は alt なし）を添える。タイトルは変数、本文は一時ファイルで渡し、実行後に一時ファイルを削除する。一部添付の失敗で非 0 終了しても stdout に PR URL が出ていれば作成済みのため、再作成せず URL と失敗した添付を報告する。gh CLI が使えなければ GitHub MCP で作成する。
