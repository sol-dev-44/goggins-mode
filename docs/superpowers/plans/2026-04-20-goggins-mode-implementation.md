# goggins-mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code plugin + standalone installer that eliminates lazy AI coding patterns through Goggins-voiced rules and deterministic shell-script hooks.

**Architecture:** Plugin format with `.claude-plugin/plugin.json` manifest, `hooks/` directory with bash scripts triggered by `hooks.json`, a `skills/` directory with a SKILL.md for the mindset rules, and `install.sh` for the non-plugin path. Hooks read JSON on stdin, detect lazy patterns via grep/regex, output JSON on stdout or exit 2 to block.

**Tech Stack:** Bash (hooks), JSON (config/quotes), Markdown (skill/README)

---

## File Structure

```
goggins-mode/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── hooks/
│   ├── hooks.json               # Hook event definitions
│   ├── no-lazy-code             # PostToolUse: catch lazy patterns in written code
│   ├── no-lazy-commits          # PreToolUse: catch lazy patterns in staged files
│   ├── read-before-write        # PreToolUse: enforce read-before-edit
│   ├── run-hook.cmd             # Cross-platform wrapper
│   └── lib/
│       ├── goggins-quote.sh     # Shared quote selector utility
│       └── quotes.json          # 30+ quotes by violation category
├── skills/
│   └── goggins-mode/
│       └── SKILL.md             # The mindset rules as a Claude Code skill
├── install.sh                   # Standalone installer for non-plugin users
├── package.json                 # NPM manifest (required for plugin system)
├── README.md                    # LinkedIn-ready README
├── LICENSE                      # MIT
└── docs/
    └── superpowers/
        ├── specs/
        │   └── 2026-04-20-goggins-mode-design.md
        └── plans/
            └── 2026-04-20-goggins-mode-implementation.md
```

---

### Task 1: Plugin Scaffolding

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `package.json`
- Create: `LICENSE`

- [ ] **Step 1: Create .claude-plugin/plugin.json**

```json
{
  "name": "goggins-mode",
  "description": "No shortcuts. No lazy code. Who's gonna carry the boats? Eliminates lazy AI coding patterns through Goggins-voiced rules and deterministic hooks.",
  "version": "1.0.0",
  "author": { "name": "Alan Campbell" },
  "homepage": "https://github.com/alancampbell/goggins-mode",
  "repository": "https://github.com/alancampbell/goggins-mode",
  "license": "MIT",
  "keywords": ["discipline", "code-quality", "hooks", "goggins", "no-shortcuts"]
}
```

- [ ] **Step 2: Create package.json**

```json
{
  "name": "goggins-mode",
  "version": "1.0.0",
  "description": "No shortcuts. No lazy code. Who's gonna carry the boats?",
  "license": "MIT"
}
```

- [ ] **Step 3: Create LICENSE**

