#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia"
CONFIG_FILE="$REPO_DIR/noctalia/state-backup/settings.toml"

for file in \
    "$REPO_DIR/assets/avatars/avatar.jpg" \
    "$REPO_DIR/assets/wallpapers/enaena2.png" \
    "$CONFIG_FILE"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Missing file: $file" >&2
        exit 1
    fi
done

mkdir -p "$STATE_DIR"

OUTPUT_FILE="$STATE_DIR/settings.toml"
TEMP_FILE="$(mktemp "${STATE_DIR}/settings.toml.XXXXXX")"
trap 'rm -f "$TEMP_FILE"' EXIT

sed \
    -e "s|ASSET_AVATAR_PATH|$REPO_DIR/assets/avatars/avatar.jpg|g" \
    -e "s|ASSET_WALLPAPER_PATH|$REPO_DIR/assets/wallpapers/enaena2.png|g" \
    "$CONFIG_FILE" > "$TEMP_FILE"

if grep -q 'ASSET_.*_PATH' "$TEMP_FILE"; then
    echo "Error: Unresolved asset placeholder; settings were not installed." >&2
    exit 1
fi

chmod 600 "$TEMP_FILE"
mv "$TEMP_FILE" "$OUTPUT_FILE"
trap - EXIT

echo "Noctalia settings restored to: $OUTPUT_FILE"
echo "Restart Noctalia to apply the settings."
