---
name: branch-commit-push-pr
description: ブランチ作成から PR まで一気にやりたいときに使う。ユーザーが「今の変更でブランチ切ってコミットしてプッシュして PR まで」「変更を全部コミットして PR 出して」「branch 作って push して PR 作成して」と言ったとき、または一連の作業（create-branch → 全差分の commit → push → create-pr）をまとめて依頼されたときに適用する。まず create-branch でブランチを作成し、現状の差分を全てコミット・プッシュしたあと create-pr で PR を作成する。
compatibility: git、GitHub CLI または GitHub MCP。create-branch および create-pr スキルが利用可能なこと（同一プラグイン内の skills/create-branch と skills/create-pr）。カレントディレクトリは git リポジトリ。
---

# ブランチ作成 → コミット・プッシュ → PR 作成（一括）

create-branch でブランチを作成し、現状の差分をすべてコミット・プッシュしてから、create-pr で PR を作成する。

## 前提条件

- カレントディレクトリが git リポジトリであること。
- GitHub CLI（`gh`）または GitHub MCP が使えること（create-pr の前提と同様）。
- この skill 内の相対パスは、SKILL.md がある skill ディレクトリ基準で解決する。

## ワークフロー概要

1. **ブランチ作成** — create-branch のワークフローに従う。
2. **全差分のコミット・プッシュ** — 変更をすべてステージし、1 コミットでコミットしてプッシュする。
3. **PR 作成** — create-pr のワークフローに従う。

---

### ステップ 1: ブランチ作成

**create-branch スキル**（`plugins/scg-ai-playbook/skills/create-branch`）のワークフローに従い、変更内容からブランチ名を**提案**する。  
この一括フロー（branch-commit-push-pr）では、**提案されたブランチ名のユーザー確認は行わず、その提案を OK として採用**し、`git checkout -b <提案されたブランチ名>` で作成して直ちにステップ 2 に進む。

- 手順: `git status` / `git diff` で変更を確認 → プレフィックス規則（feat / fix / release / epic）でブランチ名を提案 → 確認は取らずにその名前で `git checkout -b` を実行。
- 既にメインブランチ以外の作業ブランチにいて、ユーザーが「このブランチのまま PR まで」と言っている場合は、ステップ 1 を省略し、ステップ 2 から始めてよい。

---

### ステップ 2: 全差分のコミット・プッシュ

1. **ステージ**  
   現状の差分をすべてステージする。

   ```bash
   git add -A
   git status
   ```

2. **コミットメッセージ**  
   変更内容とブランチ名（feat/fix/release/epic）に合わせて、**Conventional Commits** 形式のメッセージを決める。

   - 例: `feat(skills): add create-branch skill` / `fix(auth): resolve login redirect`
   - ブランチが `feat/xxx` なら `feat(scope): summary`、`fix/xxx` なら `fix(scope): summary` を推奨。
   - ユーザーにメッセージを提示し、問題なければそのままコミットする。変更の希望があれば反映してからコミットする。

3. **コミット**

   ```bash
   git commit -m "<メッセージ>"
   ```

4. **プッシュ**

   ```bash
   git push -u origin $(git branch --show-current)
   ```

   失敗したら停止し、エラー内容をユーザーに伝える（認証・権限・リモート設定の確認を促す）。

---

### ステップ 3: PR 作成

**create-pr スキル**（`plugins/scg-ai-playbook/skills/create-pr`）のワークフローに従う。

- ベースブランチを確認する（必要なら `scripts/estimate-base-branches.sh` を create-pr の skill ディレクトリ基準で実行し、候補を提示してユーザー確認）。
- リポジトリの PR テンプレートを参照し、差分とコミット履歴から PR タイトル・本文を組み立て、ユーザーにプレビューしてから `gh pr create`（または GitHub MCP）で PR を作成する。
- 作成後、PR の URL をユーザーに共有する。

---

## 作業時のルール

- 各ステップでユーザー確認が必要な箇所（**ステップ 1 のブランチ名を除く** — コミットメッセージ・ベースブランチ・PR 本文）は、質問ツール（AskQuestion / AskUserQuestion 等）が使える場合は優先して使う。ステップ 1 では提案されたブランチ名をそのまま採用する。
- ステップ 1 で既存ブランチと同名が存在する場合は、別名を自動で決めて作成する（例: `-2` サフィックス等）。ユーザー確認は取らない。
- ステップ 2 の時点でステージできる変更がなければ（既にすべてコミット済みなど）、コミットはスキップし、未プッシュのコミットがあればそのままプッシュする。プッシュ済みで差分もコミットもない場合はステップ 3 に進み、create-pr の「差分とコミットがある状態」を満たすか確認する（既に push 済みでコミットがあるなら PR 作成可能）。
