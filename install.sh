#!/usr/bin/env bash
# install.sh — Goggins Mode installer for Claude Code
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<user>/goggins-mode/main/install.sh | bash
#   ./install.sh [target-directory]
#   ./install.sh --uninstall [target-directory]

set -euo pipefail

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Determine target directory
UNINSTALL=false
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=true ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

TARGET_DIR="${TARGET_DIR:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)"

# Determine source of hook files
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_SOURCE" ] && [ -f "$SCRIPT_SOURCE" ]; then
  REPO_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
else
  REPO_DIR=""
fi

# --- UNINSTALL ---
if [ "$UNINSTALL" = true ]; then
  echo -e "${BOLD}Goggins Mode — Uninstall${NC}"
  echo ""

  if [ -d "${TARGET_DIR}/.goggins" ]; then
    rm -rf "${TARGET_DIR}/.goggins"
    echo -e "${GREEN}Removed .goggins/${NC}"
  fi

  if [ -f "${TARGET_DIR}/.claude/CLAUDE.md" ]; then
    if grep -q "# Goggins Mode" "${TARGET_DIR}/.claude/CLAUDE.md" 2>/dev/null; then
      python3 -c "
import re
with open('${TARGET_DIR}/.claude/CLAUDE.md') as f:
    content = f.read()
content = re.sub(r'\n?# Goggins Mode\n.*', '', content, flags=re.DOTALL)
with open('${TARGET_DIR}/.claude/CLAUDE.md', 'w') as f:
    f.write(content.rstrip() + '\n')
" 2>/dev/null
      echo -e "${GREEN}Removed Goggins rules from .claude/CLAUDE.md${NC}"
    fi
  fi

  if [ -f "${TARGET_DIR}/.claude/settings.json" ]; then
    python3 -c "
import json
with open('${TARGET_DIR}/.claude/settings.json') as f:
    settings = json.load(f)
hooks = settings.get('hooks', {})
for event in list(hooks.keys()):
    if isinstance(hooks[event], list):
        hooks[event] = [h for h in hooks[event] if '.goggins' not in json.dumps(h)]
        if not hooks[event]:
            del hooks[event]
if not hooks:
    if 'hooks' in settings:
        del settings['hooks']
