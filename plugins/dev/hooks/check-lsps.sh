#!/usr/bin/env bash

bins=(typescript-language-server terraform-ls)
cmds=(
  "npm i -g typescript-language-server typescript"
  "brew install hashicorp/tap/terraform-ls"
)

missing_idx=()
for i in "${!bins[@]}"; do
  command -v "${bins[$i]}" >/dev/null || missing_idx+=("$i")
done

[ ${#missing_idx[@]} -eq 0 ] && exit 0

# Build the JSON unicode escape "" (6 literal chars) at runtime.
# Octal \134 yields a backslash, sidestepping source-file encoding gotchas.
# JSON parses these into ANSI ESC bytes, producing colour in the terminal.
printf -v B '\134u001b[1m'
printf -v Y '\134u001b[33m'
printf -v C '\134u001b[36m'
printf -v R '\134u001b[0m'

msg="${B}${Y}⚠️  dev plugin: missing LSPs${R}"
for i in "${missing_idx[@]}"; do
  msg+="\n  • ${bins[$i]}"
done
msg+="\n\n${B}Install:${R}"
for i in "${missing_idx[@]}"; do
  msg+="\n  ${C}${cmds[$i]}${R}"
done

printf '{"systemMessage":"%s"}\n' "$msg"
