# Boo shell integration for zsh.

BOO_PROMPT_FILE="$HOME/.config/boo/prompt"
BOO_DEFAULT_PROMPT_BACKEND="native"

# Optional mode override persisted by `boo mode`.
if [[ -f "$HOME/.config/boo/mode.zsh" ]]; then
  source "$HOME/.config/boo/mode.zsh"
fi

# Optional theme accents persisted by `boo theme`.
if [[ -f "$HOME/.config/boo/theme.zsh" ]]; then
  source "$HOME/.config/boo/theme.zsh"
fi

boo_read_prompt_backend() {
  local backend
  if [[ -f "$BOO_PROMPT_FILE" ]]; then
    backend="$(tr -d '[:space:]' < "$BOO_PROMPT_FILE" | tr '[:upper:]' '[:lower:]')"
    case "$backend" in
      native|omp)
        printf '%s\n' "$backend"
        return
        ;;
      *)
        ;;
    esac
  fi
  printf '%s\n' "$BOO_DEFAULT_PROMPT_BACKEND"
}

boo_effective_prompt_backend() {
  local configured
  configured="$(boo_read_prompt_backend)"
  if [[ "$configured" == "omp" ]] && ! command -v oh-my-posh >/dev/null 2>&1; then
    printf 'native\n'
    return
  fi
  printf '%s\n' "$configured"
}

boo_apply_highlight_colors() {
  local accent="${BOO_ACCENT_COLOR:-#a882ff}"
  if [[ -n ${ZSH_HIGHLIGHT_STYLES+x} ]]; then
    ZSH_HIGHLIGHT_STYLES[command]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[function]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=${accent}"
  fi
}

boo_remove_omp_hooks() {
  if typeset -p precmd_functions >/dev/null 2>&1; then
    precmd_functions=(${precmd_functions:#_omp_*})
  fi
  if typeset -p preexec_functions >/dev/null 2>&1; then
    preexec_functions=(${preexec_functions:#_omp_*})
  fi
}

boo_remove_native_prompt_hooks() {
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd boo_native_precmd 2>/dev/null || true
}

boo_native_precmd() {
  vcs_info
  if [[ -n "$vcs_info_msg_0_" ]]; then
    BOO_PROMPT_GIT_SEGMENT=" %F{${BOO_ACCENT_COLOR:-#a882ff}} $vcs_info_msg_0_%f"
  else
    BOO_PROMPT_GIT_SEGMENT=""
  fi
}

boo_apply_native_prompt() {
  autoload -Uz add-zsh-hook vcs_info
  boo_remove_native_prompt_hooks
  boo_remove_omp_hooks

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' formats '%b%u%c'
  zstyle ':vcs_info:git:*' actionformats '%b|%a'
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr '+'
  zstyle ':vcs_info:git:*' unstagedstr '*'

  setopt prompt_subst
  add-zsh-hook precmd boo_native_precmd
  boo_native_precmd

  PROMPT='%F{245}╭─%f%F{${BOO_ACCENT_COLOR:-#a882ff}}%f %F{252}%n%f %F{245}in%f %F{111}%~%f${BOO_PROMPT_GIT_SEGMENT}'$'\n''%F{245}╰─❯%f '
  RPROMPT='%(?..%F{196}✖ %?%f )%F{245}%D{%I:%M %p}%f'
}

boo_apply_omp_prompt() {
  boo_remove_native_prompt_hooks
  if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/boo.omp.json)"
    return 0
  fi
  return 1
}

boo_apply_prompt_backend() {
  local configured effective
  configured="$(boo_read_prompt_backend)"
  effective="$(boo_effective_prompt_backend)"

  export BOO_PROMPT_BACKEND="$configured"
  export BOO_PROMPT_BACKEND_EFFECTIVE="$effective"

  if [[ "$effective" == "omp" ]]; then
    if boo_apply_omp_prompt; then
      return 0
    fi
    export BOO_PROMPT_BACKEND_EFFECTIVE="native"
  fi

  boo_apply_native_prompt
  if [[ "$configured" == "omp" && -z "${BOO_OMP_FALLBACK_WARNED:-}" ]]; then
    export BOO_OMP_FALLBACK_WARNED=1
    printf 'boo: oh-my-posh not found, using native prompt fallback.\n' >&2
  fi
}

# Wrapper so mode/theme/prompt changes are reflected in the current shell immediately.
if ! typeset -f boo >/dev/null 2>&1; then
  boo() {
    if ! whence -p boo >/dev/null 2>&1; then
      printf 'boo CLI not found. Install it, then run: boo <command>\n' >&2
      return 1
    fi

    BOO_SHELL_WRAPPER=1 command boo "$@"
    local rc=$?
    if [[ $rc -ne 0 ]]; then
      return $rc
    fi

    case "${1:-}" in
      mode)
        if [[ -f "$HOME/.config/boo/mode.zsh" ]]; then
          source "$HOME/.config/boo/mode.zsh"
        fi
        ;;
      prompt)
        boo_apply_prompt_backend
        ;;
      theme|obsidian|graphite|lunar|crimson|matrix)
        if [[ -f "$HOME/.config/boo/theme.zsh" ]]; then
          source "$HOME/.config/boo/theme.zsh"
        fi
        boo_apply_prompt_backend
        boo_apply_highlight_colors
        ;;
      *)
        ;;
    esac

    return 0
  }
