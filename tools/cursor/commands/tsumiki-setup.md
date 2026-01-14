# Name: tsumiki-setup

---

# Description: Tsumikiフレームワークをプロジェクトに導入するための計画書。事前調査から設定完了まで段階的に実行します。

---

# Content

## このプランの使い方

### 初回使用

このプランに従ってTsumikiを導入する場合:

```
このプランに従って、Tsumikiを導入してください。
```

### 別リポジトリでの流用方法

このplan.mdファイルを別のリポジトリで使用する場合:

1. 新しいリポジトリをCursorで開く
2. このplan.mdファイルを読み込む
3. 以下のように指示:

```
この@[plan.mdファイル名] のプランに従って、
このリポジトリにTsumikiを導入してください。

プロジェクト名: [プロジェクト名]
プロジェクトタイプ: [gRPCサーバー/CLIツール/Webアプリケーション等]
```

AIが事前調査から順番に実行し、プロジェクトに合わせてプランを適用します。

---

## 概要

**[PROJECT_NAME]**は**[PROJECT_LANGUAGE]**で書かれた**[PROJECT_TYPE]**です。このプロジェクトにTsumikiを導入し、AI駆動開発のワークフローを確立します。

---

## 事前調査（Phase 0）

### 0-1. プロジェクト構造の確認（🤖 AI自動実行）

以下の項目をAIが自動的に調査します:

- [ ] `package.json`の存在確認
- [ ] 既存ドキュメントディレクトリの確認（`docs/`, `documentation/`等）
- [ ] `.gitignore`の内容確認
- [ ] `.cursorignore`の存在確認
- [ ] 言語固有の設定ファイル確認（`go.mod`, `pyproject.toml`, `Cargo.toml`等）

**実行するアクション:**

- `package.json`の有無を確認し、手順1の分岐を決定
- 既存ドキュメント構造を把握し、`docs/tsumiki/`の配置場所を決定
- `.gitignore`に`node_modules/`が含まれているか確認

### 0-2. 技術スタック情報の収集（🤖 AI自動実行）

プロジェクトの言語に応じて以下のファイルから情報を自動収集します:

**Go言語の場合:**
- `go.mod` → Go versionと依存ライブラリ
- `Makefile` または `taskfile.yml` → ビルドツール

**Python言語の場合:**
- `pyproject.toml` / `requirements.txt` → Python versionと依存ライブラリ
- `setup.py` / `setup.cfg` → パッケージ情報

**Rust言語の場合:**
- `Cargo.toml` → Rust versionとクレート

**TypeScript/JavaScript言語の場合:**
- `package.json` → Node.js versionと依存ライブラリ
- `tsconfig.json` → TypeScript設定

**共通:**
- `README.md` → プロジェクト概要と既存の技術スタック情報
- `docker-compose.yaml` → コンテナ環境とミドルウェア

**収集する情報:**

- 言語バージョン
- 使用フレームワーク
- データベース（MySQL, PostgreSQL, Redis等）
- インフラ（Docker, Kubernetes, AWS, GCP等）
- ビルドツール

---

## 実装内容

### 1. Node.js環境のセットアップ

**🔍 条件分岐:**

#### ケースA: `package.json`が既に存在する場合

- 既存の`package.json`をそのまま利用
- Tsumikiのインストールに進む（手順2へ）
- **確認事項**: `package.json`が壊れていないか簡易チェック

#### ケースB: `package.json`が存在しない場合

- プロジェクトルートに`package.json`を作成
- 以下の内容で初期化:

```json
{
  "name": "[プロジェクト名（小文字・ハイフン区切り）]",
  "version": "1.0.0",
  "description": "[プロジェクト説明]",
  "private": true,
  "scripts": {},
  "devDependencies": {}
}
```

**📝 注意:**

- TsumikiはNode.jsツールのため、他の言語プロジェクトでも併用します
- `.gitignore`に`node_modules/`が含まれていることを確認（なければ追加）

### 2. Tsumikiの基本インストール

以下のコマンドを実行:

```bash
npx tsumiki install
```