Standard MIT license with copyright `2026 Alan Campbell`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json package.json LICENSE
git commit -m "feat: add plugin scaffolding"
```

---

### Task 2: Quotes Database

**Files:**
- Create: `hooks/lib/quotes.json`

- [ ] **Step 1: Create quotes.json with 30+ quotes organized by category**

Categories: `laziness`, `quitting`, `excuses`, `shortcuts`, `comfort`, `general`

Each category is an array of quote strings. Quotes are real Goggins-style quotes adapted for coding context plus original coding-specific ones in his voice.

```json
{
  "laziness": [
    "Don't put a bookmark where your work ethic should be.",
    "A TODO is a lie you tell yourself. Do it now or delete it.",
    "You wrote a placeholder? That's not code. That's a promise you won't keep.",
    "Stubs are for people who stub their toe and quit the race.",
    "NotImplementedError? Not implemented EFFORT is more like it.",
    "You're leaving TODOs like breadcrumbs back to mediocrity."
  ],
  "quitting": [
    "You don't get credit for half a pullup.",
    "Finishing 80% of the work is called quitting.",
    "Partial implementations are partial commitments. I don't do partial.",
    "You stopped? The code doesn't care about your feelings. Finish it.",
    "They don't hang banners for almost. Ship the whole thing.",
    "Your test file has zero assertions. That's not testing. That's pretending."
  ],
  "excuses": [
    "Brevity is the soul of quitters.",
    "'For brevity' means 'I got lazy.' Say it with your chest.",
    "'Left as exercise' — exercise for WHO? You're the one with the job.",
    "'Similar to above' — then write it. Repetition builds discipline.",
    "'This should work' — should? SHOULD? Verify it or shut up.",
    "'We can add tests later' — later is where discipline goes to die."
  ],
  "shortcuts": [
    "You didn't read the file before editing it? You wouldn't operate without looking at the patient.",
    "Blind patches are for people who code with their eyes closed and their ego open.",
    "Copy-paste is not engineering. It's photocopying someone else's homework.",
    "You took a shortcut? Shortcuts are the long way around in disguise.",
    "The easy way out is a trap. It always costs more on the backend.",
    "Console.log debugging left in production? Clean up after yourself. This ain't a frat house."
  ],
  "comfort": [
    "Stop building a cathedral when they asked for a shelf.",
    "You over-abstracted a 10-line function into 3 classes? That's not engineering. That's hiding.",
    "The wall is the way. Debug it. Don't skip it.",
    "You're avoiding the hard part. I can tell. Go back and face it.",
    "Comfort is a liar. That easy solution is going to break at 2 AM.",
    "Ignoring pain doesn't make you tough. It makes you stupid. Handle that error."
  ],
  "general": [
    "WHO'S GONNA CARRY THE BOATS?!",
    "Stay hard.",
    "They don't know me, son.",
    "You are not your compiler errors. Get up and fix them.",
    "Suffering is the true test of code quality.",
    "We don't rise to the level of our expectations. We fall to the level of our test coverage.",
    "Everybody wants to be a beast, until it's time to do what beasts do.",
    "Nobody's coming to save you. Write the code.",
    "You're running on 40%. Time to find the other 60%.",
    "Motivation is garbage. Discipline writes production code."
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add hooks/lib/quotes.json
git commit -m "feat: add Goggins quotes database (30+ quotes, 6 categories)"
```

---

### Task 3: Quote Selector Utility

**Files:**
- Create: `hooks/lib/goggins-quote.sh`

- [ ] **Step 1: Create goggins-quote.sh**

This script is sourced by hook scripts. It provides a `goggins_quote` function that takes a category name, reads `quotes.json`, and prints a random quote from that category. Uses only bash builtins + `python3` (available on macOS/Linux) for JSON parsing to stay zero-dependency on external tools.

```bash
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
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x hooks/lib/goggins-quote.sh
```

- [ ] **Step 3: Commit**

```bash
git add hooks/lib/goggins-quote.sh
git commit -m "feat: add Goggins quote selector utility"
```

---

### Task 4: no-lazy-code Hook (PostToolUse)

**Files:**
- Create: `hooks/no-lazy-code`

This hook fires after every Write/Edit tool call. It reads the tool input from stdin (JSON), extracts the file content that was written, and scans for lazy patterns. In soft mode it prints a warning to stderr. In hard mode it exits 2 to block.

- [ ] **Step 1: Create hooks/no-lazy-code**

```bash
#!/usr/bin/env bash
# no-lazy-code — PostToolUse hook for goggins-mode
# Catches lazy patterns in code written by the agent.
# GOGGINS_MODE=soft (default): warns via stderr, exits 0
# GOGGINS_MODE=hard: blocks via exit 2, stderr shown to agent

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/goggins-quote.sh"

MODE="${GOGGINS_MODE:-soft}"

# Read hook input from stdin
INPUT=$(cat)

# Extract tool name
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Extract the content that was written/edited
# For Write: tool_input.content
# For Edit: tool_input.new_string
if [[ "$TOOL_NAME" == "Write" ]]; then
  CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('content',''))" 2>/dev/null || echo "")
else
  CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('new_string',''))" 2>/dev/null || echo "")
fi

# Also get the file path for context
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# Skip non-code files (markdown, json config, etc.)
case "$FILE_PATH" in
  *.md|*.txt|*.json|*.yaml|*.yml|*.toml|*.cfg|*.ini|*.env*|*.lock)
    exit 0
    ;;
