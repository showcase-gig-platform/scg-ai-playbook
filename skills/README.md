# Agent Skills

このディレクトリには、[Agent Skills](https://agentskills.io/home)に基づくスキルを配置しています。

## インストール

`npx skills add` コマンドを使用して各スキルをインストールできます。

```bash
npx skills add showcase-gig-platform/scg-ai-playbook --skill <skill-name>
```

## 利用可能な Skill

- `anthropic-skill-creator`: Anthropic 流の draft → test → review → improve ループで Skill を作成・改善
- `coderabbit-review`: CodeRabbit CLI を使ったコードレビュー
- `gh-pr-summary-update`: 現在ブランチの GitHub PR を分析し、タイトルと構造化サマリーを更新

## 参考

- [Agent Skills](https://agentskills.io/home)
- [npx skills - Vercel Labs](https://github.com/vercel-labs/skills#readme)
