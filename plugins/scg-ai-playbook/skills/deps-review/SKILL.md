---
name: deps-review
description: 依存関係更新のローカル差分やPRをレビューする。人間・エージェントによる更新、Dependabot・Renovateの更新PRを対象に、upstreamの変更と利用箇所を照合し、根拠付きの判定を返す。
license: Apache-2.0
---

# 依存関係更新レビュー

## Overview

人間・エージェントによるローカルの依存関係更新、Dependabot・Renovate等の更新PRをレビューし、根拠付きの判定を行う。upstreamのchangelogを読むだけでなく、リポジトリ内の利用箇所と照合し、「未確認」を「影響なし」と混同しないことがこのSkillの核心である。

## What's Needed From User

- レビュー対象: PRのURL（複数可）、ローカルの未コミット差分、または比較元のブランチ・commitを指定したコミット済み差分
- 任意: 特に懸念している点（例: 本番影響、特定機能、release branchへの反映要否）
- 任意: レビュー結果の出力先（デフォルトは会話内。ファイルを指定された場合はそこに保存する）

## レビュー対象の特定

- PR: 利用可能なGitHubツールまたはCLIで差分・説明・CI結果とbase / head commitを取得し、対象headのコードを調査する
- ローカルの未コミット差分: `git status --short`、`git diff`、`git diff --cached` と未追跡ファイルを確認し、対象の更新を特定する
- コミット済み差分: 指定された比較元と対象commitを確定し、ブランチ比較ではmerge-baseからの差分を確認する。利用箇所の調査・ローカル検証も対象commitの状態で行う。未コミット差分を含めるのは依頼された場合に限る

依頼と作業状態から対象を特定できない場合だけ、比較範囲をユーザーに確認する。ローカル差分に対応するCIがない場合は未実施として扱い、必要な検証をローカルで行う。別commitのCI成功を対象差分の検証根拠にしない。検証が追跡ファイルを書き換える場合は、対象差分を再現した一時ディレクトリ等で実行し、既存の作業内容を保つ。

## Procedure

1. 特定した対象の差分・説明・検証結果から、更新対象の依存、旧version、新version、更新種別（patch / minor / major / runtime / tool）、直接依存か間接依存かを整理する
2. 「レビューの深さ」表でリスク区分を決める。認証、決済、DB、クラウドprovider、Kubernetes controllerに関わる依存はversion番号に関係なく高リスクとして扱う
3. リポジトリ内の利用状況を調査する。import・呼び出し・型参照だけでなく、設定キー、環境変数、plugin登録、build script、CI、generator設定、動的load、peer dependencyの接点も検索する。検索結果が空でも即「未使用」と判断しない
4. upstreamのRelease Notes / Upgrade Guide / 差分から破壊的変更、default値変更、設定キーのrename・削除、deprecationを列挙し、手順3の利用箇所と1件ずつ対応づける。build・型検査で検出できるものと実行時にしか現れないものを分けて記録する
5. 各変更を「該当機能未使用 / 影響なし / 影響あり / 不明」の4分類で判定し、判定ごとに根拠を記録する
6. 差分の妥当性を確認する。manifest・lockfile・生成物以外の変更が混ざっていないか、lockfileで変化した間接依存を説明できるか、pin / override / resolution / replace で更新が無効化・部分適用されていないか、registry URL・integrity・install script・外部通信先・認証情報の変化がないか
7. runtimeやツール（Node.js、Go、package manager、GitHub Actions、Docker image、Terraform等）の更新では、同じversionを参照する箇所（version管理ファイル、CI setup step、Dockerfile、`engines`、`go.mod`等）を横断的に確認し、部分更新の場合はその理由が説明されているか確認する
8. 該当エコシステムの節（後述）のチェックを適用する。CIが検証しないmodule、image、platformがあれば、ローカルでクリーンinstall（frozen lockfile）、lint、型検査、test、buildを実行する。「影響あり」の経路を既存testが実際に通過しているか確認し、mockだけで検証しているtestを根拠にしない
9. 高リスク更新では「実行時の影響」と「リリース」の節を確認する（性能・default値・log/metricの変更、rollback手順、rolling deployment中の新旧version混在、他のrelease branchへの反映要否）
10. 「承認判断」の条件に照らして Approve候補 / Request changes を判定する
11. 下記フォーマットで判定と根拠を返す。判定を確定できない場合は「判定保留」とし、不足している確認事項を明記する。Approve候補 / Request changes はレビュー結果のラベルであり、GitHub上のレビュー操作を意味しない

## Specifications

### レビュー本文のフォーマット

