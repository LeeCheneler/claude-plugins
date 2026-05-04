#!/usr/bin/env bash
set -eu

missing=()

if ! command -v typescript-language-server >/dev/null 2>&1; then
  missing+=("typescript-language-server  →  npm install -g typescript-language-server typescript")
fi

if ! command -v terraform-ls >/dev/null 2>&1; then
  missing+=("terraform-ls                →  brew install hashicorp/tap/terraform-ls")
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo "[dev plugin] LSP binaries missing — language intelligence will be unavailable until installed:" >&2
  for entry in "${missing[@]}"; do
    echo "  • $entry" >&2
  done
fi

exit 0
