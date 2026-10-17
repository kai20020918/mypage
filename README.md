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

WING は海外（GitHub Actions のサーバー）からの SSH ログインを受け付けないため、
日本にある ConoHa VPS を中継して送っています。

```
git push → GitHub Actions → ConoHa VPS（webdeploy ユーザー） → ConoHa WING
```

| ファイル | 内容 |
|---|---|
| `workflows/deploy.yml` | push 時と手動実行時に動くワークフロー。VPS にファイルを送り、VPS で deploy.sh を実行 |
| `scripts/deploy.sh` | rsync で WING へ転送するスクリプト（VPS 上で実行される） |
| `scripts/vps-setup.sh` | VPS を中継役にする初期設定（最初に1回だけ） |

サーバー側の安全のため、次のように同期します。

- 直下のファイル（`index.html` など）は **上書き・追加のみ**。削除はしません。公開フォルダ自体の権限も変えません
- 直下のフォルダは **このリポジトリにあるものだけ** 同期し、その中では削除も反映します（例: `css/` から消したファイルはサーバーからも消える）
- リポジトリにないフォルダ（`strawberry/`・`error/` など）や `.htaccess` には **一切触れません**
- `README.md`・`.github/`・`.git*` はアップロードしません

### 手動実行（確認だけ / 再デプロイ）

Actions → **Deploy to ConoHa WING** → **Run workflow**。
「確認だけ」にチェックを入れたまま実行すると、サーバーは変更せずに、転送される予定のファイルだけをログに表示します。

## 必要な設定

### GitHub（Settings → Secrets and variables → Actions）

| Secret | 内容 |
|---|---|
| `VPS_HOST` | ConoHa VPS の IP アドレス |
| `VPS_USER` | `webdeploy` |
| `VPS_SSH_KEY` | `vps-setup.sh` が表示した秘密鍵（BEGIN〜END すべて） |
| `VPS_KNOWN_HOSTS`（任意） | 設定すると VPS の鍵を固定して検証します。未設定なら実行時に取得 |

VPS の SSH ポートが 22 以外なら、Variables に `VPS_PORT` を追加します。
Secrets が未登録のあいだは、デプロイは失敗せずスキップされます。

### VPS（最初に1回）

WING の秘密鍵と接続情報は VPS の `webdeploy` ユーザーにだけ置きます（GitHub には置きません）。

```powershell
# Windows から VPS へ、セットアップスクリプトと WING の秘密鍵を送る
scp D:\work\portfolio\.github\scripts\vps-setup.sh <VPSのユーザー>@<VPSのIP>:/tmp/
scp $HOME\.ssh\wing_key.pem <VPSのユーザー>@<VPSのIP>:/tmp/wing_key.pem
```

```bash
# VPS 上で
sudo bash /tmp/vps-setup.sh /tmp/wing_key.pem
```

WING の接続情報は `/home/webdeploy/.config/wing-deploy.env` に保存されます。変える場合はこのファイルを編集します。