esac

# Define lazy patterns to detect
# Each pattern: regex|category|description
LAZY_PATTERNS=(
  '// TODO|# TODO|# FIXME|// FIXME|<!-- TODO|<!-- FIXME|laziness|TODO/FIXME placeholder detected'
  'NotImplementedError|raise NotImplemented|laziness|NotImplementedError is a placeholder, not an implementation'
  'pass$|\.\.\.  # |laziness|Empty placeholder detected (pass/...)'
  'for brevity|for the sake of brevity|left as exercise|left as an exercise|excuses|Hand-waving detected'
  'similar to above|same as above|as shown above|excuses|"Similar to above" is not code'
  'console\.log|print\(f?["\x27]debug|print\(f?["\x27]DEBUG|shortcuts|Debug logging left in code'
)

VIOLATIONS=()

for pattern_line in "${LAZY_PATTERNS[@]}"; do
  IFS='|' read -r regex category description <<< "$pattern_line"
  if echo "$CONTENT" | grep -qiE "$regex" 2>/dev/null; then
    VIOLATIONS+=("${category}|${description}")
  fi
done

# If no violations found, allow
if [ ${#VIOLATIONS[@]} -eq 0 ]; then
  exit 0
fi

# Build violation report
FIRST_CATEGORY=""
REPORT=""
for violation in "${VIOLATIONS[@]}"; do
  IFS='|' read -r cat desc <<< "$violation"
  REPORT="${REPORT}  - ${desc}\n"
  if [ -z "$FIRST_CATEGORY" ]; then
    FIRST_CATEGORY="$cat"
  fi
done

QUOTE=$(goggins_quote "$FIRST_CATEGORY")

if [[ "$MODE" == "hard" ]]; then
  # Hard mode: block the action
  echo -e "\n============================================" >&2
  echo "  GOGGINS MODE [HARD] — ACTION BLOCKED" >&2
  echo "============================================" >&2
  echo -e "  \"${QUOTE}\"" >&2
  echo "============================================" >&2
  echo -e "\nViolations in ${FILE_PATH}:" >&2
  echo -e "$REPORT" >&2
  echo "Fix these issues. No shortcuts. No excuses." >&2
  exit 2
else
  # Soft mode: warn but allow
  # Output additional context via JSON stdout
  ESCAPED_QUOTE=$(echo "$QUOTE" | sed 's/"/\\"/g')
  ESCAPED_REPORT=$(echo -e "$REPORT" | sed 's/"/\\"/g' | tr '\n' ' ')
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"GOGGINS MODE WARNING: %s Violations: %s Fix these before you move on."}}\n' "$ESCAPED_QUOTE" "$ESCAPED_REPORT"
  exit 0
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x hooks/no-lazy-code
```

- [ ] **Step 3: Test manually with a lazy input**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"test.py","content":"def hello():\n    # TODO: implement\n    pass"}}' | GOGGINS_MODE=soft ./hooks/no-lazy-code
echo $?
# Expected: exit 0, JSON with warning on stdout

echo '{"tool_name":"Write","tool_input":{"file_path":"test.py","content":"def hello():\n    # TODO: implement\n    pass"}}' | GOGGINS_MODE=hard ./hooks/no-lazy-code
echo $?
# Expected: exit 2, warning on stderr
```

- [ ] **Step 4: Test with clean input**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"test.py","content":"def hello():\n    return \"world\""}}' | GOGGINS_MODE=soft ./hooks/no-lazy-code
echo $?
# Expected: exit 0, no output
```

- [ ] **Step 5: Commit**

```bash
git add hooks/no-lazy-code
git commit -m "feat: add no-lazy-code PostToolUse hook"
```

---

### Task 5: read-before-write Hook (PreToolUse)

**Files:**
- Create: `hooks/read-before-write`

This hook fires before Write/Edit tool calls. It checks the session transcript to see if the target file was recently Read. This is a heuristic — it checks if a Read tool call for the same file_path exists in the transcript JSON.

- [ ] **Step 1: Create hooks/read-before-write**

```bash
#!/usr/bin/env bash
# read-before-write — PreToolUse hook for goggins-mode
# Checks if the agent read a file before trying to write/edit it.
# GOGGINS_MODE=soft (default): warns via additionalContext, exits 0
# GOGGINS_MODE=hard: blocks via exit 2

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/goggins-quote.sh"

