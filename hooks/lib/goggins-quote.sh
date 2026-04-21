#!/usr/bin/env bash
# goggins-quote.sh — Quote selector utility for goggins-mode hooks
# Source this file: source "$(dirname "$0")/lib/goggins-quote.sh"

GOGGINS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

goggins_quote() {
  local category="${1:-general}"
  local quotes_file="${GOGGINS_LIB_DIR}/quotes.json"

  if [ ! -f "$quotes_file" ]; then
    echo "STAY HARD."
    return
  fi

  python3 -c "
import json, random, sys
with open('${quotes_file}') as f:
    data = json.load(f)
category = '${category}'
quotes = data.get(category, data.get('general', ['STAY HARD.']))
print(random.choice(quotes))
" 2>/dev/null || echo "STAY HARD."
}

goggins_banner() {
  local category="${1:-general}"
  local quote
  quote=$(goggins_quote "$category")
  echo ""
  echo "============================================"
  echo "  GOGGINS MODE"
  echo "============================================"
  echo "  $quote"
  echo "============================================"
  echo ""
}
