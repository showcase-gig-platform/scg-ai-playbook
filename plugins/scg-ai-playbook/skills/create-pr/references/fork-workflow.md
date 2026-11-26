# fork 構成での PR 作成補足

PR 作成時に別リモートを作成先に指定された場合、または gh CLI 利用時の `gh repo view --json nameWithOwner` が `origin` の `owner/repo` と一致しない場合は、`SKILL.md` の `origin` と `<owner/repo>` を次のとおり読み替える。`<head-remote>` は作成元リモート（通常 `origin`）、`<target-remote>` は作成先リモート（通常 `upstream`）、`<head-owner>` は作成元リポジトリの所有者、`<target-owner>/<target-repo>` は作成先リポジトリを指す。

## 手順 1（重複確認）

`origin` を `<head-remote>` に読み替えて、作成元リモートの重複を確認する。

## 手順 2（ベース候補推定）

`bash <skill-dir>/scripts/estimate-base-branches.sh <target-remote>` のように作成先リモートを引数に渡す。

## 手順 3（差分確認と既存 PR 照会）

1. `<target-remote>` からベースブランチを fetch し、`git rev-parse FETCH_HEAD` の SHA を `<base-ref>` に固定する。同一ブランチ判定は「リポジトリ＋ブランチ」で行う。
2. 既存 PR の照会は REST API を使い、応答の `head.repo.full_name` が作成元リポジトリと一致する PR だけを対象にする。GitHub MCP でも同じ条件で照合する。

```bash
gh api --method GET "repos/<target-owner>/<target-repo>/pulls" \
  -f state=open -f head="<head-owner>:<branch>"
```

## 手順 4（テンプレート取得）

作成先リポジトリ `<target-owner>/<target-repo>` の既定ブランチ参照からテンプレートを一覧する。

## 手順 5（確認提示）

作成先リポジトリ `<target-owner>/<target-repo>`、push 先リモート・ブランチ、承認対象のコミット SHA もあわせて提示する。

## 手順 6（push と PR 作成）

1. push は `<head-remote>` に対して行い、追跡先が未設定なら `<head-remote>/<branch>` を設定する。
2. gh CLI で新規 PR を作成するときは `--repo <target-owner>/<target-repo>` と `--head <head-owner>:<branch>` を明示する。
3. 組織所有 fork など `gh pr create --head` が非対応の環境では、`gh api repos/<target-owner>/<target-repo>/pulls` の `POST` で作成する。作成元と作成先が同じ組織の別リポジトリなら `head_repo` も指定する。
