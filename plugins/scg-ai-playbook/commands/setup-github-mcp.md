# setup-github-mcp

## 目的

GitHub MCPサーバーをCursorに設定し、GitHub APIとの連携を可能にします。

## 前提条件

- Node.js (v18以上) がインストールされている
- GitHub Personal Access Token (PAT) を取得済み
- `~/.cursor/mcp.json` ファイルへの書き込み権限がある
- シェル設定ファイル（`~/.zshrc`等）への書き込み権限がある

## ⚠️ セキュリティに関する重要事項

**トークンはmcp.jsonに直接書かず、環境変数から取得します。**

理由：
- mcp.jsonをLLMが読み取ると、トークンが露出するリスクがある
- チャット履歴にトークンが残る可能性がある
- 環境変数を使用することで、これらのリスクを軽減できる

## GitHub Personal Access Tokenの取得方法

1. GitHub にログイン
2. Settings → Developer settings → Personal access tokens → Tokens (classic)
3. "Generate new token (classic)" をクリック
4. 必要なスコープを選択：
   - `repo` - リポジトリへのフルアクセス
   - `read:org` - 組織情報の読み取り
   - `read:user` - ユーザー情報の読み取り
   - `read:project` - プロジェクト情報の読み取り
5. トークンを生成してコピー（一度しか表示されません）

## 実行内容

1. **環境変数の設定**
   - シェル設定ファイル（`~/.zshrc`）にトークンを設定
   - シェルを再読み込み

2. **MCP設定の追加**
   - `~/.cursor/mcp.json` にGitHub MCP設定を追加
   - トークンは環境変数から参照（直接書かない）

3. **設定の検証**
   - Cursorを再起動して設定を反映
   - MCPサーバーが正常に起動するか確認

## 設定フォーマット

### 1. 環境変数の設定（~/.zshrc）

```bash
# GitHub MCP用のPersonal Access Token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 2. MCP設定（~/.cursor/mcp.json）

以下の設定を `mcpServers` セクションに追加します：

```json
{
  "mcpServers": {
    "github": {
      "command": "/path/to/npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}",
        "PATH": "/path/to/node/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

**注意**: `${GITHUB_TOKEN}` は環境変数を参照するプレースホルダーです。トークンを直接書かないでください。

## 設定パラメータ

- **command**: `npx` コマンドのフルパス
  - fnmを使用している場合: `~/.local/share/fnm/node-versions/vXX.XX.X/installation/bin/npx`
  - システムのnodeを使用している場合: `/usr/local/bin/npx` または `which npx` で確認
  
- **args**: MCPサーバーの起動引数
  - `-y`: インストール確認をスキップ
  - `@modelcontextprotocol/server-github`: GitHub MCPサーバーパッケージ

- **env**: 環境変数
  - `GITHUB_PERSONAL_ACCESS_TOKEN`: `${GITHUB_TOKEN}` で環境変数から取得
  - `PATH`: Node.jsのパスを含むシステムパス

## 実行手順

### 1. Node.jsパスの確認

```bash
which npx
# 例: /Users/username/.local/share/fnm/node-versions/v20.11.0/installation/bin/npx
```

### 2. GitHub Personal Access Tokenの取得

GitHubでトークンを生成し、安全な場所にコピーしておきます。

### 3. 環境変数の設定

シェル設定ファイル（`~/.zshrc`）に以下を追加：

```bash
# GitHub MCP用のPersonal Access Token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

設定を反映：

```bash
source ~/.zshrc
```

### 4. MCP設定ファイルのバックアップ

```bash
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup
```

### 5. GitHub MCP設定の追加

`~/.cursor/mcp.json` を編集し、GitHub MCP設定を追加します。

**重要**: トークンは `${GITHUB_TOKEN}` で環境変数から参照し、直接書かないでください。

### 6. Cursorの再起動

設定を反映するためにCursorを完全に再起動します：
- Cursorを完全に終了（Cmd+Q）
- ターミナルから `source ~/.zshrc` を実行（環境変数を反映）
- Cursorを起動
- チャットでMCPサーバーの接続状態を確認

## 利用可能な機能

GitHub MCPを設定すると、以下の操作がCursorから実行可能になります：

- **リポジトリ操作**
  - リポジトリの検索・取得
  - ファイル内容の読み取り
  - ブランチ一覧の取得

- **Issue管理**
  - Issueの一覧取得
  - Issueの作成・更新
  - Issueへのコメント追加

- **Pull Request管理**
  - PRの一覧取得
  - PRの作成・更新
  - PRのレビュー

- **その他**
  - コミット履歴の取得
  - ユーザー情報の取得
  - 組織情報の取得

## トラブルシューティング

### MCPサーバーが起動しない場合

1. **環境変数が設定されているか確認**
   ```bash
   echo $GITHUB_TOKEN
   # トークンが表示されればOK
   ```

2. **Node.jsのパスが正しいか確認**
   ```bash
   which npx
   node --version
   ```

3. **Personal Access Tokenが有効か確認**
   ```bash
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   ```

4. **Cursorのログを確認**
   - Help → Toggle Developer Tools
   - Consoleタブでエラーメッセージを確認

### 環境変数が読み込まれない場合

1. シェル設定ファイルを再読み込み：
   ```bash
   source ~/.zshrc
   ```

2. Cursorを完全に再起動（Cmd+Q → 起動）

3. それでも動かない場合は、ターミナルからCursorを起動：
   ```bash
   open -a Cursor
   ```

### 権限エラーが発生する場合

Personal Access Tokenのスコープを確認し、必要な権限が付与されているか確認してください。

### パッケージのインストールエラー

手動でパッケージをインストールして確認：
```bash
npx -y @modelcontextprotocol/server-github
```

## セキュリティ上の注意

### 必須事項

- **トークンはmcp.jsonに直接書かない** → 環境変数を使用
- **Personal Access Tokenを共有しない**
- **トークンは定期的にローテーションする**
- **最小限の権限スコープのみを付与する**
- **mcp.jsonファイルをgitにコミットしない**
- **チーム共有する場合は、各自が自分のトークンを設定する**

### なぜ環境変数を使用するのか

1. **LLMへの露出防止**: mcp.jsonをLLMが読み取ってもトークンは表示されない
2. **チャット履歴への残存防止**: トークンがチャット履歴に残らない
3. **設定ファイルの共有が可能**: mcp.jsonをチームで共有しても安全

## 参考情報

- [Model Context Protocol - GitHub Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

## 次のステップ

設定完了後、Cursorのチャットで以下のように試してみてください：

```
@github リポジトリの最新のIssueを5件取得して
```

```
@github Pull Requestの一覧を表示して
```