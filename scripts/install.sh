#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BOO_BACKUP_DIR="$HOME/.config/boo/backups"
GHOSTTY_ORIGINAL_PRIMARY="$BOO_BACKUP_DIR/ghostty-config-primary.original"
GHOSTTY_ORIGINAL_MAC="$BOO_BACKUP_DIR/ghostty-config-mac.original"
BOO_GHOSTTY_MARKER="# Boo managed Ghostty config"
PRIMARY_GHOSTTY="$HOME/.config/ghostty/config"
MAC_GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
ZSHRC_FILE="$HOME/.zshrc"

if [[ -t 1 && -z "${NO_COLOR:-}" && "${TERM:-}" != "dumb" ]]; then
  C_RESET=$'\033[0m'
  C_TITLE=$'\033[1;38;5;141m'
  C_OK=$'\033[38;5;82m'
  C_INFO=$'\033[38;5;111m'
  C_WARN=$'\033[38;5;214m'
  C_DIM=$'\033[38;5;244m'
  C_ERR=$'\033[38;5;196m'
else
  C_RESET=""
  C_TITLE=""
  C_OK=""
  C_INFO=""
  C_WARN=""
  C_DIM=""
  C_ERR=""
fi

COUNT_OK=0
COUNT_INFO=0
COUNT_SKIP=0
COUNT_BACKUP=0
COUNT_ERR=0

short_path() {
  local path="$1"
  printf '%s' "${path/#$HOME/~}"
}

render_boo_ascii() {
  local art_file="$REPO_DIR/art/boo.txt"
  if [[ -f "$art_file" ]]; then
    while IFS= read -r line; do
      printf "%s%s%s\n" "$C_TITLE" "$line" "$C_RESET"
    done < "$art_file"
    return
  fi
  printf "%sBOO%s\n" "$C_TITLE" "$C_RESET"
}

log_header() {
  printf "\n"
  render_boo_ascii
  printf "\n"
}

log_section() {
  printf "\n%s== %s ==%s\n" "$C_TITLE" "$1" "$C_RESET"
}

log_ok() {
  COUNT_OK=$((COUNT_OK + 1))
  printf "  %s[ok]%s %s\n" "$C_OK" "$C_RESET" "$1"
}

log_info() {
  COUNT_INFO=$((COUNT_INFO + 1))
  printf "  %s[..]%s %s\n" "$C_INFO" "$C_RESET" "$1"
}

log_skip() {
  COUNT_SKIP=$((COUNT_SKIP + 1))
  printf "  %s[skip]%s %s\n" "$C_WARN" "$C_RESET" "$1"
}

log_backup() {
  COUNT_BACKUP=$((COUNT_BACKUP + 1))
  printf "  %s[backup]%s %s\n" "$C_DIM" "$C_RESET" "$1"
}

log_fail() {
  COUNT_ERR=$((COUNT_ERR + 1))
  printf "  %s[error]%s %s\n" "$C_ERR" "$C_RESET" "$1" >&2
}

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.backup-${STAMP}"
    cp "$file" "$backup"
    log_backup "$(short_path "$file") -> $(short_path "$backup")"
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

on_install_error() {
  local exit_code=$?
  printf "\n" >&2
  log_fail "Install failed before completion."
  log_fail "Re-run with: bash -x scripts/install.sh"
  exit "$exit_code"
}

trap on_install_error ERR

log_header

log_section "Preparing"
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/boo" "$HOME/.local/bin" "$BOO_BACKUP_DIR"
log_ok "Ensured config directories under ~/.config and ~/.local/bin"

log_section "Ghostty"
if [[ -f "$PRIMARY_GHOSTTY" ]] && [[ ! -f "$GHOSTTY_ORIGINAL_PRIMARY" ]]; then
  if is_boo_ghostty_config "$PRIMARY_GHOSTTY"; then
    log_skip "Original Ghostty backup skipped (already Boo-managed): $(short_path "$PRIMARY_GHOSTTY")"
  else
    cp "$PRIMARY_GHOSTTY" "$GHOSTTY_ORIGINAL_PRIMARY"
    log_ok "Saved original Ghostty config: $(short_path "$GHOSTTY_ORIGINAL_PRIMARY")"
  fi
fi

backup_file "$PRIMARY_GHOSTTY"
cp "$REPO_DIR/configs/ghostty/config" "$PRIMARY_GHOSTTY"
log_ok "Installed Ghostty config: $(short_path "$PRIMARY_GHOSTTY")"

# Some macOS installs use this path.
if [[ -f "$MAC_GHOSTTY" ]]; then
  mkdir -p "$(dirname "$MAC_GHOSTTY")"
  if [[ ! -f "$GHOSTTY_ORIGINAL_MAC" ]]; then
    if is_boo_ghostty_config "$MAC_GHOSTTY"; then
      log_skip "Original Ghostty backup skipped (already Boo-managed): $(short_path "$MAC_GHOSTTY")"
    else
      cp "$MAC_GHOSTTY" "$GHOSTTY_ORIGINAL_MAC"
      log_ok "Saved original Ghostty config: $(short_path "$GHOSTTY_ORIGINAL_MAC")"
    fi
  fi
  backup_file "$MAC_GHOSTTY"
  cp "$REPO_DIR/configs/ghostty/config" "$MAC_GHOSTTY"
  log_ok "Installed Ghostty config: $(short_path "$MAC_GHOSTTY")"
