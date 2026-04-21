# goggins-mode — Design Spec

**Date:** 2026-04-20
**Author:** Alan Campbell / Iron Lion Ventures
**Status:** Approved

## Overview

A Claude Code plugin AND standalone installer that eliminates lazy AI coding patterns through Goggins-voiced rules (behavioral guidance) and deterministic shell-script hooks (enforcement). Two modes: **soft** (warnings + quotes) and **hard** (blocks execution until fixed).

"Everybody wants to be a beast, until it's time to do what beasts do."

## Target

- **Audience:** Claude Code users (power users + newcomers drawn in by viral branding)
- **Platform:** Claude Code only for v1
- **Distribution:** Claude Code plugin (`/plugin install`) + `curl | bash` installer + manual clone
- **Goal:** Ship v1 today. Genuinely useful + meme-tier viral for LinkedIn.

## Architecture

### Layer 1: The Mindset (Skill — SKILL.md)

A skill called `goggins-mode` that loads Goggins-voiced rules targeting documented lazy LLM patterns. Delivered as a plugin skill (auto-loaded by Claude Code) AND embedded in CLAUDE.md for the curl installer path.

~15 rules:

1. No `// TODO`, `// FIXME`, `pass`, `NotImplementedError`, `...` placeholders — "Don't put a bookmark where your work ethic should be."
2. No "for brevity", "left as exercise", "similar to above" hand-waving — "Brevity is the soul of quitters."
3. No proposing 3 options and asking the user to pick — make a decision and build it — "Leaders don't give multiple choice tests."
4. Read files before editing them — no blind patches — "You wouldn't operate without looking at the patient."
5. Write tests alongside implementation, not "later" — "Later is where discipline goes to die."
6. No `console.log` / `print()` debugging left in committed code — "Clean up after yourself. This ain't a frat house."
7. Finish what you start — no partial implementations — "You don't get credit for half a pullup."
8. No over-abstracting simple things into factory-pattern class hierarchies — "Stop building a cathedral when they asked for a shelf."
9. Don't ask permission to do your job — just do the work — "Nobody's coming to save you. Write the code."
10. No empty catch blocks or swallowed errors — "Ignoring pain doesn't make you tough. It makes you stupid."
11. No placeholder variable names (temp, foo, bar, x, data) — "Name things like you mean it."
12. When you hit a wall, debug it — don't skip it and move on — "The wall is the way."
13. No copy-pasting code — if it's repeated, refactor it — "Repetition without improvement is just laziness in a costume."
14. Don't comment out code "just in case" — delete it or use it — "Hoarding dead code is fear. Delete it."
15. No "this should work" — verify it works, then say it works — "Claiming victory before the war is over is how you lose."

### Layer 2: The Accountability (Hooks)

Shell scripts wired to Claude Code's hook system via `hooks/hooks.json`:

| Hook | Trigger | Detects | Soft Mode | Hard Mode |
|---|---|---|---|---|
| `no-lazy-code` | PostToolUse (Write/Edit) | TODOs, stubs, placeholders, NotImplementedError, `...` | Goggins quote in stderr | Exit 2, blocks |
| `read-before-write` | PreToolUse (Write/Edit) | File writes without a prior read of same file | Goggins warning | Exit 2, blocks |
| `no-lazy-commits` | PreToolUse (Bash: git commit) | TODOs/FIXMEs in staged files | Goggins warning | Exit 2, blocks |

**Config toggle:** `GOGGINS_MODE` env var. Default: `soft`. Set to `hard` for blocking enforcement.

**Hook mechanics:**
- Hooks receive tool input as JSON on stdin
- PostToolUse hooks can read the tool output to scan for lazy patterns
- PreToolUse hooks can inspect the planned action before it executes
- Exit code 0 = allow, exit code 2 = block (with stderr shown to agent as feedback)
- All hooks source `lib/goggins-quote.sh` for quote selection
- Hooks use `${CLAUDE_PLUGIN_ROOT}` env var for paths when running as plugin

### Layer 3: The Quotes (quotes.json)