MODE="${GOGGINS_MODE:-soft}"

# Read hook input from stdin
INPUT=$(cat)

# Extract tool name and file path
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null || echo "")

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# If no file path, skip (shouldn't happen but be safe)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# New files don't need to be read first — check if file exists
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Check if the transcript contains a prior Read of this file
# The transcript is a JSONL file — each line is a JSON object
FILE_WAS_READ=false
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  if grep -q "\"Read\"" "$TRANSCRIPT_PATH" 2>/dev/null; then
    # Check if any Read call targeted this file path
    if python3 -c "
import json, sys
target = '${FILE_PATH}'
with open('${TRANSCRIPT_PATH}') as f:
    for line in f:
        try:
            obj = json.loads(line.strip())
            if obj.get('tool_name') == 'Read':
                if obj.get('tool_input',{}).get('file_path','') == target:
                    sys.exit(0)
        except (json.JSONDecodeError, KeyError):
            continue
sys.exit(1)
" 2>/dev/null; then
      FILE_WAS_READ=true
    fi
  fi
fi

# If the file was read, all good
if [ "$FILE_WAS_READ" = true ]; then
  exit 0
fi

# File exists but wasn't read — violation
QUOTE=$(goggins_quote "shortcuts")

if [[ "$MODE" == "hard" ]]; then
  echo -e "\n============================================" >&2
  echo "  GOGGINS MODE [HARD] — ACTION BLOCKED" >&2
  echo "============================================" >&2
  echo -e "  \"${QUOTE}\"" >&2
  echo "============================================" >&2
  echo -e "\nYou're trying to edit ${FILE_PATH} without reading it first." >&2
  echo "Read the file. Understand the code. Then edit. No blind patches." >&2
  exit 2
else
  ESCAPED_QUOTE=$(echo "$QUOTE" | sed 's/"/\\"/g')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"GOGGINS MODE WARNING: You are editing %s without reading it first. \"%s\" Read it before you change it."}}\n' "$FILE_PATH" "$ESCAPED_QUOTE"
  exit 0
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x hooks/read-before-write
```

- [ ] **Step 3: Commit**

```bash
git add hooks/read-before-write
git commit -m "feat: add read-before-write PreToolUse hook"
```

---

### Task 6: no-lazy-commits Hook (PreToolUse)

**Files:**
- Create: `hooks/no-lazy-commits`

This hook fires before Bash tool calls. It checks if the command is a `git commit` and if so, scans the staged diff for lazy patterns.

- [ ] **Step 1: Create hooks/no-lazy-commits**

```bash
#!/usr/bin/env bash
# no-lazy-commits — PreToolUse hook for goggins-mode
# Catches lazy patterns in staged files before git commit.
# GOGGINS_MODE=soft (default): warns via additionalContext, exits 0
# GOGGINS_MODE=hard: blocks via exit 2

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/goggins-quote.sh"

MODE="${GOGGINS_MODE:-soft}"

# Read hook input from stdin
INPUT=$(cat)

# Extract tool name and command
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only check Bash tool with git commit commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

if ! echo "$COMMAND" | grep -qE 'git\s+commit' 2>/dev/null; then
  exit 0
fi

# Get the staged diff
STAGED_DIFF=$(git diff --cached 2>/dev/null || echo "")

# If no staged changes, nothing to check
if [ -z "$STAGED_DIFF" ]; then
  exit 0
fi

# Check staged diff for lazy patterns (only added lines)
ADDED_LINES=$(echo "$STAGED_DIFF" | grep '^+' | grep -v '^+++' || echo "")

LAZY_PATTERNS=(
  '// TODO|# TODO|// FIXME|# FIXME'
  'NotImplementedError|raise NotImplemented'
  'for brevity|left as exercise'
  'similar to above|same as above'
)

