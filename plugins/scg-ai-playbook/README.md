# scg-ai-playbook

実務で使う Agent Skills を、Agent Plugins 1.0.0 と Claude Code の形式で配布します。
利用可能なスキルは [skills/](./skills/README.md) を参照してください。

## 配布形式

```text
plugins/scg-ai-playbook/
├── plugin.json                 # Agent Plugins 1.0.0
├── .claude-plugin/plugin.json  # Claude Code
└── skills/                    # 全クライアントで共有
    └── <skill-name>/SKILL.md
```

Agent Plugins 対応クライアントはルートの `plugin.json` から `skills/` を検出します。
旧 `.cursor-plugin/plugin.json` は廃止し、Cursor も Agent Plugins 形式を利用します。
Devin は manifest の優先順位により、本構成では `.claude-plugin/plugin.json` を読みます。
詳細は [Agent Plugins の仕様](https://agent-plugins.org/specification) と [Devin の対応形式](https://docs.devin.ai/cli/extensibility/plugins/overview#compatible-formats) を参照してください。

## 導入

### Cursor

Agent Plugins 対応バージョンの Cursor を使用してください。
Teams / Enterprise の管理画面で **Dashboard → Plugins → Add Marketplace → Import from Repo** を選び、`showcase-gig-platform/scg-ai-playbook` を指定します。
リポジトリ直下の `.cursor-plugin/marketplace.json` が配布入口です。
利用者は **Customize** から `scg-ai-playbook` を選んでインストールします。

ローカルで使う場合は、clone したリポジトリのルートで次を実行し、Cursor を再起動します。
Teams / Enterprise では管理者が **Dashboard → Settings → Security & Identity → Marketplace and Plugins → Allow Local Plugin Imports** を許可する必要があります（Enterprise は既定で無効）。

```bash
mkdir -p ~/.cursor/plugins/local
ln -s "$PWD/plugins/scg-ai-playbook" ~/.cursor/plugins/local/scg-ai-playbook
```

導入・更新の詳細は [Cursor Plugins](https://cursor.com/docs/plugins) を参照してください。

### Claude Code

Claude Code 内で marketplace を登録し、プラグインをインストールします。

```text
/plugin marketplace add showcase-gig-platform/scg-ai-playbook
/plugin install scg-ai-playbook@scg-ai-playbook
```

リポジトリ直下の `.claude-plugin/marketplace.json` が共通プラグインを参照します。
更新時は `/plugin marketplace update scg-ai-playbook` を実行し、`/plugin` の Installed からプラグインを更新します。
詳細は [Claude Code の marketplace 配布](https://code.claude.com/docs/en/plugin-marketplaces) を参照してください。

### Codex

```bash
codex plugin marketplace add showcase-gig-platform/scg-ai-playbook
```

リポジトリ直下の `.agents/plugins/marketplace.json` を登録します。
Codex のプラグイン画面で `SCG AI Playbook` の marketplace を選び、`scg-ai-playbook` をインストールして新しいセッションを開始します。
更新時は `codex plugin marketplace upgrade scg-ai-playbook` で marketplace を更新します。
画面ごとの利用方法は [Plugins](https://learn.chatgpt.com/docs/plugins)、配布形式は [Package your plugin](https://developers.openai.com/plugins/build/plugins) を参照してください。

### Devin

クラウド版は **Customize → Plugins → Add plugin → From repository** で次を指定し、適用先の Personal / Organization / Enterprise を選びます。

- リポジトリ: `showcase-gig-platform/scg-ai-playbook`
- サブディレクトリ: `plugins/scg-ai-playbook`

CLI からは次のコマンドで導入できます。

```bash
devin plugins install showcase-gig-platform/scg-ai-playbook#plugins/scg-ai-playbook
```

既定では Personal に登録され、クラウドにも同期されます。
端末内だけで使う場合は `--local` を付けます。
CLI の更新は `devin plugins update scg-ai-playbook`、クラウドの表示更新は Customize の **Reindex plugins** を使います。
詳細は [クラウド版の導入手順](https://docs.devin.ai/product-guides/plugins) と [Devin CLI plugins](https://docs.devin.ai/cli/extensibility/plugins/overview) を参照してください。

## 検証

[検証 CI](../../.github/workflows/ci.yaml) で [JSON Schema Validate Action](https://github.com/dsanders11/json-schema-validate-action) を使用します。
Agent Plugins manifest、Claude Code manifest、Claude Code marketplace をそれぞれの JSON スキーマで検証します。
Cursor / Codex marketplace と、ファイル間の参照先・メタデータ・バージョンの整合性は検証対象に含めません。

配布対象はスキルのみです。
スキル本文のクライアント依存・パス記述の変更、各クライアントでの実機検証、公開 marketplace への掲載申請は対象外です。
この検証はスキル本文の互換性や実動作を保証しません。

## リリース

プラグインのバージョンは `0.4.0` から継続し、release-please が2種類の manifest を同時に更新します。
次回からリリース識別名・タグの接頭辞は `cursor-plugin` から `agent-plugin` に変わります。
リポジトリ本体のリリースは従来どおり別管理です。
初回の Release PR では、マージ直前にプラグインの CHANGELOG と PR 本文の比較元タグを `agent-plugin-v0.4.0` から `cursor-plugin-v0.4.0` に修正してください。
release-please の再実行で上書きされる場合があるため、再生成後も両方を確認してください。

## 参考リンク

- [Agent Plugins manifest](https://agent-plugins.org/plugin-authors/manifest)
- [Agent Plugins JSON Schemas](https://agent-plugins.org/schemas)
- [Claude Code Plugins reference](https://code.claude.com/docs/en/plugins-reference)
