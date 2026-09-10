# scg-ai-playbook

Agent Plugins または Claude Code Plugin として利用可能です。
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
詳細は [Agent Plugins の仕様](https://agent-plugins.org/specification) と [Devin の対応形式](https://docs.devin.ai/cli/extensibility/plugins/overview#compatible-formats) を参照してください。

## 導入

### Cursor

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

登録済みの marketplace を手動で更新する場合は、Claude Code 内で次を実行します。

```text
/plugin marketplace update scg-ai-playbook
```

詳細は [Claude Code の marketplace 配布](https://code.claude.com/docs/en/plugin-marketplaces) を参照してください。

### Codex

```bash
codex plugin marketplace add showcase-gig-platform/scg-ai-playbook
codex plugin add scg-ai-playbook@scg-ai-playbook
```

登録済みの marketplace を更新する場合は、既存の marketplace 名を指定します。

```bash
codex plugin marketplace upgrade scg-ai-playbook
```

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

## 参考リンク

- [Agent Plugins manifest](https://agent-plugins.org/plugin-authors/manifest)
- [Agent Plugins JSON Schemas](https://agent-plugins.org/schemas)
- [Claude Code Plugins reference](https://code.claude.com/docs/en/plugins-reference)
