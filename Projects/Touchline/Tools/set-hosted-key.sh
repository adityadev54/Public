#!/bin/zsh
# Read privately; the key never becomes a command argument or a saved file.
set -eu
fly_cli="$(command -v flyctl || true)"
if [[ -z "$fly_cli" ]]; then fly_cli=/private/tmp/touchline-fly/flyctl; fi
if [[ ! -x "$fly_cli" ]]; then print 'Install the official Fly CLI first.'; exit 1; fi
read -rs 'touchline_key?Paste your AI key (hidden): '
print
if [[ "$touchline_key" != sk-or-* ]]; then print 'That key format is invalid.'; unset touchline_key; exit 1; fi
printf 'OPENROUTER_API_KEY=%s\n' "$touchline_key" | "$fly_cli" secrets import -a touchline-aditya-vision
unset touchline_key
