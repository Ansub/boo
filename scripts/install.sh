#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    cp "$file" "${file}.backup-${STAMP}"
    echo "Backed up: $file -> ${file}.backup-${STAMP}"
  fi
}

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/obsighost"

backup_file "$HOME/.config/ghostty/config"
cp "$REPO_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
echo "Installed Ghostty config -> ~/.config/ghostty/config"

# Some macOS installs use this path.
MAC_GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [[ -f "$MAC_GHOSTTY" || -d "$(dirname "$MAC_GHOSTTY")" ]]; then
  mkdir -p "$(dirname "$MAC_GHOSTTY")"
  backup_file "$MAC_GHOSTTY"
  cp "$REPO_DIR/configs/ghostty/config" "$MAC_GHOSTTY"
  echo "Installed Ghostty config -> $MAC_GHOSTTY"
fi

backup_file "$HOME/.config/ohmyposh/obsighost.omp.json"
cp "$REPO_DIR/configs/ohmyposh/obsighost.omp.json" "$HOME/.config/ohmyposh/obsighost.omp.json"
echo "Installed prompt theme -> ~/.config/ohmyposh/obsighost.omp.json"

cp "$REPO_DIR/shell/obsighost.zsh" "$HOME/.config/obsighost/obsighost.zsh"
echo "Installed shell snippet -> ~/.config/obsighost/obsighost.zsh"

if [[ ! -f "$HOME/.zshrc" ]]; then
  touch "$HOME/.zshrc"
fi

START_MARK="# >>> ObsiGhost >>>"
END_MARK="# <<< ObsiGhost <<<"

if ! grep -qF "$START_MARK" "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'ZSHBLOCK'

# >>> ObsiGhost >>>
if [[ -f "$HOME/.config/obsighost/obsighost.zsh" ]]; then
  source "$HOME/.config/obsighost/obsighost.zsh"
fi
# <<< ObsiGhost <<<
ZSHBLOCK
  echo "Added ObsiGhost source block to ~/.zshrc"
else
  echo "ObsiGhost block already exists in ~/.zshrc (skipped append)."
fi

echo
echo "Done. Open a new Ghostty window or run: source ~/.zshrc"
