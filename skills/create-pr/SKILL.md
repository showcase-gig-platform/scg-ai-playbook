---
name: create-pr
description: プロジェクトのPRテンプレートに従ってGitHub Pull Requestを作成する。git差分・コミット履歴からPR本文を作成する。PRを作成する必要があるときに使用する。
compatibility: Requires gh CLI or GitHub MCP, git, and access to the internet. The target directory must be a git repository.
license: Apache-2.0
---

# Create a GitHub Pull Request

## 目的

プロジェクトのPRテンプレートに従い、git情報から内容を自動生成してPull Requestを作成する。

## 前提条件

- `gh` CLI または Pull Request を作成できる GitHub MCP が利用可能であること
- `gh` CLI と GitHub MCP の両方が利用可能な場合は `gh` CLI を優先する
- 作業ブランチで変更がコミット済み
- リモートにプッシュ済み

前提条件を満たしていない場合は即座に停止し、何が不足しているかを説明する。

## ワークフロー

### Step 1: ユーザーへの確認

原則として以下を確認する:

1. **ベースブランチ**: マージ先（デフォルト: `main`）
2. **チケットID / リンク**: Jira・GitHub Issue等のURL

テンプレート内に自動推測できない項目がある場合のみ、追加で確認する。

### Step 2: 現状確認（自動実行）

以下を実行して現在のgitの状態を確認する:

```bash
gh --version
gh auth status
git status
git branch --show-current
git log <base-branch>..HEAD --oneline
git diff <base-branch> --stat
git remote get-url origin
```

確認項目と判定：

- `gh --version` が失敗しても GitHub MCP が利用可能なら MCP に切り替えて継続する
- `gh --version` が成功し、`gh auth status` が失敗した場合は GitHub MCP が利用可能なら MCP に切り替えて継続する
- `gh --version` と `gh auth status` の両方が成功した場合は `gh` CLI を使って継続する
- `gh` CLI も GitHub MCP も使えない場合は停止し、利用可能な PR 作成手段がないことを説明する
- 未コミットの変更がある場合は停止し、先にコミットが必要だと説明する
- リモートにプッシュされていない場合は停止せず、`git push -u origin <branch>` を次のアクションとして提案する
- リモートURLが取得できない場合は停止し、`origin` の設定確認が必要だと説明する

### Step 3: PRテンプレートの決定

PR本文を生成する前に、以下の優先順でテンプレートを探す：

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `references/default-pr-template.md`

#### ルール

- 見つかった場合はそのファイルを読み、見出し・順序・HTMLコメント・チェックリストを維持して本文を作成する
- テンプレート内の項目で自動推測できないものだけをユーザーに確認する
- リポジトリにPRテンプレートが存在しない場合は `references/default-pr-template.md` をフォールバックテンプレートとして使い、そのまま継続する
- リポジトリ固有テンプレートがある場合は常にそちらを優先する

### Step 4: PR本文の作成

- **PRタイトル**: まずブランチ名から推測し、適切でない場合はコミットメッセージの要約を使う
- **PRの目的**: コミットメッセージを整理して生成
- **影響範囲**: `git diff <base-branch> --stat` からファイル一覧を取得しカテゴリ分け
- **破壊的変更点**: 破壊的変更がある場合は記載する（例: DBスキーマ変更、API定義変更、エンドポイント変更など）
- **動作確認項目**: 変更内容、追加・更新されたテスト、手動確認が必要な観点から生成する
- **参考リンク**: デフォルト「なし」

### Step 5: プレビューと確認

作成するPRの内容（タイトル・本文）をユーザーに提示する。修正依頼があれば反映してから次へ進む。

### Step 6: PR作成

- `gh` CLI が利用可能で認証済みなら `gh pr create` を使用する。
- `gh` CLI が使えない場合は、利用可能な GitHub MCP の Pull Request 作成機能を使用する。
- 作成したPRのURLを表示する。

## 停止・提案・継続の基準

- **停止**: 未コミットの変更がある、利用可能な PR 作成手段がない、`origin` の取得に失敗する、ベースブランチやテンプレート必須項目が確定できない
- **提案**: リモートにブランチが未 push の場合は `git push -u origin <branch>`、`gh` 未認証で GitHub MCP も使えない場合は `gh auth login`
- **継続**: リポジトリ固有テンプレートがなくても `references/default-pr-template.md` で継続する。`gh` が使えなくても GitHub MCP が使えるなら継続する