読み手は先頭数行で判定と理由を把握できることを最優先とする。全体で概ね30行以内。

```
## <Approve候補 | Request changes | 判定保留>: <依存名> <旧> → <新>
<判定理由を1〜3行で。例: 「patch更新で破壊的変更なし。実行時に到達するのは Transition のみで、該当修正は影響なし。CI・ローカルbuild・test成功。」>

### 概要
- 対象: <PR URLとhead commit、または比較元・対象commitと未コミット差分の有無>
- 種別 / リスク: <patch・minor・major・runtime>、<本番・開発用>、<高リスクか否か>
- 利用箇所: <実行時に到達する利用のみをファイル名で列挙。未到達なものは件数だけ>
- 照合結果: <「影響あり」「不明」の変更だけを列挙し根拠を一行で。影響なし・未使用は「その他N件は影響なし/未使用」とまとめる>
- 差分: <実際に変更されたファイルの種類を要約し、不審な変化があれば記載>
- 検証: <実行したものと結果を一行で。未実施・実行不能の項目は理由も記載>
- 残存リスク / 依頼事項: <ある場合のみ。Request changes の場合は必要な対応を箇条書き>

<details><summary>詳細</summary>
<検索コマンド、変更ごとの4分類表、参照URLなど、再現に必要な情報はここにまとめる>
</details>
```

- 判定理由は必ず先頭。表は使わず箇条書きで書く（詳細内は可）
- 概要は各項目1〜2行。問題がない項目は一語で済ませ、調査の経緯や否定した可能性の列挙は書かない
- 検索コマンド、全変更の照合表、参照URLは `<details>` 内に限定する（再現性のために残すが、本文には出さない）
- 高リスク更新に「不明」が残る場合、または「影響あり」の修正・検証が未完了の場合は Approveしない
- 高リスク更新以外で「不明」が残る場合は、「残存リスク」に記録したうえで承認理由を先頭に書く

## Advice and Pointers

### レビューの深さ

開発用依存とは、配布物とbuild outputに影響しないものを指す。build・変換・コード生成に関与する依存は本番依存と同じ深さでレビューする。

| 更新                                                    | 最低限の確認                                                            |
| ------------------------------------------------------- | ----------------------------------------------------------------------- |
| 開発用依存のpatch / minor更新                           | 利用状況、upstreamの変更、クリーンinstall、既存CI                       |
| 本番依存のpatch / minor更新                             | 上記に加えて、利用箇所との照合、主要経路のsmoke test                    |
| major更新またはruntime更新                              | 破壊的変更との照合、migration、全build対象、staging相当の検証、rollback |
| 認証、決済、DB、クラウドprovider、Kubernetes controller | version番号に関係なく高リスク。混在versionと運用影響を確認              |

「高リスク更新」とは表の3行目または4行目に該当する更新を指す。高リスク更新を除き、patch / minor更新で該当する変更がない場合は、確認結果を記録したうえで「実行時の影響」と「リリース」を省略できる。差分の説明、固定install、既存CIの確認は省略しない。changelogが無い・不完全な場合はversion間の差分を確認してから省略可否を判断する。

### 4分類の判定基準

| 判定           | 意味                                         | 必要な根拠                                                        |
| -------------- | -------------------------------------------- | ----------------------------------------------------------------- |
| 該当機能未使用 | 変更対象の機能を利用していない               | コード検索に加えて、設定、plugin、generator、動的利用の接点がない |
| 影響なし       | 利用しているが変更の影響を受けない           | 引数、設定値、実行条件などから新しい挙動へ到達しない              |
| 影響あり       | 修正、migration、追加検証が必要              | 影響を受ける経路、修正、検証方法を特定している                    |
| 不明           | 利用状況または実行時の影響を確認できていない | 必要な証拠を取得できていない                                      |

- 検索結果が空であることだけを「該当機能未使用」「影響なし」の根拠にしない。framework、build plugin、code generator、peer dependency、初期化時の副作用は直接importされないことがある
- 間接依存では中間packageの利用箇所を照合対象にする。中間package内の影響を確認できない場合は「不明」とする
- 削除・renameされた設定キーが無視される場合、意図した設定が有効であることを実行時に確認する
- 直接依存が未使用と判断できる場合は、別PRでの削除を提案する

### security advisoryを理由とする更新

- 新versionがadvisoryの修正version条件を満たしている
- 脆弱な機能・実行経路を実際に利用しているか確認する
- pin、override、間接依存の制約で修正が無効化されていない
- 更新を延期・見送る場合はリスクを記録する

### 更新設定（Dependabot / Renovate設定の変更を含む差分、または対象範囲・base branch・grouped updateが想定と異なる場合）

