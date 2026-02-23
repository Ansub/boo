#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="${BOO_REPO_SLUG:-Ansub/boo}"
REF="${BOO_REF:-main}"
TARBALL_URL="${BOO_TARBALL_URL:-https://github.com/${REPO_SLUG}/archive/refs/heads/${REF}.tar.gz}"

if [[ -t 1 && -z "${NO_COLOR:-}" && "${TERM:-}" != "dumb" ]]; then
  C_RESET=$'\033[0m'
  C_TITLE=$'\033[1;38;5;141m'
  C_OK=$'\033[38;5;82m'
  C_INFO=$'\033[38;5;111m'
  C_ERR=$'\033[38;5;196m'
  C_DIM=$'\033[38;5;244m'
else
  C_RESET=""
  C_TITLE=""
  C_OK=""
  C_INFO=""
  C_ERR=""
  C_DIM=""
fi

COUNT_OK=0
COUNT_INFO=0
COUNT_ERR=0

log_header() {
  printf "\n%sBoo Bootstrap%s\n" "$C_TITLE" "$C_RESET"
  printf "%sDownloading and launching the installer%s\n\n" "$C_DIM" "$C_RESET"
}

log_info() {
  COUNT_INFO=$((COUNT_INFO + 1))
  printf "  %s[..]%s %s\n" "$C_INFO" "$C_RESET" "$1"
}

log_ok() {
  COUNT_OK=$((COUNT_OK + 1))
  printf "  %s[ok]%s %s\n" "$C_OK" "$C_RESET" "$1"
}

log_fail() {
  COUNT_ERR=$((COUNT_ERR + 1))
  printf "  %s[error]%s %s\n" "$C_ERR" "$C_RESET" "$1" >&2
}

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_fail "Missing required command: $cmd"
    exit 1
  fi
}

on_bootstrap_error() {
  local exit_code=$?
  printf "\n" >&2
  log_fail "Bootstrap failed before completion."
  log_fail "Please retry the install command."
  exit "$exit_code"
}

trap on_bootstrap_error ERR

log_header
log_info "Checking required commands"
need_cmd bash
need_cmd curl
need_cmd tar
need_cmd mktemp
log_ok "Requirements satisfied"

workdir="$(mktemp -d)"
archive="${workdir}/boo.tar.gz"

cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

log_info "Downloading Boo (${REPO_SLUG}@${REF})"
curl -fsSL "$TARBALL_URL" -o "$archive"
log_ok "Download complete"

log_info "Extracting archive"
tar -xzf "$archive" -C "$workdir"
log_ok "Extraction complete"

top_entry="$(tar -tzf "$archive" | head -n1)"
top_dir="${top_entry%%/*}"
repo_dir="${workdir}/${top_dir}"

if [[ ! -f "${repo_dir}/scripts/install.sh" ]] && [[ -f "${workdir}/scripts/install.sh" ]]; then
  repo_dir="$workdir"
fi

if [[ ! -f "${repo_dir}/scripts/install.sh" ]]; then
  log_fail "Failed to locate scripts/install.sh after extraction."
  exit 1
fi

log_info "Launching installer"
bash "${repo_dir}/scripts/install.sh"
log_ok "Installer finished"
printf "\n%sSummary:%s ok=%d info=%d error=%d\n" "$C_TITLE" "$C_RESET" "$COUNT_OK" "$COUNT_INFO" "$COUNT_ERR"
