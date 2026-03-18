---
name: create-commit
description: Gitの変更をステージしてコミットする。「コミットして」「コミットしたい」「変更をコミット」といったリクエストで使用。差分を分析し、whatとwhyを含む適切なコミットメッセージを自動生成する。
---

# Git Commit Skill

現在のブランチで変更をステージし、適切なコミットメッセージでコミットする。

## コミットメッセージの原則

良いコミットメッセージには**what（何を変更したか）**と**why（なぜ変更したか）**の両方が含まれる。

- **what**: コードを見ればわかることもあるが、概要として明記することで理解を助ける
- **why**: コードを見ただけでは絶対にわからない。変更の意図、背景、理由を説明することが最も重要

## ワークフロー

1. `git status` で現在の状態を確認
2. `git diff` と `git diff --cached` で変更内容を把握
3. **変更を意味的なグループに分類**（複数の目的が混在している場合）
4. グループごとに:
   a. 対象ファイルをステージ（`git add <ファイル>`）
   b. コミットメッセージを生成
   c. コミットを実行
5. 単一の目的の変更のみの場合は従来通り一括コミット

## 変更のグループ分類

### なぜ分割するか

1つのコミットには1つの目的（why）のみを含めるべき。複数の目的が混在すると:
- コミット履歴が追いにくくなる
- 特定の変更だけを revert したい場合に困る
- コードレビューで変更の意図が伝わりにくい

### 分類の基準

以下の観点で変更を分類する:

| 観点 | 説明 |
|------|------|
| **why（理由）** | 同じ理由・目的の変更は同じコミットへ |
| **機能的な関連性** | 同じ機能に対する変更は同じコミットへ |
| **変更の種類** | 新機能、バグ修正、リファクタリング、ドキュメント更新など |

### 分類の例

1つの作業セッションで以下の変更があった場合:
- `UserProfileView.swift` に編集機能を追加
- `LegacyUserManager.swift` を削除（不要になったレガシーコード）
- `README.md` にセットアップ手順を追加

→ **3つの別コミット**に分ける:
1. `feat: UserProfileViewに編集機能を追加`
2. `refactor: LegacyUserManagerを削除`
3. `docs: READMEにセットアップ手順を追加`

### 判断のガイドライン

- **1つの変更が複数の目的を持つ場合**: 主要な目的でまとめる
- **依存関係がある場合**: 例えばリファクタリング→機能追加の順序で依存がある場合、その順序でコミット
- **迷った場合**: 「この変更だけを revert したくなることがあるか？」と考える。あるなら分ける
- **Claudeが自動判断**: ユーザー確認なしで適切に分割し、結果を報告する

## コミットメッセージフォーマット

```
prefix: 概要説明（what）

why:
なぜこの変更が必要だったかの説明

what:
- 具体的な変更点1
- 具体的な変更点2
- ...
```

### 各セクションの説明

#### 1行目: 概要（what の要約）
- **prefix**: 英語で記述（Conventional Commits形式）
- **概要説明**: 日本語で簡潔に記述
  - ファイル名、クラス名、関数名、システム用語は英語のまま維持
  - 例: `Info.plistにATTの設定を追加`

#### why セクション
変更の理由・背景・意図を説明する。以下のような観点で記述:
- **問題**: どんな問題があったか（バグ修正の場合）
- **目的**: 何を達成したかったか（新機能の場合）
- **背景**: なぜ今この変更が必要か
- **制約**: 技術的な制約や考慮事項

#### what セクション
具体的に何を変更したかをリスト形式で記述:
- 追加・削除・変更したファイルや機能
- 実装の詳細（必要に応じて）

### Prefix一覧

| Prefix | 用途 |
|--------|------|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | コードの動作に影響しない変更（空白、フォーマット等） |
| `refactor` | バグ修正でも機能追加でもないコード変更 |
| `perf` | パフォーマンス改善 |
| `test` | テストの追加・修正 |
| `chore` | ビルドプロセスや補助ツールの変更 |
| `build` | ビルドシステムや外部依存関係の変更 |
| `ci` | CI設定ファイルやスクリプトの変更 |
| `revert` | 以前のコミットを取り消し |

## 例

### 例1: 新機能追加

