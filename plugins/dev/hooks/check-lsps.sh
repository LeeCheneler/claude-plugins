#!/usr/bin/env bash
missing=()
command -v typescript-language-server >/dev/null || missing+=("typescript-language-server")
command -v terraform-ls >/dev/null || missing+=("terraform-ls")

if [ ${#missing[@]} -gt 0 ]; then
  echo "⚠️  dev plugin: missing LSPs: ${missing[*]}"
  echo "Install with: npm i -g typescript-language-server typescript && brew install hashicorp/tap/terraform-ls"
fi