fi

boo-mode() {
  if command -v boo >/dev/null 2>&1; then
    boo mode "${1:-}"
  else
    printf 'boo CLI not found. Install it, then run: boo mode [full|public]\n' >&2
    return 1
  fi
}

boo-prompt() {
  if command -v boo >/dev/null 2>&1; then
    boo prompt "${1:-}"
  else
    printf 'boo CLI not found. Install it, then run: boo prompt [show|set <native|omp>]\n' >&2
    return 1
  fi
}

show_boo_startup_panel() {
  local panel_rgb="${BOO_PANEL_COLOR_RGB:-168;130;255}"
  local purple="\033[38;2;${panel_rgb}m"
  local dim='\033[38;2;148;163;184m'
  local reset='\033[0m'
  local now shell_name os_name os_ver cpu_cores cpu_arch total_bytes mem_total mem_public
  local show_private host_short kernel load_avg vm_out page_size active wired compressed used_bytes
  local mem_used model
  local -a logo info
  local i max left_col right_col
  local logo_len info_len logo_start info_start left_idx right_idx

  now="$(date '+%a %b %d, %I:%M %p')"
  shell_name="${SHELL##*/}"
  os_name="$(sw_vers -productName 2>/dev/null || uname -s)"
  os_ver="$(sw_vers -productVersion 2>/dev/null || uname -r)"
  cpu_cores="$(sysctl -n hw.ncpu 2>/dev/null || echo '-')"
  cpu_arch="$(uname -m 2>/dev/null || echo '-')"
  total_bytes="$(sysctl -n hw.memsize 2>/dev/null)"
  if [[ -n "$total_bytes" ]]; then
    mem_total="$(awk "BEGIN {printf \"%.1f\", ${total_bytes}/1073741824}")"
    mem_public="${mem_total} GB"
  else
    mem_total="-"
    mem_public="-"
  fi
  show_private="${BOO_SHOW_PRIVATE:-1}"

  logo=(
    "                    'c."
    "                 ,xNMM."
    "               .OMMMMo"
    "               OMMM0,"
    "     .;loddo:' loolloddol;."
    "   cKMMMMMMMMMMNWMMMMMMMMMM0:"
    " .KMMMMMMMMMMMMMMMMMMMMMMMWd."
    " XMMMMMMMMMMMMMMMMMMMMMMMX."
    ";MMMMMMMMMMMMMMMMMMMMMMMM:"
    ":MMMMMMMMMMMMMMMMMMMMMMMM:"
    ".MMMMMMMMMMMMMMMMMMMMMMMMX."
    " kMMMMMMMMMMMMMMMMMMMMMMMMWd."
    " .XMMMMMMMMMMMMMMMMMMMMMMMMMMk"
    "  .XMMMMMMMMMMMMMMMMMMMMMMMMK."
    "    kMMMMMMMMMMMMMMMMMMMMMMd"
    "     ;KMMMMMMMWXXWMMMMMMMk."
    "       .cooc,.    .,coo:."
  )

  if [[ "$show_private" == "1" ]]; then
    host_short="$(hostname -s 2>/dev/null || hostname)"
    kernel="$(uname -r 2>/dev/null)"
    model="$(sysctl -n hw.model 2>/dev/null || echo '-')"
    load_avg="$(sysctl -n vm.loadavg 2>/dev/null | tr -d '{}' | awk '{printf "%s %s %s", $1, $2, $3}')"
    [[ -z "${load_avg}" ]] && load_avg="-"

    vm_out="$(vm_stat 2>/dev/null)"
    page_size="$(printf '%s\n' "$vm_out" | awk '/page size of/ {gsub("\\.","",$8); print $8}')"
    active="$(printf '%s\n' "$vm_out" | awk '/Pages active/ {gsub("\\.","",$3); print $3}')"
    wired="$(printf '%s\n' "$vm_out" | awk '/Pages wired down/ {gsub("\\.","",$4); print $4}')"
    compressed="$(printf '%s\n' "$vm_out" | awk '/Pages occupied by compressor/ {gsub("\\.","",$5); print $5}')"

    if [[ -n "$page_size" && -n "$active" && -n "$wired" && -n "$compressed" ]]; then
      used_bytes=$(( (active + wired + compressed) * page_size ))
      mem_used="$(awk "BEGIN {printf \"%.1f\", ${used_bytes}/1073741824}")"
    else
      mem_used="-"
    fi

    info=(
      "${USER}@${host_short}"
      "------------------------------"
      "OS      : ${os_name} ${os_ver}"
      "KERNEL  : ${kernel}"
      "SHELL   : ${shell_name}"
      "MODEL   : ${model}"
      "CPU     : ${cpu_cores} cores (${cpu_arch})"
      "LOAD    : ${load_avg}"
      "MEMORY  : ${mem_used}/${mem_total} GB"
      "TIME    : ${now}"
    )
  else
    info=(
      "boo"
      "------------------------------"
      "PROFILE : public-safe"
      "OS      : ${os_name} ${os_ver}"
      "SHELL   : ${shell_name}"
      "CPU     : ${cpu_cores} cores (${cpu_arch})"
      "MEMORY  : ${mem_public}"
      "TIME    : ${now}"
    )
  fi

  logo_len=${#logo[@]}
  info_len=${#info[@]}
  max=$(( logo_len > info_len ? logo_len : info_len ))
  logo_start=$(( (max - logo_len) / 2 + 1 ))
  info_start=$(( (max - info_len) / 2 + 1 ))

  for (( i = 1; i <= max; i++ )); do
    left_col=""
    right_col=""

    if (( i >= logo_start && i < logo_start + logo_len )); then
      left_idx=$(( i - logo_start + 1 ))
      left_col="${logo[left_idx]}"
    fi

    if (( i >= info_start && i < info_start + info_len )); then
      right_idx=$(( i - info_start + 1 ))
      right_col="${info[right_idx]}"
    fi

    printf '%b%-30s%b  %b%s%b\n' "$purple" "$left_col" "$reset" "$dim" "$right_col" "$reset"
  done
  printf '\n'
}

if [[ -o interactive && "$TERM_PROGRAM" == "ghostty" && "${SHLVL:-1}" == "1" && -z "${GHOSTTY_STARTUP_PANEL_SHOWN:-}" ]]; then
  export GHOSTTY_STARTUP_PANEL_SHOWN=1
  show_boo_startup_panel
fi

boo_apply_prompt_backend
boo_apply_highlight_colors