```
feat: UserProfileViewに編集機能を追加

why:
ユーザーからプロフィールを変更したいという要望が多く寄せられていた。
現状では設定画面からしか変更できず、導線がわかりにくかった。
プロフィール画面から直接編集できるようにすることでUXを改善する。

what:
- EditProfileSheetを新規作成
- プロフィール画像の変更機能を実装（PhotosPickerを使用）
- ユーザー名のバリデーションを追加（3-20文字、英数字のみ）
- 保存時のローディング表示とエラーハンドリングを追加
```

### 例2: バグ修正

```
fix: ログイン画面でクラッシュする問題を修正

why:
ユーザーがパスワードを空欄のままログインボタンを押すとクラッシュしていた。
原因はpassword.countを直接参照しており、nilの場合に強制アンラップで落ちていた。
App Store Connectのクラッシュレポートで週100件以上報告されていた。

what:
- LoginViewModelにpasswordのnilチェックを追加
- 空欄の場合はバリデーションエラーを表示するように変更
- 関連する単体テストを追加
```

### 例3: リファクタリング

```
refactor: APIクライアントをasync/awaitに移行

why:
既存のAPIクライアントはコールバックベースで実装されており、
ネストが深くなりがちでコードの可読性が低下していた。
Swift Concurrencyに統一することで、エラーハンドリングも簡潔になり、
今後の機能追加時の開発効率が向上する。

what:
- APIClientのすべてのメソッドをasync throwsに変更
- completionハンドラを削除
- 呼び出し元のViewModelをTaskでラップするよう修正
- レガシーなDispatchQueue.main.asyncを@MainActorに置換
```

### 例4: 設定変更

```
chore: Info.plistにATT設定を追加

why:
AdMob広告を導入するにあたり、iOS 14.5以降で必須となる
App Tracking Transparency（ATT）の許可ダイアログを表示する必要がある。
これがないとApp Store審査でリジェクトされる。

what:
- NSUserTrackingUsageDescriptionを追加（日本語の説明文）
- SKAdNetworkItemsにGoogleの広告ネットワークIDを追加
```

### 例5: ドキュメント更新

```
docs: READMEにセットアップ手順を追加

why:
新しいチームメンバーがプロジェクトに参加した際、
環境構築に時間がかかっていた。
手順が口頭伝達に頼っていたため、ドキュメント化する。

what:
- 必要な開発環境（Xcode、CocoaPods等）の記載
- APIキーの取得・設定方法を追加
- よくあるエラーとその解決方法を追加
```

## 複数コミットの実行例

以下のような変更がある場合の実行フロー:

```
Changes not staged for commit:
  modified:   UserProfileView.swift    # 編集機能追加
  modified:   UserProfileViewModel.swift # 編集機能追加
  deleted:    LegacyUserManager.swift  # レガシーコード削除
  modified:   README.md                # セットアップ手順追加
```

### Step 1: グループ分類

| グループ | ファイル | 目的 |
|---------|---------|------|
| 1 | UserProfileView.swift, UserProfileViewModel.swift | 編集機能追加 |
| 2 | LegacyUserManager.swift | レガシーコード削除 |
| 3 | README.md | ドキュメント更新 |

### Step 2: 順次コミット

```bash
# グループ1: 新機能
git add UserProfileView.swift UserProfileViewModel.swift
git commit -m "feat: UserProfileViewに編集機能を追加..."

# グループ2: リファクタリング
git add LegacyUserManager.swift
git commit -m "refactor: LegacyUserManagerを削除..."

# グループ3: ドキュメント
git add README.md
git commit -m "docs: READMEにセットアップ手順を追加..."
```

### 結果報告

コミット完了後、以下の形式で報告:

```
3件のコミットを作成しました:

1. feat: UserProfileViewに編集機能を追加
   - UserProfileView.swift
   - UserProfileViewModel.swift

2. refactor: LegacyUserManagerを削除
   - LegacyUserManager.swift

3. docs: READMEにセットアップ手順を追加
   - README.md
```

## 補足

### なぜwhyが重要か

6ヶ月後に同じコードを見たとき、「なぜこう実装したのか」は覚えていない。
whatはgit diffで確認できるが、whyはコミットメッセージにしか残らない。
将来の自分や他のメンバーのために、必ずwhyを記録する。

### whyが思い浮かばない場合

- そもそも本当に必要な変更か再考する
- 変更のきっかけ（Issue、PRコメント、ユーザー報告）を思い出す
- 「この変更がなかったらどうなるか」を考える
