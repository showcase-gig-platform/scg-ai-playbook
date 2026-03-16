# Cursor Team Commands & Rules

このディレクトリには、[Cursor](https://cursor.sh/)のチームコマンドとチームルールを配置しています。

## ディレクトリ構成

- **commands/**: チームコマンド（Markdown形式）
- **rules/**: チームルール（Markdown形式）
- [**skills/**](./skills/): Agent Skills

## チームルール

### Team Rules の形式と適用方法

- **プレーンテキスト**: Team Rules は自由記述のテキストです。Project Rules のようなフォルダ構造は使用せず、globs、alwaysApply、ルールタイプといったメタデータもサポートしません。
- **適用範囲**: Team Rule が有効になっていて（強制設定でない限りユーザーによって無効化されていなければ）、そのチームのすべてのリポジトリとプロジェクトにおける Agent（Chat）のモデルコンテキストに含まれます。
- **優先順位**: ルールは次の順序で適用されます: Team Rules → Project Rules → User Rules。該当するすべてのルールがマージされ、指示内容が競合する場合は先に適用されるソースが優先されます。

## 参考リンク

- [Cursor Commands ドキュメント](https://cursor.com/ja/docs/agent/chat/commands#-2)
- [Cursor Rules ドキュメント](https://cursor.com/ja/docs/context/rules)
