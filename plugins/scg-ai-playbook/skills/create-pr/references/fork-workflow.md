# fork 構成での読み替え

`SKILL.md` の `origin` と `<owner/repo>` を、作成元リモート `<head-remote>`（通常 `origin`、所有者 `<head-owner>`）と作成先リモート `<target-remote>`（通常 `upstream`、`<target-owner>/<target-repo>`）に読み替える。

- 手順 1: 重複確認は `<head-remote>` で行う。
- 手順 2: `bash <skill-dir>/scripts/estimate-base-branches.sh <target-remote> <head-remote>` を実行する（`<head-remote>` が `origin` なら第 2 引数は省略できる）。
- 手順 3: `<target-remote>` からベースブランチを fetch して SHA を固定し、同一ブランチ判定はリポジトリとブランチ名の組で行う。既存 PR の照会は次のコマンド（gh CLI がなければ GitHub MCP）で行い、応答の `head.repo.full_name` が作成元リポジトリと一致するものだけを対象にする。

  ```bash
  gh api --method GET "repos/<target-owner>/<target-repo>/pulls" -f state=open -f head="<head-owner>:<branch>"
  ```

- 手順 4: テンプレートは作成先リポジトリの既定ブランチ参照から取得する。
- 手順 5: push 先リモートも提示する。
- 手順 6: push と追跡先の設定は `<head-remote>` に対して行う。新規 PR は `--repo <target-owner>/<target-repo> --head <head-owner>:<branch>` を明示する。組織所有 fork 等で `gh pr create` が失敗した場合は、`gh api repos/<target-owner>/<target-repo>/pulls` の `POST` で作成する。その際は `head` に `<head-owner>:<branch>`、`base`、`title`、`body` を指定し、必要に応じて `draft` と同一組織の別リポジトリ向け `head_repo` を付ける。