else
  log_info "Skipped macOS app-support Ghostty config (file not present)"
fi

log_section "Prompt and shell assets"
backup_file "$HOME/.config/ohmyposh/boo.omp.json"
PROMPT_PRESET="$REPO_DIR/configs/ohmyposh/presets/abyss.omp.json"
if [[ ! -f "$PROMPT_PRESET" ]]; then
  PROMPT_PRESET="$REPO_DIR/configs/ohmyposh/presets/obsidian.omp.json"
fi
cp "$PROMPT_PRESET" "$HOME/.config/ohmyposh/boo.omp.json"
log_ok "Installed prompt theme: ~/.config/ohmyposh/boo.omp.json"

mkdir -p "$HOME/.config/boo/ohmyposh"
cp "$REPO_DIR"/configs/ohmyposh/presets/*.omp.json "$HOME/.config/boo/ohmyposh/"
log_ok "Installed prompt presets: ~/.config/boo/ohmyposh/"

cp "$REPO_DIR/shell/boo.zsh" "$HOME/.config/boo/boo.zsh"
log_ok "Installed shell snippet: ~/.config/boo/boo.zsh"

mkdir -p "$HOME/.config/boo/art"
cp "$REPO_DIR"/art/*.txt "$HOME/.config/boo/art/"
log_ok "Installed splash art: ~/.config/boo/art/"

log_section "Defaults"
if [[ ! -f "$HOME/.config/boo/theme.zsh" ]]; then
  cat > "$HOME/.config/boo/theme.zsh" <<'THEMEBLOCK'
export BOO_THEME="abyss"
export BOO_ACCENT_COLOR="#cc44ff"
export BOO_PANEL_COLOR_RGB="204;68;255"
THEMEBLOCK
  log_ok "Initialized theme accents: ~/.config/boo/theme.zsh"
else
  log_skip "Keeping existing theme accents: ~/.config/boo/theme.zsh"
fi

if [[ ! -f "$HOME/.config/boo/theme" ]]; then
  printf 'abyss\n' > "$HOME/.config/boo/theme"
  log_ok "Initialized selected theme: ~/.config/boo/theme (abyss)"
else
  log_skip "Keeping existing selected theme: ~/.config/boo/theme"
fi

if [[ ! -f "$HOME/.config/boo/prompt" ]]; then
  printf 'native\n' > "$HOME/.config/boo/prompt"
  log_ok "Initialized prompt backend: ~/.config/boo/prompt (native)"
else
  log_skip "Keeping existing prompt backend: ~/.config/boo/prompt"
fi

log_section "CLI and shell integration"
backup_file "$HOME/.local/bin/boo"
cp "$REPO_DIR/bin/boo" "$HOME/.local/bin/boo"
chmod +x "$HOME/.local/bin/boo"
log_ok "Installed CLI: ~/.local/bin/boo"

if [[ ! -f "$ZSHRC_FILE" ]]; then
  touch "$ZSHRC_FILE"
  log_info "Created ~/.zshrc"
fi

if ! grep -q 'PATH=.*\.local/bin' "$ZSHRC_FILE"; then
  cat >> "$ZSHRC_FILE" <<'PATHBLOCK'

export PATH="$HOME/.local/bin:$PATH"
PATHBLOCK
  log_ok "Added ~/.local/bin to PATH in ~/.zshrc"
else
  log_skip "~/.local/bin already present in ~/.zshrc"
fi

START_MARK="# >>> Boo >>>"
END_MARK="# <<< Boo <<<"

if ! grep -qF "$START_MARK" "$ZSHRC_FILE"; then
  cat >> "$ZSHRC_FILE" <<'ZSHBLOCK'

# >>> Boo >>>
if [[ -f "$HOME/.config/boo/boo.zsh" ]]; then
  source "$HOME/.config/boo/boo.zsh"
fi
# <<< Boo <<<
ZSHBLOCK
  log_ok "Added Boo source block to ~/.zshrc"
else
  log_skip "Boo source block already exists in ~/.zshrc"
fi

printf "\n%sInstall complete.%s\n\n" "$C_OK" "$C_RESET"
printf "%sSummary:%s ok=%d skip=%d backup=%d info=%d error=%d\n\n" \
  "$C_TITLE" "$C_RESET" "$COUNT_OK" "$COUNT_SKIP" "$COUNT_BACKUP" "$COUNT_INFO" "$COUNT_ERR"
printf "%sNext steps%s\n" "$C_TITLE" "$C_RESET"
printf "  1) Run: source ~/.zshrc\n"
printf "     (skip if you already ran it after install)\n"
printf "  2) In Ghostty, press Cmd+Shift+, to reload config now\n"
printf "     (or open a new Ghostty window)\n"
printf "  3) Or run: boo reload --unsafe\n"
printf "  4) Optional: run boo doctor\n"
