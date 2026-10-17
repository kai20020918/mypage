#!/usr/bin/env bash
# ConoHa VPS を「GitHub Actions → VPS → WING」の中継役にする初期設定。
# VPS 上で1回だけ実行する:  sudo bash /tmp/vps-setup.sh /tmp/wing_key.pem
#
# やること:
#   1. 中継専用ユーザー webdeploy を作る（sudo 権限なし）
#   2. WING の秘密鍵と接続情報を webdeploy に置き、VPS から WING に入れるか確認
#   3. GitHub Actions が VPS に入るための鍵を作り、秘密鍵を画面に表示（GitHub に登録する）
set -euo pipefail

DEPLOY_USER=webdeploy
WING_KEY_SRC="${1:-}"

[[ $EUID -eq 0 ]] || { echo "sudo を付けて実行してください"; exit 1; }
[[ -f "$WING_KEY_SRC" ]] || { echo "使い方: sudo bash $0 /tmp/wing_key.pem"; exit 1; }

command -v rsync >/dev/null || { apt-get update -q && apt-get install -y -q rsync; }

if ! id "$DEPLOY_USER" &>/dev/null; then
  useradd --create-home --shell /bin/bash "$DEPLOY_USER"
  echo "ユーザー $DEPLOY_USER を作成しました"
fi
H=$(getent passwd "$DEPLOY_USER" | cut -d: -f6)
install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "$H/.ssh" "$H/.config"

# --- WING の鍵と接続情報 ---------------------------------------------------
install -m 600 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "$WING_KEY_SRC" "$H/.ssh/wing_key"
tr -d '\r' < "$H/.ssh/wing_key" > "$H/.ssh/wing_key.tmp" && mv "$H/.ssh/wing_key.tmp" "$H/.ssh/wing_key"
chown "$DEPLOY_USER:$DEPLOY_USER" "$H/.ssh/wing_key"; chmod 600 "$H/.ssh/wing_key"
shred -u "$WING_KEY_SRC" 2>/dev/null || rm -f "$WING_KEY_SRC"
echo "WING の鍵を配置し、コピー元（$WING_KEY_SRC）は削除しました"

ask() { local v; read -rp "$1 [$2]: " v; echo "${v:-$2}"; }
WING_HOST=$(ask "WING のホスト名" "www1191.conoha.ne.jp")
WING_USER=$(ask "WING のユーザー名" "c7426743")
WING_PATH=$(ask "公開フォルダ（ホームからの相対パス）" "public_html/cafe-web.com")
WING_PORT=$(ask "WING の SSH ポート" "8022")

cat > "$H/.config/wing-deploy.env" <<ENV
WING_HOST=$WING_HOST
WING_USER=$WING_USER
WING_PATH=$WING_PATH
WING_PORT=$WING_PORT
ENV
chown "$DEPLOY_USER:$DEPLOY_USER" "$H/.config/wing-deploy.env"; chmod 600 "$H/.config/wing-deploy.env"

ssh-keyscan -p "$WING_PORT" "$WING_HOST" 2>/dev/null > "$H/.ssh/known_hosts"
chown "$DEPLOY_USER:$DEPLOY_USER" "$H/.ssh/known_hosts"

echo "VPS から WING への接続を確認します..."
if sudo -u "$DEPLOY_USER" ssh -p "$WING_PORT" -i "$H/.ssh/wing_key" -o BatchMode=yes -o ConnectTimeout=20 \
     "$WING_USER@$WING_HOST" "test -d '$WING_PATH'"; then
  echo "OK: VPS から WING の公開フォルダ（$WING_PATH）に接続できました"
else
  echo "NG: VPS から WING に接続できませんでした。ここで止めます"; exit 1
fi

# --- GitHub Actions → VPS の鍵 ---------------------------------------------
TMPKEY=$(mktemp -u /tmp/gh_actions_key.XXXXXX)
ssh-keygen -q -t ed25519 -N '' -C "github-actions-portfolio" -f "$TMPKEY"
AK="$H/.ssh/authorized_keys"
touch "$AK"
grep -v 'github-actions-portfolio' "$AK" > "$AK.tmp" || true   # 以前の鍵は置き換える
echo "restrict $(cat "$TMPKEY.pub")" >> "$AK.tmp"
mv "$AK.tmp" "$AK"; chown "$DEPLOY_USER:$DEPLOY_USER" "$AK"; chmod 600 "$AK"

echo
echo "=================================================================="
echo " 下の BEGIN〜END を、GitHub の Secret「VPS_SSH_KEY」に登録してください"
echo "=================================================================="
cat "$TMPKEY"
echo "=================================================================="
shred -u "$TMPKEY" 2>/dev/null || rm -f "$TMPKEY"; rm -f "$TMPKEY.pub"
echo "VPS_USER には「$DEPLOY_USER」を登録してください。"
echo "（この秘密鍵は VPS から削除済みです。画面を閉じたら再表示できません。失った場合はこのスクリプトを再実行）"
