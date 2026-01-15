# Name: init-tech-stack

---

# Description: プロジェクトの技術スタック情報を自動検出・初期化します。Tsumikiコマンド使用前に実行推奨。

---

# Content

## 概要

このコマンドは、プロジェクトの技術スタック情報を自動検出し、`docs/tsumiki/tech-stack.md`に記録します。

## 実行手順

### 1. プロジェクト言語の自動検出

以下のファイルを確認して、プロジェクトの主要言語を特定してください：

| ファイル | 言語 |
|---------|------|
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python |
| `package.json` + `tsconfig.json` | TypeScript |
| `package.json`（tsconfig.jsonなし） | JavaScript |
| `pom.xml`, `build.gradle` | Java |
| `*.csproj`, `*.sln` | C# |
| `mix.exs` | Elixir |
| `Gemfile` | Ruby |

### 2. 技術スタック情報の収集

検出した言語に応じて、以下の情報を収集してください：

**共通項目：**
- プロジェクト名（ディレクトリ名またはREADMEから）
- プロジェクトタイプ（API、CLI、Webアプリ、ライブラリ等）
- 使用フレームワーク
- データベース/ミドルウェア（docker-compose.yaml等から）
- CI/CD設定（.github/workflows等）
- ビルドツール（Makefile, npm scripts等）

**言語固有の情報：**

| 言語 | 収集するファイル | 収集内容 |
|------|-----------------|---------|
| Go | `go.mod` | Go version、依存モジュール |
| Rust | `Cargo.toml` | edition、依存クレート |
| Python | `pyproject.toml` | Python version、依存パッケージ |
| TypeScript | `package.json`, `tsconfig.json` | Node version、依存パッケージ、TS設定 |
| Java | `pom.xml`, `build.gradle` | Java version、依存ライブラリ |

### 3. tech-stack.mdの作成

`docs/tsumiki/`ディレクトリを作成し、以下の形式で`tech-stack.md`を生成してください：

```markdown
# 技術スタック

## プロジェクト情報
- プロジェクト名: [検出したプロジェクト名]
- タイプ: [検出したプロジェクトタイプ]
- 言語: [検出した言語]

## 言語・ランタイム
- [言語名]: [バージョン]

## フレームワーク・ライブラリ
- [検出したフレームワーク]
- [主要な依存ライブラリ（上位5-10個）]

## データベース・ミドルウェア
- [検出したDB/ミドルウェア]

## インフラ・デプロイ
- [Docker/Kubernetes等]
- [CI/CD設定]

## ビルド・開発ツール
- [ビルドツール]
- [テストツール]
- [リンター/フォーマッター]

## 開発環境
- ローカル起動: [コマンド]
- テスト実行: [コマンド]
- ビルド: [コマンド]
```

### 4. 確認と出力

収集した技術スタック情報を表示し、ユーザーに確認を求めてください。

## 出力形式

技術スタック情報を以下の形式で出力してください：

```
## 検出結果

**プロジェクト**: [名前]
**言語**: [言語] [バージョン]
**フレームワーク**: [フレームワーク名]
**データベース**: [DB名]
**ビルドツール**: [ツール名]

docs/tsumiki/tech-stack.md を作成しました。
```

## 注意事項

- 既存の`docs/tsumiki/tech-stack.md`がある場合は上書き確認を行う
- 検出できなかった項目は「不明」または「なし」と記載
- モノレポの場合は、各サブプロジェクトを個別に記載

## 次のステップ

技術スタックの初期化が完了したら、以下のコマンドを使用できます：

### 新機能開発（Kairoフロー）
1. `/kairo-requirements` - 要件定義
2. `/kairo-design` - 技術設計
3. `/kairo-tasks` - タスク分割
4. `/kairo-implement` - 実装（TDD使用）

### TDD開発サイクル
1. `/tdd-requirements` - TDD要件整理
2. `/tdd-testcases` - テストケース設計
3. `/tdd-red` - 失敗するテスト作成
4. `/tdd-green` - 最小実装
5. `/tdd-refactor` - リファクタリング
6. `/tdd-verify-complete` - 完了確認

### 既存コードのドキュメント化（リバースエンジニアリング）
1. `/rev-tasks` - タスク構造の逆生成
2. `/rev-design` - 設計書の逆生成
3. `/rev-specs` - テスト仕様書の逆生成
4. `/rev-requirements` - 要件定義書の逆生成
