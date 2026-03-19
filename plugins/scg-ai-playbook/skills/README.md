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
- `create-branch`: 現在の変更内容に合うブランチ名を提案し、ブランチを作成
- `create-commit`: Git の変更を整理し、what と why を含むコミットメッセージで変更をコミット
- `create-pr`: GitHub PR を作成。必要なら新規ブランチ作成・未コミット変更のコミット（create-commit 利用）を事前に行う。main/release/*/epic/* のときは新規ブランチ要否を確認。テンプレートに従い差分から本文を生成

## 参考

- [Agent Skills](https://agentskills.io/home)
- [npx skills - Vercel Labs](https://github.com/vercel-labs/skills#readme)