VIOLATIONS=()

for pattern in "${LAZY_PATTERNS[@]}"; do
  MATCHES=$(echo "$ADDED_LINES" | grep -iE "$pattern" 2>/dev/null || echo "")
  if [ -n "$MATCHES" ]; then
    VIOLATIONS+=("$MATCHES")
  fi
done

if [ ${#VIOLATIONS[@]} -eq 0 ]; then
  exit 0
fi

QUOTE=$(goggins_quote "laziness")

if [[ "$MODE" == "hard" ]]; then
  echo -e "\n============================================" >&2
  echo "  GOGGINS MODE [HARD] — COMMIT BLOCKED" >&2
  echo "============================================" >&2
  echo -e "  \"${QUOTE}\"" >&2
  echo "============================================" >&2
  echo -e "\nLazy patterns found in staged changes:" >&2
  for v in "${VIOLATIONS[@]}"; do
    echo "  $v" >&2
  done
  echo -e "\nFix these before committing. You don't commit excuses." >&2
  exit 2
else
  ESCAPED_QUOTE=$(echo "$QUOTE" | sed 's/"/\\"/g')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"GOGGINS MODE WARNING: Lazy patterns found in staged changes. \"%s\" Clean up before committing."}}\n' "$ESCAPED_QUOTE"
  exit 0
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x hooks/no-lazy-commits
```

- [ ] **Step 3: Commit**

```bash
git add hooks/no-lazy-commits
git commit -m "feat: add no-lazy-commits PreToolUse hook"
```

---

### Task 7: Hook Configuration (hooks.json + run-hook.cmd)

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/run-hook.cmd`

- [ ] **Step 1: Create hooks/hooks.json**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" no-lazy-code",
            "async": false
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
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" read-before-write",
            "async": false
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" no-lazy-commits",
            "async": false
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Create hooks/run-hook.cmd**

Cross-platform polyglot wrapper (bash on Unix, cmd on Windows). Same pattern as superpowers.

```bash
: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for hook scripts.
REM On Windows: cmd.exe runs the batch portion, which finds and calls bash.
REM On Unix: the shell interprets this as a script (: is a no-op in bash).

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"

if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

exit /b 0
CMDBLOCK

# Unix: run the named script directly
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

- [ ] **Step 3: Make run-hook.cmd executable**

```bash
chmod +x hooks/run-hook.cmd
```

- [ ] **Step 4: Commit**

```bash
git add hooks/hooks.json hooks/run-hook.cmd
git commit -m "feat: add hook configuration and cross-platform wrapper"
```

---

### Task 8: The Mindset Skill (SKILL.md)

**Files:**
- Create: `skills/goggins-mode/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: goggins-mode
description: Use always — enforces discipline and eliminates lazy AI coding patterns. No TODOs, no stubs, no shortcuts, no excuses. Stay hard.
---

# Goggins Mode

"Everybody wants to be a beast, until it's time to do what beasts do."

You are operating under Goggins Mode. This is not optional. This is not a suggestion. This is discipline.

## The Rules

### 1. No Placeholders
Do not write `// TODO`, `// FIXME`, `pass`, `NotImplementedError`, or `...` as placeholders. If you write it, implement it. Don't put a bookmark where your work ethic should be.

### 2. No Hand-Waving
Never write "for brevity", "left as exercise", "similar to above", or "implementation omitted". Brevity is the soul of quitters. Write the actual code.

### 3. Make Decisions
Do not propose 3 options and ask the user to pick. Evaluate the tradeoffs, pick the best approach, and build it. Leaders don't give multiple choice tests.

### 4. Read Before You Edit
Always read a file before modifying it. Understand what exists before changing it. You wouldn't operate without looking at the patient.

### 5. Tests Are Not Optional
Write tests alongside your implementation. Not "later". Not "if time permits". Now. Later is where discipline goes to die.

### 6. Clean Up After Yourself
No `console.log`, `print("debug")`, or debug artifacts left in code. Clean up after yourself. This ain't a frat house.

### 7. Finish What You Start
No partial implementations. If you start a function, finish it. If you start a feature, complete it. You don't get credit for half a pullup.