**実行結果:**

- `.claude/commands/`ディレクトリにスラッシュコマンドがインストールされる
- 利用可能なコマンド一覧が表示される

**確認事項:**

- `.claude/commands/`ディレクトリが作成されたか
- コマンドファイル（`*.md`）が配置されたか

### 3. rulesyncの設定（Cursor対応）

Cursor環境で使用するため、rulesyncを使ってコマンドを変換します:

```bash
npx -y rulesync init
npx -y rulesync import --targets claudecode --features commands,subagents
npx -y rulesync generate --targets cursor --features commands --experimental-simulate-commands
```

**実行結果:**

- `.cursorrules`ファイル または `.cursor/commands/`ディレクトリが作成される
- Cursor用のカスタムスラッシュコマンドが生成される

**📝 注意:**

- `--experimental-simulate-commands`は実験的機能です
- 生成されたファイルは`.gitignore`に含めず、チーム共有推奨

### 3.5. 日本語化設定（重要）

Tsumikiコマンドが日本語で応答するように`.cursorrules`ファイルに日本語化指示を追加します。

**`.cursorrules`ファイルの先頭に以下を追加:**

```markdown
## Language Settings
- Always respond in Japanese (日本語) for all Tsumiki commands
- Use polite Japanese form (です・ます調)
- Provide detailed explanations in Japanese
- When using Tsumiki commands, ensure all output is in Japanese
- For technical terms, use Japanese with English in parentheses when needed
```

**実行方法:**

手動で`.cursorrules`ファイルを編集するか、以下のコマンドで追加:

```bash
# .cursorrules の先頭に日本語化設定を追加
cat > .cursorrules.tmp << 'EOF'
# Tsumiki Commands for Cursor

This project uses Tsumiki framework for AI-driven development. The following commands are available:

## Language Settings
- Always respond in Japanese (日本語) for all Tsumiki commands
- Use polite Japanese form (です・ます調)
- Provide detailed explanations in Japanese
- When using Tsumiki commands, ensure all output is in Japanese
- For technical terms, use Japanese with English in parentheses when needed

EOF
cat .cursorrules >> .cursorrules.tmp
mv .cursorrules.tmp .cursorrules
```

**📝 重要:**

- この設定により、すべてのTsumikiコマンド（`/kairo-*`, `/tdd-*`, `/rev-*`等）が日本語で応答します
- コード自体は英語のまま（変数名、関数名等）
- コメントとドキュメントは日本語で生成されます

### 3.6. プロジェクト言語に応じたoverview.mdの設定

生成された`.rulesync/rules/overview.md`を、プロジェクトで使用されている言語に応じて修正します。

**Go言語プロジェクトの場合:**
- TypeScript用の設定をGo言語用に変更
- インデント設定をタブに変更
- Go言語特有のルールを追加
- リント処理はMakefileのlintコマンドを使用する旨を記載

**Python言語プロジェクトの場合:**
- インデントはスペース4つ（PEP 8準拠）
- 型ヒントの使用を推奨
- リント処理はflake8, pylint, ruff等を使用

**Rust言語プロジェクトの場合:**
- インデントはスペース4つ（Rust標準）
- cargo fmt, cargo clippyを使用

**TypeScript/JavaScript言語プロジェクトの場合:**
- プロジェクトのeslint/prettier設定に従う

**📝 重要:**
- この設定により、Tsumikiコマンド実行時にプロジェクトの言語に適したコードが生成されます
- 既存のプロジェクトのコーディング規約に合わせて調整してください

### 4. 技術スタック情報の準備

プロジェクトの技術スタックドキュメントを`docs/tsumiki/tech-stack.md`に作成します。

**ディレクトリ作成:**

```bash
mkdir -p docs/tsumiki
```

**`docs/tsumiki/tech-stack.md`の内容:**

事前調査（Phase 0-2）で収集した情報を元に、以下の形式で作成:

