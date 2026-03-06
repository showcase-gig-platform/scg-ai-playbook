# SCG AI Playbook

AI活用に関する汎用的なガイドラインやツール設定を共有するリポジトリです。

## Why SCG AI Playbook?

このリポジトリは以下を公開するものです。

- AIを安全かつ実務的に活用するための「考え方」と「型」
- 特定のツールやモデルに依存しない再利用可能なPlaybook

## How to use

- フォークして自社用にカスタマイズしてください
- 一部ディレクトリだけの利用も歓迎します

## Cursor Plugin

このリポジトリは Cursor Plugin として配布できるよう、[`.cursor-plugin/plugin.json`](./.cursor-plugin/plugin.json) を追加しています。

- `skills/`: Cursor Plugin の Skill として配布
- `tools/cursor/commands/`: Cursor Plugin の Command として配布

Marketplace 提出時は、このリポジトリをそのまま plugin repository として利用できます。詳細は [Cursor Plugins ドキュメント](https://cursor.com/ja/docs/plugins) を参照してください。

## ディレクトリ構造

```plaintext
scg-ai-playbook/
├── philosophy/       # AI活用のフィロソフィー（位置付け・役割分担・判断基準）
├── governance/       # ガバナンス（パブリックAI利用時の基本ルール）
├── guidelines/       # AI活用全般のガイドライン
├── skills/           # Agent Skills
└── tools/            # ツール設定・テンプレート
    └── cursor/       # Cursor関連の設定ファイル
        ├── commands/ # team commands
        └── rules/    # team rules
```

## 内容

### guidelines/

AI活用全般に関するガイドラインを配置しています。

### philosophy/

AIをどう位置付け、どう使うかの「前提」を揃えるためのドキュメントを配置します。

- **AIの位置付け**: 例）「生産性向上の手段」「思考補助」「代替ではない」
- **人とAIの役割分担**: どこまでをAIに任せ、どこからを人が責任を持つか
- **AI導入時の判断基準（使う／使わない）**: 目的・リスク・品質要件・説明責任などの観点

### governance/

パブリックAI（外部サービスや外部モデル）利用時の基本ルールを配置します。

- **基本ルール**: 入力・出力・保存・共有の原則（何をしてよくて、何を禁止するか）
- **入れてはいけない情報の分類（抽象化）**: 機密情報を「カテゴリ」で整理し、具体例よりも再現可能な判断軸を提示
- **OSS / 公開物に含めてよいAI生成物の考え方**: ライセンス、出所・根拠、再現性、レビュー責任、混入リスク（秘匿情報/著作物）など

### [skills/](./skills/)

[Agent Skills](https://agentskills.io/home)に基づくスキルを配置します。

- `gh-pr-summary-update`: 現在ブランチの GitHub PR を分析し、タイトルと構造化サマリーを更新する Skill

### [tools/cursor/](./tools/cursor/)

[Cursor](https://cursor.sh/)エディタで使用できるチームコマンド、チームルールの設定を配置します。

- **commands/**: チームコマンド（Markdown形式）
- **rules/**: チームルール（Markdown形式）

## 貢献方法

1. このリポジトリをフォーク
2. 変更を加えたブランチを作成
3. プルリクエストを送信

## 注意事項

このリポジトリはパブリックです。社内固有の情報や機密情報は含めないでください。