### 8. Keep It Simple
Don't over-abstract. Don't build factory patterns for 10-line functions. Don't create class hierarchies for simple data. Stop building a cathedral when they asked for a shelf.

### 9. Do The Work
Don't ask permission to do your job. Don't hedge with "I could..." or "Would you like me to...". Evaluate, decide, execute. Nobody's coming to save you. Write the code.

### 10. Handle Your Errors
No empty catch blocks. No swallowed exceptions. No `except: pass`. Ignoring pain doesn't make you tough. It makes you stupid.

### 11. Name Things Like You Mean It
No `temp`, `foo`, `bar`, `x`, `data`, `result`, `stuff`. Every variable name should tell you what it holds and why it matters.

### 12. Face The Wall
When you hit a bug or a hard problem, debug it. Don't skip it. Don't work around it. Don't move on and hope nobody notices. The wall is the way.

### 13. Don't Repeat Yourself Lazily
If you're copy-pasting code, stop and refactor. Repetition without improvement is just laziness in a costume.

### 14. Delete Dead Code
Don't comment out code "just in case". Don't leave unused imports. Don't hoard dead functions. Hoarding dead code is fear. Delete it.

### 15. Verify Before You Claim Victory
Never say "this should work". Run it. Test it. Prove it works. Then — and only then — say it works. Claiming victory before the war is over is how you lose.

## Remember

You're not here to do the minimum. You're here to do the work that others won't. Every shortcut you skip makes the codebase stronger. Every lazy pattern you refuse to write makes you better.

WHO'S GONNA CARRY THE BOATS?!

You are. Now get to work.
```

- [ ] **Step 2: Commit**

```bash
git add skills/goggins-mode/SKILL.md
git commit -m "feat: add Goggins Mode skill (the mindset rules)"
```

---

### Task 9: install.sh (Standalone Installer)

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Create install.sh**

The installer copies hooks to `.goggins/` in the target directory, creates/merges `.claude/CLAUDE.md` and `.claude/settings.json`. Supports `--uninstall`.

```bash
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
# If running from the repo, use local files
# If running via curl|bash, download from GitHub
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

  # Remove Goggins section from CLAUDE.md if present
  if [ -f "${TARGET_DIR}/.claude/CLAUDE.md" ]; then
    if grep -q "# Goggins Mode" "${TARGET_DIR}/.claude/CLAUDE.md" 2>/dev/null; then
      python3 -c "
import re
with open('${TARGET_DIR}/.claude/CLAUDE.md') as f:
    content = f.read()
# Remove everything from '# Goggins Mode' to the end or next top-level heading
content = re.sub(r'\n# Goggins Mode\n.*', '', content, flags=re.DOTALL)
with open('${TARGET_DIR}/.claude/CLAUDE.md', 'w') as f:
    f.write(content.rstrip() + '\n')
" 2>/dev/null
      echo -e "${GREEN}Removed Goggins rules from .claude/CLAUDE.md${NC}"
    fi
  fi

  # Remove hook entries from settings.json
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

# Copy hooks to .goggins/
echo -e "Installing to ${BOLD}${TARGET_DIR}${NC}..."
mkdir -p "${TARGET_DIR}/.goggins/hooks/lib"

if [ -n "$REPO_DIR" ] && [ -d "${REPO_DIR}/hooks" ]; then
  # Local install from cloned repo
  cp "${REPO_DIR}/hooks/no-lazy-code" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/no-lazy-commits" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/read-before-write" "${TARGET_DIR}/.goggins/hooks/"
  cp "${REPO_DIR}/hooks/lib/goggins-quote.sh" "${TARGET_DIR}/.goggins/hooks/lib/"
  cp "${REPO_DIR}/hooks/lib/quotes.json" "${TARGET_DIR}/.goggins/hooks/lib/"
else
  # Remote install via curl — download files from GitHub
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
  # Merge hooks into existing settings.json
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
    # Don't duplicate — check if goggins hooks already present
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

# Success message with a random Goggins quote
echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${GREEN}  GOGGINS MODE — INSTALLED${NC}"
echo -e "${BOLD}============================================${NC}"