```markdown
# 技術スタック

## プロジェクト情報
- プロジェクト名: [PROJECT_NAME]
- タイプ: [PROJECT_TYPE]

## 言語・ランタイム
- [言語名]: [バージョン]

## フレームワーク・ライブラリ
- [使用しているフレームワーク]
- [主要な依存ライブラリ]

## データベース・ミドルウェア
- [MySQL, PostgreSQL, Redis等]

## インフラ・デプロイ
- [Docker, Kubernetes, AWS, GCP等]
- [CI/CD]

## ビルド・開発ツール
- [Make, npm scripts, cargo等]
- [コード生成ツール]

## 開発環境
- [ローカル開発環境の起動方法]
- [テスト実行方法]
```

**🔍 情報源:**

- `README.md` - プロジェクト概要
- 言語設定ファイル（`go.mod`, `Cargo.toml`, `package.json`等） - バージョン、依存ライブラリ
- `Makefile` / `package.json scripts` - ビルド・テストコマンド
- `docker-compose.yaml` - ミドルウェア構成
- プロジェクト構造 - アーキテクチャパターン

### 5. .gitignore/.cursorignoreの更新

Tsumiki関連ファイルの適切な管理設定を行います。

**`.gitignore`に追加（必要な場合のみ）:**

既に`node_modules/`が含まれているか確認し、なければ追加:

```gitignore
# Node.js（Tsumiki用）
node_modules/
package-lock.json
yarn.lock

# rulesync生成ファイル（オプション）
# .rulesync/
```

**`.cursorignore`の作成または更新:**

存在しない場合は新規作成、存在する場合は以下を追加:

```
# 大きなディレクトリ（AIの読み込み対象外）
node_modules/
.git/

# ビルド成果物（プロジェクトに応じて調整）
vendor/
dist/
build/
target/
__pycache__/
```

**📝 管理方針（チーム共有推奨）:**

- ✅ `.claude/commands/*` → コミット対象
- ✅ `.cursorrules` または `.cursor/commands/*` → コミット対象
- ✅ `docs/tsumiki/*` → コミット対象
- ❌ `node_modules/` → 除外
- ✅ `package.json` → コミット対象

### 6. READMEの更新

`README.md`に以下のセクションを追加します（既存の構造に合わせて配置）:

**追加する内容:**

~~~markdown
## AI駆動開発（Tsumiki）

このプロジェクトではTsumikiフレームワークを導入しています。

### 利用可能なコマンド

#### 初期設定
```
/init-tech-stack
```
技術スタック情報を確認・初期化します（初回のみ）。

#### Kairoフロー（新機能開発）
要件定義から実装までの一連のフローをサポートします:

1. `/kairo-requirements` - 要件定義書を作成
2. `/kairo-design` - 技術設計文書を生成
3. `/kairo-tasks` - 実装タスクを分割・順序付け
4. `/kairo-implement` - TDD方式で実装を実行

#### TDDコマンド（個別実行）
テスト駆動開発を段階的に実行:

1. `/tdd-requirements` - TDD要件定義
2. `/tdd-testcases` - テストケース作成
3. `/tdd-red` - テスト実装（Red）
4. `/tdd-green` - 最小実装（Green）
5. `/tdd-refactor` - リファクタリング
6. `/tdd-verify-complete` - TDD完了確認

#### リバースエンジニアリング（既存コード文書化）
既存コードから設計文書を自動生成:

1. `/rev-tasks` - タスク構造の逆生成
2. `/rev-design` - 設計文書の逆生成
3. `/rev-specs` - テスト仕様書の逆生成
4. `/rev-requirements` - 要件定義書の逆生成

### 詳細情報
使い方の詳細は [docs/tsumiki/USAGE.md](docs/tsumiki/USAGE.md) を参照してください。
~~~

**挿入位置:**

- 既存の「Development」セクションの前、または
- 「Documents」セクションの後
- プロジェクトの構造に合わせて最適な位置に配置

### 7. 動作確認用ドキュメント作成

`docs/tsumiki/USAGE.md`を作成します。

**含める内容:**

