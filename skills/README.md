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
- `create-pr`: プロジェクトの PR テンプレートに従い、git 差分から本文を自動生成して GitHub PR を作成

## 参考

- [Agent Skills](https://agentskills.io/home)
- [npx skills - Vercel Labs](https://github.com/vercel-labs/skills#readme)
