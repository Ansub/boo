#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="${BOO_REPO_SLUG:-Ansub/boo}"
REF="${BOO_REF:-main}"
TARBALL_URL="${BOO_TARBALL_URL:-https://github.com/${REPO_SLUG}/archive/refs/heads/${REF}.tar.gz}"

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

need_cmd bash
need_cmd curl
need_cmd tar
need_cmd mktemp

workdir="$(mktemp -d)"
archive="${workdir}/boo.tar.gz"

cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

echo "Downloading Boo (${REPO_SLUG}@${REF})..."
curl -fsSL "$TARBALL_URL" -o "$archive"

echo "Extracting..."
tar -xzf "$archive" -C "$workdir"

top_entry="$(tar -tzf "$archive" | head -n1)"
top_dir="${top_entry%%/*}"
repo_dir="${workdir}/${top_dir}"

if [[ ! -f "${repo_dir}/scripts/install.sh" ]] && [[ -f "${workdir}/scripts/install.sh" ]]; then
  repo_dir="$workdir"
fi

if [[ ! -f "${repo_dir}/scripts/install.sh" ]]; then
  echo "Failed to locate scripts/install.sh after extraction." >&2
  exit 1
fi

echo "Running installer..."
bash "${repo_dir}/scripts/install.sh"