- manager種類、manifestディレクトリ、対象範囲、base branch
- grouped updateに含まれる依存、ignore / allow / exclude / version constraint
- private registryと認証方式、cooldown / minimum release age
- 自動更新の対象外になっている関連ファイル

### 検証の注意点

- CIのdependency cacheがlockfileの変更を反映しているか
- 最新のbase branchを取り込んだ状態でCIが成功しているか
- bot作成PRで権限やsecretが制限される場合、通常CIとの差を確認する
- 生成物がある場合は生成コマンドを再実行して差分を確認する
- 変更経路を通るtestがない場合は最小の回帰test / smoke testの追加を求める

### 実行時の影響（高リスク更新）

latency / CPU / memory / 起動時間、network通信量、timeout / retry / connection pool / 並行数のdefault変更、log / metric / trace名称の変更、既存dashboard・alertへの影響。事前測定は必須とせず、upstreamの記載、既存benchmark、段階的deploy後の観測、停止条件のうち利用可能な証拠を使う。

### リリース（高リスク更新、deploy・配布に影響する更新、共有状態や通信形式を扱う依存）

他の保守ブランチ（release/vX.Y.Z）への反映要否、rollback方法、複数サービス・リポジトリの更新順序、private dependencyのtagと互換性、rolling deployment中の新旧同時稼働、API / event / DB schema / cache / 永続データの前方・後方互換性、migration後に旧versionへ戻せるか、canaryで確認する指標、release automation更新時の認証・署名・配布先接続。

### エコシステム別チェック

**Node.js本体**: `.node-version` / `.nvmrc` / Volta、`package.json` の `engines`、CIの `node-version` / `node-version-file`、Dockerfileの `FROM node:*`、`@types/node` のmajorと実行runtimeの整合、Corepackとpackage managerの対応、ESM/CJS・OpenSSL・native addon、glibc / musl、cache keyへのversion反映。

**JavaScript / TypeScript依存**: `npm ci` / `yarn install --immutable` / pnpm frozen lockfile相当が通る、peer dependency警告、framework・renderer・型・build pluginの対応範囲、optional / native dependencyのOS・arch解決、routing・SSR/CSR境界・環境変数・build outputへの影響、新しいTS / linterエラーをignoreで隠していない、UI依存では主要画面 / component preview / visual regression、test runner更新ではconfig・環境・snapshot形式、browser automation更新では本体とbrowser revisionの組み合わせ。

**JavaScript package manager**: `packageManager` / Corepack / Volta / `yarnPath` の指定、lockfile形式の対応、workspaceとpeer dependencyの解決結果、script実行ポリシー、CI・Docker・開発環境が同じpackage managerを使う、private registryのクリーンinstall再現。

**Go本体**: すべての `go.mod` の `go` と `toolchain`、CIのGo setup、Dockerfileの `FROM golang:*` / `GO_VERSION`、server / batch / Lambda / generatorなど用途別build環境、CGO・OS・arch・標準ライブラリの挙動変更、必要なバイナリとcontainer imageのbuild。

**Go module**: direct / indirectの変化、major version・pseudo-version・`+incompatible`、`replace` / `exclude` / local module参照、`go.sum` の大量削除・upgrade・downgrade、DB driver / cloud SDK / RPC / observabilityライブラリの初期化・設定変更、API / schema / event payloadのconsumer互換性。複数moduleではroot moduleの `go test ./...` はネストしたmoduleを検証しないため、変更されたmoduleごとに `go mod tidy` / `go build ./...` / `go test ./...` を実行する。

**GitHub Actions**: inputs / outputs / default値、Node.js runtimeとrunner要件（self-hosted含む）、`permissions` の拡大、OIDC / PAT / `GITHUB_TOKEN`、`persist-credentials` / `fetch-depth` / submodule / checkout ref、cache・artifact形式、reusable workflow・composite Actionへの影響、SHA固定が記載versionのtagと一致、実際のジョブ成功。branch参照の共有Action / reusable workflowは提供側の変更が利用側へ自動で届くため、提供側更新時は参照元リポジトリを含めて影響範囲を確認する。

**Docker / OCI image**: 同じimageを参照するDockerfile / Compose / Kubernetes manifestの検索、build stageとruntime stage、single / multi-architectureの整合、OS・glibc/musl・CA証明書・timezone・DNS・package名、default user / UID / entrypoint / shell / healthcheck、imageのbuildと起動、floating tagのdigest、stateful serviceのデータ形式とupgrade手順、本番managed serviceと開発containerのversion差。