```markdown
# Tsumiki 使用ガイド

## 初回セットアップ

1. 技術スタックの初期化
   ```
   /init-tech-stack
   ```

2. 生成された `docs/tsumiki/tech-stack.md` を確認

## Kairoフロー（新機能開発）

### 使用例: 新しいAPIエンドポイントの追加

1. 要件定義
   ```
   /kairo-requirements
   ```
   → ユーザー認証APIを追加したい

2. 技術設計
   ```
   /kairo-design
   ```

3. タスク分割
   ```
   /kairo-tasks
   ```

4. 実装
   ```
   /kairo-implement
   ```

## TDDフロー（テスト駆動開発）

### 使用例: ユーティリティ関数の追加

1. `/tdd-requirements` - 要件を定義
2. `/tdd-testcases` - テストケースを設計
3. `/tdd-red` - 失敗するテストを作成
4. `/tdd-green` - テストをパスさせる
5. `/tdd-refactor` - リファクタリング
6. `/tdd-verify-complete` - 完了確認

## リバースエンジニアリング

### 使用例: 既存コードのドキュメント化

1. `/rev-tasks` で対象ディレクトリを指定
2. `/rev-design` で設計文書を生成
3. `/rev-specs` でテスト仕様書を生成
4. `/rev-requirements` で要件定義書を生成

## トラブルシューティング

### コマンドが認識されない
- `.cursorrules`ファイルが正しく配置されているか確認
- Cursorを再起動

### 日本語で応答しない
- `.cursorrules`に日本語化設定が含まれているか確認
```

---

## 主要ファイル一覧

| ファイル/ディレクトリ | 作成方法 | 説明 |
|---------------------|---------|------|
| `package.json` | 新規作成 or 既存利用 | Node.js依存関係管理 |
| `.claude/commands/*` | Tsumikiが生成 | Claude Code用コマンド |
| `.cursorrules` or `.cursor/commands/*` | rulesyncが生成 | Cursor用コマンド |
| `docs/tsumiki/tech-stack.md` | 手順4で作成 | 技術スタック情報 |
| `docs/tsumiki/USAGE.md` | 手順7で作成 | 使い方ガイド |
| `README.md` | 手順6で更新 | プロジェクト README |
| `.gitignore` | 手順5で更新 | Git除外設定 |
| `.cursorignore` | 手順5で作成/更新 | Cursor除外設定 |

---

## 導入後の活用方法

### Kairoフロー（新機能開発）

1. `/init-tech-stack` - 技術スタック確認
2. `/kairo-requirements` - 要件定義
3. `/kairo-design` - 設計
4. `/kairo-tasks` - タスク分割
5. `/kairo-implement` - 実装

### リバースエンジニアリング（既存コード文書化）

1. `/rev-tasks` - タスク構造分析
2. `/rev-design` - 設計文書生成
3. `/rev-specs` - テスト仕様書生成
4. `/rev-requirements` - 要件定義書生成

---

## 注意事項

- **Cursor対応**: `--experimental-simulate-commands`による実験的サポートです
- **環境の共存**: 他言語プロジェクトとNode.js環境が共存します
- **既存フロー**: 既存の開発フロー（Makefile、docker-compose、cargo等）は維持されます
- **チーム開発**: `.claude/`と`.cursor/`ディレクトリをコミットして共有推奨

---

## 他のプロジェクトへの適用

このプランは**汎用テンプレート**です。

### プレースホルダー

- `[PROJECT_NAME]` → プロジェクト名
- `[PROJECT_LANGUAGE]` → プログラミング言語（Go, Python, Rust, TypeScript等）
- `[PROJECT_TYPE]` → プロジェクトタイプ（gRPCサーバー、CLIツール、Webアプリケーション等）

### 自動適応される項目

- 言語バージョン（設定ファイルから自動取得）
- 依存ライブラリ（設定ファイルから自動取得）
- ミドルウェア構成（`docker-compose.yaml`から自動取得）
- ビルドツール（`Makefile`等から自動取得）

### 手動調整が必要な項目

- プロジェクト固有のドキュメント構造
- 特殊な開発フロー
- カスタムビルドプロセス
