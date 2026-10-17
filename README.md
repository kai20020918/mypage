# Portfolio

ConoHa WING で公開しているポートフォリオサイトです。
`main` ブランチに push すると、GitHub Actions が自動で WING に反映します。

## 更新のしかた

```powershell
cd D:\work\portfolio
git add -A
git commit -m "変更内容"
git push
```

GitHub の **Actions** タブで結果を確認できます（緑のチェックなら完了）。

- css / js を読み込む `?v=...` は、デプロイ時にコミットIDへ自動で置き換わります。手で書き換える必要はありません
- 新しい作品は `js/projects-data.js` に1件追加します

## デプロイの仕組み（.github/）

| ファイル | 内容 |
|---|---|
| `workflows/deploy.yml` | push 時と手動実行時に動くワークフロー |
| `scripts/deploy.sh` | rsync で WING へ転送するスクリプト |

サーバー側の安全のため、次のように同期します。

- 直下のファイル（`index.html` など）は **上書き・追加のみ**。削除はしません
- 直下のフォルダは **このリポジトリにあるものだけ** 同期し、その中では削除も反映します（例: `css/` から消したファイルはサーバーからも消える）
- リポジトリにないフォルダ（`strawberry/` など）や `.htaccess` には **一切触れません**
- `README.md`・`.github/`・`.git*` はアップロードしません

### 手動実行（確認だけ / 再デプロイ）

Actions → **Deploy to ConoHa WING** → **Run workflow**。
「確認だけ」にチェックを入れたまま実行すると、サーバーは変更せずに、転送される予定のファイルだけをログに表示します。

## 必要な設定（GitHub → Settings → Secrets and variables → Actions）

| Secret | 例 | 内容 |
|---|---|---|
| `WING_SSH_KEY` | `-----BEGIN ... PRIVATE KEY-----` … | WING で作った SSH の秘密鍵（ファイルの中身すべて） |
| `WING_HOST` | `www123.conoha.ne.jp` | WING の SSH 接続情報のホスト名 |
| `WING_USER` | `c1234567` | WING の SSH 接続情報のユーザー名 |
| `WING_PATH` | `public_html/cafe-web.com` | サイトの公開フォルダ（ホームからの相対パス） |
| `WING_KNOWN_HOSTS`（任意） | | 設定するとサーバーの鍵を固定して検証します。未設定なら実行時に取得 |

SSH のポートは 8022 を使います（変える場合は Variables に `WING_PORT` を追加）。

Secrets が未登録のあいだは、デプロイは失敗せずスキップされます。
