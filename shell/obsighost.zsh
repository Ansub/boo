# ObsiGhost shell integration for zsh.

if [[ -z "${OBSIGHOST_OMP_INIT_DONE:-}" ]]; then
  export OBSIGHOST_OMP_INIT_DONE=1
  if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/obsighost.omp.json)"
  fi
fi

# Optional mode override persisted by `obsighost mode`.
if [[ -f "$HOME/.config/obsighost/mode.zsh" ]]; then
  source "$HOME/.config/obsighost/mode.zsh"
fi

# Optional theme accents persisted by `obsighost theme`.
if [[ -f "$HOME/.config/obsighost/theme.zsh" ]]; then
  source "$HOME/.config/obsighost/theme.zsh"
fi

obsighost_apply_highlight_colors() {
  local accent="${OBSIGHOST_ACCENT_COLOR:-#a882ff}"
  if [[ -n ${ZSH_HIGHLIGHT_STYLES+x} ]]; then
    ZSH_HIGHLIGHT_STYLES[command]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[function]="fg=${accent}"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=${accent}"
  fi
}

# Wrapper so mode changes are reflected in the current shell immediately.
if ! typeset -f obsighost >/dev/null 2>&1; then
  obsighost() {
    if ! whence -p obsighost >/dev/null 2>&1; then
      printf 'obsighost CLI not found. Install it, then run: obsighost <command>\n' >&2
      return 1
    fi

    command obsighost "$@"
    local rc=$?
    if [[ $rc -eq 0 ]]; then
      if [[ "${1:-}" == "mode" && -f "$HOME/.config/obsighost/mode.zsh" ]]; then
        source "$HOME/.config/obsighost/mode.zsh"
      fi
      if [[ "${1:-}" == "theme" ]]; then
        if [[ -f "$HOME/.config/obsighost/theme.zsh" ]]; then
          source "$HOME/.config/obsighost/theme.zsh"
        fi
        if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null 2>&1; then
          eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/obsighost.omp.json)"
        fi
        obsighost_apply_highlight_colors
      fi
    fi
    return $rc
  }
fi

obsighost-mode() {
  if command -v obsighost >/dev/null 2>&1; then
    obsighost mode "${1:-}"
  else
    printf 'obsighost CLI not found. Install it, then run: obsighost mode [full|public]\n' >&2
    return 1
  fi
}

show_obsighost_startup_panel() {
  local panel_rgb="${OBSIGHOST_PANEL_COLOR_RGB:-168;130;255}"
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
  show_private="${OBSIGHOST_SHOW_PRIVATE:-1}"

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
      "obsighost"
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
  show_obsighost_startup_panel
fi

# Purple syntax highlighting accents.
obsighost_apply_highlight_colors