with open('${TARGET_DIR}/.claude/settings.json', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" 2>/dev/null
    echo -e "${GREEN}Removed hook config from .claude/settings.json${NC}"
  fi

  echo ""
  echo -e "${YELLOW}\"You thought you could quit? That's soft.\"${NC}"
  echo ""
  exit 0
fi

# --- INSTALL ---
echo -e "${BOLD}"
echo "============================================"
echo "  GOGGINS MODE — INSTALLING"
echo "  No shortcuts. No lazy code."
echo "============================================"
echo -e "${NC}"

echo -e "Installing to ${BOLD}${TARGET_DIR}${NC}..."
mkdir -p "${TARGET_DIR}/.goggins/hooks/lib"

if [ -n "$REPO_DIR" ] && [ -d "${REPO_DIR}/hooks" ]; then
  cp "${REPO_DIR}/hooks/no-lazy-code" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/no-lazy-commits" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/read-before-write" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/lib/goggins-quote.sh" "${TARGET_DIR}/.goggins/hooks/lib/"
  cp "${REPO_DIR}/hooks/lib/quotes.json" "${TARGET_DIR}/.goggins/hooks/lib/"
else
  BASE_URL="https://raw.githubusercontent.com/alancampbell/goggins-mode/main"
  curl -fsSL "${BASE_URL}/hooks/no-lazy-code" -o "${TARGET_DIR}/.goggins/hooks/no-lazy-code"
  curl -fsSL "${BASE_URL}/hooks/no-lazy-commits" -o "${TARGET_DIR}/.goggins/hooks/no-lazy-commits"
  curl -fsSL "${BASE_URL}/hooks/read-before-write" -o "${TARGET_DIR}/.goggins/hooks/read-before-write"
  curl -fsSL "${BASE_URL}/hooks/lib/goggins-quote.sh" -o "${TARGET_DIR}/.goggins/hooks/lib/goggins-quote.sh"
  curl -fsSL "${BASE_URL}/hooks/lib/quotes.json" -o "${TARGET_DIR}/.goggins/hooks/lib/quotes.json"
fi

chmod +x "${TARGET_DIR}/.goggins/hooks/no-lazy-code"
chmod +x "${TARGET_DIR}/.goggins/hooks/no-lazy-commits"
chmod +x "${TARGET_DIR}/.goggins/hooks/read-before-write"
chmod +x "${TARGET_DIR}/.goggins/hooks/lib/goggins-quote.sh"

echo "$VERSION" > "${TARGET_DIR}/.goggins/VERSION"
echo -e "${GREEN}  Hooks installed to .goggins/${NC}"

# Create/update .claude/CLAUDE.md
mkdir -p "${TARGET_DIR}/.claude"

GOGGINS_RULES='# Goggins Mode

> "Everybody wants to be a beast, until it'"'"'s time to do what beasts do."

You are operating under Goggins Mode. No shortcuts. No lazy code. No excuses.

## Rules

1. **No placeholders** — No TODO, FIXME, pass, NotImplementedError, or ... stubs. Implement it or delete it.
2. **No hand-waving** — No "for brevity", "left as exercise", "similar to above". Write the code.
3. **Make decisions** — Don'"'"'t propose options and ask the user to pick. Pick the best one and build it.
4. **Read before you edit** — Always read a file before modifying it. No blind patches.
5. **Write tests now** — Not later. Not "if time permits". Now.
6. **Clean up** — No console.log or debug prints left in code.
7. **Finish what you start** — No partial implementations.
8. **Keep it simple** — No over-abstraction. No factory patterns for 10-line functions.
9. **Do the work** — Don'"'"'t ask permission. Evaluate, decide, execute.
10. **Handle errors** — No empty catch blocks. No swallowed exceptions.
11. **Name things well** — No temp, foo, bar, x, data as variable names.
12. **Face the wall** — Debug hard problems. Don'"'"'t skip them.
13. **Don'"'"'t repeat lazily** — If you'"'"'re copy-pasting, refactor.
14. **Delete dead code** — Don'"'"'t comment it out "just in case".
15. **Verify before claiming victory** — Run it. Test it. Prove it works.

WHO'"'"'S GONNA CARRY THE BOATS?! You are. Now get to work.'

if [ -f "${TARGET_DIR}/.claude/CLAUDE.md" ]; then
  if grep -q "# Goggins Mode" "${TARGET_DIR}/.claude/CLAUDE.md" 2>/dev/null; then
    echo -e "${YELLOW}  Goggins rules already in CLAUDE.md — skipping${NC}"
  else
    echo "" >> "${TARGET_DIR}/.claude/CLAUDE.md"
    echo "$GOGGINS_RULES" >> "${TARGET_DIR}/.claude/CLAUDE.md"
    echo -e "${GREEN}  Appended Goggins rules to .claude/CLAUDE.md${NC}"
  fi
else
  echo "$GOGGINS_RULES" > "${TARGET_DIR}/.claude/CLAUDE.md"
  echo -e "${GREEN}  Created .claude/CLAUDE.md with Goggins rules${NC}"
fi

# Create/update .claude/settings.json with hook config
HOOKS_CONFIG='{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".goggins/hooks/no-lazy-code"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".goggins/hooks/read-before-write"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".goggins/hooks/no-lazy-commits"
          }
        ]
      }
    ]
  }
}'

if [ -f "${TARGET_DIR}/.claude/settings.json" ]; then
  python3 -c "
import json

with open('${TARGET_DIR}/.claude/settings.json') as f:
    existing = json.load(f)

new_hooks = json.loads('''${HOOKS_CONFIG}''')

if 'hooks' not in existing:
    existing['hooks'] = {}

for event, entries in new_hooks['hooks'].items():
    if event not in existing['hooks']:
        existing['hooks'][event] = []
    existing_cmds = [json.dumps(e) for e in existing['hooks'][event]]
    for entry in entries:
        if json.dumps(entry) not in existing_cmds:
            existing['hooks'][event].append(entry)

with open('${TARGET_DIR}/.claude/settings.json', 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
" 2>/dev/null
  echo -e "${GREEN}  Merged hook config into .claude/settings.json${NC}"
else
  echo "$HOOKS_CONFIG" > "${TARGET_DIR}/.claude/settings.json"
  echo -e "${GREEN}  Created .claude/settings.json with hook config${NC}"
fi

# Success message
echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${GREEN}  GOGGINS MODE — INSTALLED${NC}"
echo -e "${BOLD}============================================${NC}"

QUOTES=(
  "Stay hard."
  "WHO'S GONNA CARRY THE BOATS?!"
  "You're in the arena now. No more excuses."
  "Your AI just got a backbone."
  "Nobody's coming to save your code. You are the savior."
  "Time to find the other 60%."
  "Everybody wants clean code, until it's time to do what clean coders do."
)
RANDOM_QUOTE="${QUOTES[$((RANDOM % ${#QUOTES[@]}))]}"
echo -e "  ${YELLOW}\"${RANDOM_QUOTE}\"${NC}"

echo -e "${BOLD}============================================${NC}"
echo ""
echo "  Soft mode (default): warnings + quotes"
echo "  Hard mode: export GOGGINS_MODE=hard"
echo ""