**Terraform**: `.terraform-version`、各rootの `required_version`、CI・remote executionのTerraform version、provider / module constraint、各rootの `.terraform.lock.hcl` と必要platformのhash、対象外providerの混入、CIのformat / init / validate / plan結果、CI対象外rootの手動plan、planのcreate / update / replace / destroyの人による確認、IAM・公開範囲・暗号化・default値・tag、major更新のstate migration。

**Kubernetes / Helm / Kustomize**: render後の最終manifest比較、CRD / API version / RBAC / IAM / webhook / certificate、selector / label / Service port / resources / PDB / security context、chart default値の上書き、CRDとcontrollerの適用順序、leader electionとrollout中の可用性、metrics名・label変更のmonitor影響、clusterとKubernetes versionの対応範囲、schema validatorの除外kind、全overlayからの検証、関連chart / componentの連動更新。

**Protobuf / コード生成**: compiler・generator・runtimeライブラリのversionを分けて確認、生成物がすべて対象差分に含まれている、整形差分への意味変更の混入、field numberの再利用・削除、enum zero値 / optional / presence / JSON field名、service / method / HTTP annotationのconsumer互換、schema registry / module lockのdigest、lintだけでなくbreaking change検査。

**DB migration / 単体CLI**: 対象OS・arch用asset、checksum・署名の検証、archive形式・ファイル名・実行権限、CLI option / 出力形式 / config形式、既存の履歴・state・metadataの読み込み、downgrade時の互換、fresh schemaと既存schemaでのdry-run、apply後の再dry-runが空、意図しないDROP / ALTER / index / foreign key、DAO / ORM生成物の再生成。

**Flutter / Android / iOS**: Flutter / Dart SDK constraintとbuild環境、lockfile / dependency resolution、static analysisとtest、対象platformのrelease build、native pluginのpermission / minimum OS・SDK / lifecycle / background動作、生成物の再生成、Git dependencyのtagとcommit、Gradle / AGP / JDK / Kotlin / Flutter pluginの互換、compile / target / minimum SDK・deployment target、CocoaPods lockfileの全再解決。

**Python / Ruby**: runtime versionとライブラリの対応、lockfileが無い場合の実解決version記録、native packageのOS・arch対応、resolver変更の結果、実行単位（server / batch / script）ごとのsmoke test、framework更新の起動方法・middleware・設定・default値。

**pre-commit hook**: revision / hook ID / argument / stage / runtime要件、`pre-commit run --all-files`、自動整形による無関係差分の混入、外部CLIとの互換性。

**上記以外のエコシステム**: 共通チェックを適用し、manifest → lockfile → runtime → CI → コンテナ → 生成物の順に確認する。CI対象外のworkspace / subprojectを確認する。

### 承認判断

次がすべて揃えばApprove候補とする。

1. 依存の利用状況を確認した
2. upstreamの変更を利用箇所と照合し、高リスク更新に「不明」が残っていない
3. 更新箇所を横断して確認し、部分更新の理由を説明できる
4. manifest、lockfile、生成物の差分を説明できる
5. 更新の深さに応じて、CIから漏れるmodule、image、platformを検証した
6. 必要な互換性、migration、rollbackを確認した
7. security advisoryを理由とする更新では、脆弱なversionと経路が解消されている

次のいずれかに該当する場合はRequest changesとする。

- runtimeまたはツールの部分更新に説明がない
- 高リスク更新で利用箇所と影響を確認できていない、または他の更新で残存リスクの記録がない
- 影響を受ける経路をtestまたはsmoke testが通らない
- 大量のlockfile差分を説明できない
- 必要な生成物が対象差分に含まれていない
- インフラ変更のplanまたはrender結果を確認できない
- CI/CDの権限拡大が説明されていない
- package名、publisher、所有者、配布元、install script、外部通信先の変更を説明できない
- 新旧versionが共有状態または通信形式を扱う更新で、rolling deployment中の互換性を確認できていない
- DBまたはschemaのmigrationとrollbackが確認されていない

## Forbidden Actions

- 検索結果が空であることだけを根拠に「該当機能未使用」「影響なし」と判定する
- upstreamのchangelogを読んだだけで、利用箇所との照合をせずに判定する
- 高リスク更新に「不明」を残したままApprove候補とする
- PRをマージする
- 承認判断の条件を満たさない更新をApprove候補とする
- レビュー対象を修正する、または修正commitをpushする（修正が必要な場合はレビュー結果で提案する）
- 更新対象をmockしているtestの成功を検証根拠にする
- 日本語以外でレビュー結果を記載する
- GitHubレビューやコメント、Issueを投稿する
- 判定理由を本文の後半に置く
