#!/usr/bin/env bash
# ConoHa WING へ rsync で公開する。
#
# 安全のための方針:
#   - 直下のファイル（index.html など）は上書き・追加だけ。削除はしない
#   - 直下のフォルダは「このリポジトリにあるものだけ」同期し、その中では削除も反映する
#   - リポジトリにないフォルダ（strawberry/ など）には一切触れない
#
# 環境変数: WING_HOST WING_USER WING_PATH WING_PORT(既定8022) SSH_KEY_FILE(既定 ~/.ssh/wing_key) DRY_RUN(true/false)
# ローカルテスト用: RSYNC_DEST を指定すると SSH を使わずそのパスへ同期する
set -euo pipefail
shopt -s nullglob

cd "$(dirname "$0")/../.."

EXCLUDES=(
  --exclude='.git' --exclude='.github' --exclude='.gitignore' --exclude='.gitattributes'
  --exclude='README.md' --exclude='Thumbs.db' --exclude='desktop.ini' --exclude='.DS_Store'
)
OPTS=(-rlptz --itemize-changes --chmod=D755,F644 "${EXCLUDES[@]}")
[[ "${DRY_RUN:-false}" == "true" ]] && OPTS+=(--dry-run) && echo "::notice::DRY RUN（サーバーは変更しません）"

if [[ -n "${RSYNC_DEST:-}" ]]; then
  DEST="${RSYNC_DEST%/}"
else
  : "${WING_HOST:?}" "${WING_USER:?}" "${WING_PATH:?}" 
  # 誤って public_html 全体やホームを指定しないよう、公開ディレクトリ配下だけ許可
  case "$WING_PATH" in
    */public_html/?*) ;;
    *) echo "::error::WING_PATH は .../public_html/<ドメイン> の形にしてください: $WING_PATH"; exit 1 ;;
  esac
  SSH_KEY_FILE="${SSH_KEY_FILE:-$HOME/.ssh/wing_key}"
  OPTS+=(-e "ssh -p ${WING_PORT:-8022} -i $SSH_KEY_FILE -o StrictHostKeyChecking=yes -o BatchMode=yes")
  DEST="${WING_USER}@${WING_HOST}:${WING_PATH%/}"
fi

echo "== 直下のファイル（削除なし）"
rsync "${OPTS[@]}" --exclude='*/' ./ "$DEST/"

for dir in */; do
  dir="${dir%/}"
  echo "== ${dir}/（削除も反映）"
  rsync "${OPTS[@]}" --delete "$dir/" "$DEST/$dir/"
done