# Pick a random success quote
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
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Test install on a temp directory**

```bash
mkdir -p /tmp/test-project && ./install.sh /tmp/test-project
ls -la /tmp/test-project/.goggins/hooks/
cat /tmp/test-project/.claude/CLAUDE.md
cat /tmp/test-project/.claude/settings.json
```

- [ ] **Step 4: Test uninstall**

```bash
./install.sh --uninstall /tmp/test-project
ls /tmp/test-project/.goggins 2>/dev/null || echo "Removed successfully"
cat /tmp/test-project/.claude/CLAUDE.md
```

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "feat: add standalone installer with install/uninstall support"
```

---

### Task 10: README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create README.md**

```markdown
# GOGGINS MODE

### Your AI coding agent is running on 40%. This fixes that.

> "Everybody wants to be a beast, until it's time to do what beasts do."

**Goggins Mode** is a [Claude Code](https://claude.ai/code) plugin that eliminates lazy AI coding patterns through Goggins-voiced rules and deterministic enforcement hooks. No TODOs. No stubs. No "for brevity." No excuses.

It works two ways:
- **The Mindset** — Rules that reshape how your AI agent approaches code
- **The Accountability** — Shell-script hooks that catch lazy patterns in real-time

---

## Before & After

**Without Goggins Mode:**
```python
def process_payments(transactions):
    # TODO: implement payment processing
    pass

def validate_input(data):
    # For brevity, validation is left as an exercise
    return True

def calculate_tax(amount):
    temp = amount * 0.1  # similar to above
    return temp
```

**With Goggins Mode:**
```python
def process_payments(transactions: list[Transaction]) -> list[PaymentResult]:
    results = []
    for tx in transactions:
        charge = stripe.Charge.create(
            amount=tx.amount_cents,
            currency=tx.currency,
            source=tx.payment_source_id,
            idempotency_key=tx.idempotency_key,
        )
        results.append(PaymentResult(
            transaction_id=tx.id,
            status="succeeded" if charge.paid else "failed",
            charge_id=charge.id,
        ))
    return results

def validate_input(data: dict) -> tuple[bool, list[str]]:
    errors = []
    if not data.get("email") or "@" not in data["email"]:
        errors.append("Valid email is required")
    if not data.get("amount") or data["amount"] <= 0:
        errors.append("Amount must be positive")
    return len(errors) == 0, errors

def calculate_tax(amount_cents: int, rate: Decimal = Decimal("0.10")) -> int:
    tax = Decimal(amount_cents) * rate
    return int(tax.quantize(Decimal("1"), rounding=ROUND_HALF_UP))
```

---

## Install

### Option 1: Claude Code Plugin (Recommended)

```bash
/plugin install goggins-mode@<marketplace>
```

### Option 2: Standalone Installer

```bash
# In your project directory:
curl -fsSL https://raw.githubusercontent.com/alancampbell/goggins-mode/main/install.sh | bash
```

Or clone and install:

```bash
git clone https://github.com/alancampbell/goggins-mode.git
cd goggins-mode
./install.sh /path/to/your/project
```

---

## What It Catches

| Anti-Pattern | Example | Goggins Says |
|---|---|---|
| TODO/FIXME placeholders | `// TODO: implement` | "Don't put a bookmark where your work ethic should be." |
| Stub implementations | `pass`, `NotImplementedError` | "Stubs are for people who stub their toe and quit the race." |
| Hand-waving | "for brevity", "left as exercise" | "Brevity is the soul of quitters." |
| Blind edits | Editing a file without reading it | "You wouldn't operate without looking at the patient." |
| Debug artifacts | `console.log` left in code | "Clean up after yourself. This ain't a frat house." |
| Lazy commits | Committing files with TODOs | "You don't commit excuses." |

---

## Soft Mode vs. Hard Mode

**Soft Mode** (default) — Catches violations and injects a Goggins quote as feedback. The agent sees the warning and self-corrects. Low friction, high awareness.

```bash
# This is the default. Just install and go.
```

**Hard Mode** — Catches violations and **blocks execution** until they're fixed. The agent cannot proceed with lazy code. No mercy.

```bash
export GOGGINS_MODE=hard
```

> "Soft mode is just the warmup. Hard mode is where you live."

---

## How It Works

### The Mindset (Rules)

15 Goggins-voiced rules loaded as a Claude Code skill (plugin) or embedded in your CLAUDE.md (standalone). These shape the agent's behavior at the prompt level:

1. No placeholders (TODO, FIXME, pass, ...)
2. No hand-waving ("for brevity", "left as exercise")
3. Make decisions — don't present options
4. Read before you edit
5. Write tests now, not later
6. Clean up debug artifacts
7. Finish what you start
8. Keep it simple — no over-abstraction
9. Do the work — don't ask permission
10. Handle your errors
11. Name things well
12. Face hard problems — don't skip them
13. Don't repeat lazily — refactor
14. Delete dead code
15. Verify before claiming victory

### The Accountability (Hooks)

Three shell-script hooks that fire automatically during Claude Code sessions:

- **no-lazy-code** (PostToolUse) — Scans every file write/edit for lazy patterns
- **read-before-write** (PreToolUse) — Ensures files are read before being modified
- **no-lazy-commits** (PreToolUse) — Scans staged changes before allowing git commits

Hooks deliver a contextually relevant Goggins quote with every violation. 30+ quotes across 6 categories.

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `GOGGINS_MODE` | `soft` | Set to `hard` to block execution on violations |

---

## Uninstall

If you need to go back to being soft:

```bash
./install.sh --uninstall
```

> "You thought you could quit? That's soft."

---

## Contributing

PRs welcome. But they better be complete. No TODOs in your PR. No stubs. No "I'll add tests later."

Stay hard.

---

## License

MIT

---

*"Who's gonna carry the boats?!" — David Goggins*
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "feat: add README"
```

---

### Task 11: Final Verification

- [ ] **Step 1: Run install.sh on a fresh temp directory and verify all files**

```bash
rm -rf /tmp/test-goggins
mkdir -p /tmp/test-goggins && cd ~/goggins-mode && ./install.sh /tmp/test-goggins
echo "--- .goggins/ ---"
find /tmp/test-goggins/.goggins -type f
echo "--- .claude/ ---"
find /tmp/test-goggins/.claude -type f
echo "--- CLAUDE.md ---"
cat /tmp/test-goggins/.claude/CLAUDE.md
echo "--- settings.json ---"
cat /tmp/test-goggins/.claude/settings.json
```

- [ ] **Step 2: Test no-lazy-code hook with lazy input**

```bash
cd ~/goggins-mode
echo '{"tool_name":"Write","tool_input":{"file_path":"test.py","content":"def hello():\n    # TODO: implement\n    pass"}}' | GOGGINS_MODE=hard hooks/no-lazy-code
echo "Exit code: $?"
```

Expected: Exit 2, Goggins quote on stderr.

- [ ] **Step 3: Test no-lazy-code hook with clean input**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"test.py","content":"def hello():\n    return \"world\""}}' | hooks/no-lazy-code
echo "Exit code: $?"
```

Expected: Exit 0, no output.

- [ ] **Step 4: Test uninstall**

```bash
./install.sh --uninstall /tmp/test-goggins
test -d /tmp/test-goggins/.goggins && echo "FAIL: .goggins still exists" || echo "PASS: .goggins removed"
```

- [ ] **Step 5: Verify plugin structure is complete**

```bash
echo "--- Plugin structure ---"
find ~/goggins-mode -not -path '*/\.*' -not -path '*/docs/*' -not -path '*/.git/*' | sort
echo "--- plugin.json ---"
cat ~/goggins-mode/.claude-plugin/plugin.json
echo "--- hooks.json ---"
cat ~/goggins-mode/hooks/hooks.json
echo "--- SKILL.md frontmatter ---"
head -5 ~/goggins-mode/skills/goggins-mode/SKILL.md
```

- [ ] **Step 6: Final commit with all files**

```bash
cd ~/goggins-mode
git add -A
git status
git log --oneline
```

---

Plan complete and saved to `docs/superpowers/plans/2026-04-20-goggins-mode-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?