30+ quotes organized by violation category:
- `laziness` — TODOs, stubs, placeholders
- `quitting` — partial implementations, skipped tests
- `excuses` — "for brevity", "left as exercise"
- `shortcuts` — blind edits, copy-paste
- `comfort` — avoiding hard problems, over-abstracting
- `general` — fallback motivational quotes

Each hook maps its violation type to a category and pulls a contextually relevant quote.

## Plugin Structure

```
goggins-mode/
├── .claude-plugin/
│   └── plugin.json              # Claude Code plugin manifest
├── hooks/
│   ├── hooks.json               # Claude Code hook definitions
│   ├── no-lazy-code             # PostToolUse hook (executable, no extension)
│   ├── no-lazy-commits          # PreToolUse hook (executable)
│   ├── read-before-write        # PreToolUse hook (executable)
│   └── lib/
│       ├── goggins-quote.sh     # Quote selector utility
│       └── quotes.json          # Quote database
├── skills/
│   └── goggins-mode/
│       └── SKILL.md             # The mindset rules as a skill
├── install.sh                   # Standalone installer (non-plugin path)
├── README.md
├── LICENSE
└── package.json
```

**Installed layout via curl installer** (in user's project):

```
user-project/
├── .claude/
│   ├── CLAUDE.md        ← Goggins rules appended or created
│   └── settings.json    ← Hook config pointing to .goggins/hooks/
└── .goggins/
    ├── hooks/
    │   ├── no-lazy-code
    │   ├── no-lazy-commits
    │   ├── read-before-write
    │   └── lib/
    │       ├── goggins-quote.sh
    │       └── quotes.json
    └── VERSION
```

## Plugin Manifest (.claude-plugin/plugin.json)

```json
{
  "name": "goggins-mode",
  "description": "No shortcuts. No lazy code. Who's gonna carry the boats? Eliminates lazy AI coding patterns through Goggins-voiced rules and deterministic hooks.",
  "version": "1.0.0",
  "author": { "name": "Alan Campbell" },
  "repository": "https://github.com/alancampbell/goggins-mode",
  "license": "MIT",
  "keywords": ["discipline", "code-quality", "hooks", "goggins", "no-shortcuts"]
}
```

## hooks.json (Claude Code Hook Definitions)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/no-lazy-code\"",
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
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/read-before-write\"",
            "async": false
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/no-lazy-commits\"",
            "async": false
          }
        ]
      }
    ]
  }
}
```

## install.sh Behavior

1. Detect current directory (must be a git repo or project root)
2. Copy hook scripts to `.goggins/hooks/`
3. Write `.goggins/VERSION`
4. If `.claude/CLAUDE.md` exists → append `# Goggins Mode` section
5. If `.claude/CLAUDE.md` doesn't exist → create it with full rules
6. If `.claude/settings.json` exists → merge hook entries
7. If `.claude/settings.json` doesn't exist → create it with hook config
8. Print a Goggins quote on success
9. Support `--uninstall` flag to cleanly remove

**CLI usage:**
```bash
# Remote install (in your project directory)
curl -fsSL https://raw.githubusercontent.com/<user>/goggins-mode/main/install.sh | bash

# Local install (after cloning)
./install.sh [target-directory]

# Uninstall
./install.sh --uninstall [target-directory]
```

## README.md

- Bold banner headline
- One-liner: "Your AI coding agent is running on 40%. This fixes that."
- Before/after text demo (lazy output vs. Goggins-enforced output)
- Two installation paths (plugin + curl)
- What it catches (anti-pattern table)
- Soft vs. Hard mode docs
- Quote examples
- Configuration reference (`GOGGINS_MODE` env var)

## Out of Scope for v1

- Scoreboard / Goggins Score (v2)
- Multi-platform support (Cursor, Copilot, Windsurf)
- MCP server
- GitHub badges
- npm/brew distribution

## Success Criteria

1. `/plugin install goggins-mode` works from a GitHub repo
2. `install.sh` works on a fresh project and a project with existing `.claude/` config
3. All hooks fire correctly on lazy patterns in soft mode
4. All hooks block correctly in hard mode (`GOGGINS_MODE=hard`)
5. README is LinkedIn-post-ready
6. The whole thing makes you laugh AND makes your code better
