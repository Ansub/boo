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

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/boo" "$HOME/.local/bin"

backup_file "$HOME/.config/ghostty/config"
cp "$REPO_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
echo "Installed Ghostty config -> ~/.config/ghostty/config"

# Some macOS installs use this path.
MAC_GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [[ -f "$MAC_GHOSTTY" ]]; then
  mkdir -p "$(dirname "$MAC_GHOSTTY")"
  backup_file "$MAC_GHOSTTY"
  cp "$REPO_DIR/configs/ghostty/config" "$MAC_GHOSTTY"
  echo "Installed Ghostty config -> $MAC_GHOSTTY"
fi

backup_file "$HOME/.config/ohmyposh/boo.omp.json"
cp "$REPO_DIR/configs/ohmyposh/presets/obsidian.omp.json" "$HOME/.config/ohmyposh/boo.omp.json"
echo "Installed prompt theme -> ~/.config/ohmyposh/boo.omp.json"

mkdir -p "$HOME/.config/boo/ohmyposh"
cp "$REPO_DIR"/configs/ohmyposh/presets/*.omp.json "$HOME/.config/boo/ohmyposh/"
echo "Installed prompt presets -> ~/.config/boo/ohmyposh/"

cp "$REPO_DIR/shell/boo.zsh" "$HOME/.config/boo/boo.zsh"
echo "Installed shell snippet -> ~/.config/boo/boo.zsh"

if [[ ! -f "$HOME/.config/boo/theme.zsh" ]]; then
  cat > "$HOME/.config/boo/theme.zsh" <<'THEMEBLOCK'
export BOO_THEME="obsidian"
export BOO_ACCENT_COLOR="#a882ff"
export BOO_PANEL_COLOR_RGB="168;130;255"
THEMEBLOCK
  echo "Initialized theme accents -> ~/.config/boo/theme.zsh"
fi

backup_file "$HOME/.local/bin/boo"
cp "$REPO_DIR/bin/boo" "$HOME/.local/bin/boo"
chmod +x "$HOME/.local/bin/boo"
echo "Installed CLI -> ~/.local/bin/boo"

if [[ ! -f "$HOME/.zshrc" ]]; then
  touch "$HOME/.zshrc"
fi

if ! grep -q 'PATH=.*\.local/bin' "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'PATHBLOCK'

export PATH="$HOME/.local/bin:$PATH"
PATHBLOCK
  echo "Added ~/.local/bin to PATH in ~/.zshrc"
fi

START_MARK="# >>> Boo >>>"
END_MARK="# <<< Boo <<<"

if ! grep -qF "$START_MARK" "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'ZSHBLOCK'

# >>> Boo >>>
if [[ -f "$HOME/.config/boo/boo.zsh" ]]; then
  source "$HOME/.config/boo/boo.zsh"
fi
# <<< Boo <<<
ZSHBLOCK
  echo "Added Boo source block to ~/.zshrc"
else
  echo "Boo block already exists in ~/.zshrc (skipped append)."
fi

echo
echo "Done. Open a new Ghostty window or run: source ~/.zshrc"
