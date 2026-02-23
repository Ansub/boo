#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BOO_BACKUP_DIR="$HOME/.config/boo/backups"
GHOSTTY_ORIGINAL_PRIMARY="$BOO_BACKUP_DIR/ghostty-config-primary.original"
GHOSTTY_ORIGINAL_MAC="$BOO_BACKUP_DIR/ghostty-config-mac.original"
BOO_GHOSTTY_MARKER="# Boo managed Ghostty config"

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    cp "$file" "${file}.backup-${STAMP}"
    echo "Backed up: $file -> ${file}.backup-${STAMP}"
  fi
}

is_boo_ghostty_config() {
  local file="$1"
  [[ -f "$file" ]] || return 1

  if grep -qF "$BOO_GHOSTTY_MARKER" "$file"; then
    return 0
  fi

  if grep -qF "theme = Phala Green Dark" "$file" \
    && grep -qF "window-padding-color = extend" "$file" \
    && grep -qF "shell-integration = zsh" "$file"; then
    return 0
  fi

  return 1
}

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/boo" "$HOME/.local/bin" "$BOO_BACKUP_DIR"

if [[ -f "$HOME/.config/ghostty/config" ]] && [[ ! -f "$GHOSTTY_ORIGINAL_PRIMARY" ]]; then
  if is_boo_ghostty_config "$HOME/.config/ghostty/config"; then
    echo "Skipped saving original Ghostty config (already Boo-managed): ~/.config/ghostty/config"
  else
    cp "$HOME/.config/ghostty/config" "$GHOSTTY_ORIGINAL_PRIMARY"
    echo "Saved original Ghostty config -> $GHOSTTY_ORIGINAL_PRIMARY"
  fi
fi

backup_file "$HOME/.config/ghostty/config"
cp "$REPO_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
echo "Installed Ghostty config -> ~/.config/ghostty/config"

# Some macOS installs use this path.
MAC_GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [[ -f "$MAC_GHOSTTY" ]]; then
  mkdir -p "$(dirname "$MAC_GHOSTTY")"
  if [[ ! -f "$GHOSTTY_ORIGINAL_MAC" ]]; then
    if is_boo_ghostty_config "$MAC_GHOSTTY"; then
      echo "Skipped saving original Ghostty config (already Boo-managed): $MAC_GHOSTTY"
    else
      cp "$MAC_GHOSTTY" "$GHOSTTY_ORIGINAL_MAC"
      echo "Saved original Ghostty config -> $GHOSTTY_ORIGINAL_MAC"
    fi
  fi
  backup_file "$MAC_GHOSTTY"
  cp "$REPO_DIR/configs/ghostty/config" "$MAC_GHOSTTY"
  echo "Installed Ghostty config -> $MAC_GHOSTTY"
fi

backup_file "$HOME/.config/ohmyposh/boo.omp.json"
PROMPT_PRESET="$REPO_DIR/configs/ohmyposh/presets/abyss.omp.json"
if [[ ! -f "$PROMPT_PRESET" ]]; then
  PROMPT_PRESET="$REPO_DIR/configs/ohmyposh/presets/obsidian.omp.json"
fi
cp "$PROMPT_PRESET" "$HOME/.config/ohmyposh/boo.omp.json"
echo "Installed prompt theme -> ~/.config/ohmyposh/boo.omp.json"

mkdir -p "$HOME/.config/boo/ohmyposh"
cp "$REPO_DIR"/configs/ohmyposh/presets/*.omp.json "$HOME/.config/boo/ohmyposh/"
echo "Installed prompt presets -> ~/.config/boo/ohmyposh/"

cp "$REPO_DIR/shell/boo.zsh" "$HOME/.config/boo/boo.zsh"
echo "Installed shell snippet -> ~/.config/boo/boo.zsh"

mkdir -p "$HOME/.config/boo/art"
cp "$REPO_DIR"/art/*.txt "$HOME/.config/boo/art/"
echo "Installed splash art -> ~/.config/boo/art/"

if [[ ! -f "$HOME/.config/boo/theme.zsh" ]]; then
  cat > "$HOME/.config/boo/theme.zsh" <<'THEMEBLOCK'
export BOO_THEME="abyss"
export BOO_ACCENT_COLOR="#cc44ff"
export BOO_PANEL_COLOR_RGB="204;68;255"
THEMEBLOCK
  echo "Initialized theme accents -> ~/.config/boo/theme.zsh"
fi

if [[ ! -f "$HOME/.config/boo/theme" ]]; then
  printf 'abyss\n' > "$HOME/.config/boo/theme"
  echo "Initialized selected theme -> ~/.config/boo/theme (abyss)"
fi

if [[ ! -f "$HOME/.config/boo/prompt" ]]; then
  printf 'native\n' > "$HOME/.config/boo/prompt"
  echo "Initialized prompt backend -> ~/.config/boo/prompt (native)"
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
