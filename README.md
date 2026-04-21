# GOGGINS MODE

### Your AI coding agent is running on 40%. This fixes that.

> "Everybody wants to be a beast, until it's time to do what beasts do."

**Goggins Mode** is a [Claude Code](https://claude.ai/code) plugin that eliminates lazy AI coding patterns through Goggins-voiced rules and deterministic enforcement hooks. No TODOs. No stubs. No "for brevity." No excuses.

You know the drill. You ask your AI to build a payment processor and it hands you back:

```python
def process_payments(transactions):
    # TODO: implement payment processing
    pass
```

Congratulations. You just mass-produced a sticky note. That'll look great in production.

Goggins Mode makes that impossible. It works two ways:

- **The Mindset** — 15 rules that reshape how your AI agent approaches code
- **The Accountability** — Shell-script hooks that catch lazy patterns *in real-time* and yell at your agent in David Goggins quotes

---

## The Problem Is Worse Than You Think

This isn't just vibes. The data is brutal:

- **40% of AI-generated code gets rewritten within 2 weeks** — [GitClear 2025 Research](https://www.gitclear.com/ai_assistant_code_quality_2025_research), analyzing 211 million lines of code
- **AI-assisted developers are actually 19% slower** — but *believe* they're 20% faster. A 39-point perception gap. — [METR Randomized Controlled Trial](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
- **66% of developers say AI code is "almost right, but not quite"** — [Stack Overflow Developer Survey](https://stackoverflow.blog/2026/01/28/are-bugs-and-incidents-inevitable-with-ai-coding-agents/) (90,000+ devs)
- **45.2% of developers spend significant time debugging AI output** — same survey
- **AI code creates 1.7x more bugs** than human-written code — [CodeRabbit Report](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report)
- **Code duplication grew 4x** (8.3% to 12.3% of all changed lines) since AI coding tools went mainstream — GitClear
- **322% more privilege escalation paths** in AI-generated code — [Apiiro 2024](https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/)

OpenAI literally had to [acknowledge that GPT-4 got lazy](https://www.analyticsvidhya.com/blog/2023/12/user-complained-gpt-4-being-lazy-openai-acknowledges/). Google filed a [P1 bug](https://github.com/google-gemini/gemini-cli/issues/4836) after Gemini replaced real code with `// ... (rest of the logic is the same)` — and wrote it directly to disk, destroying working implementations. Cursor users reported [AI deleting entire code blocks](https://forum.cursor.com/t/cursor-now-deleting-code-indiscriminately-loosing-context/29023) and replacing them with placeholders.

One developer testing JetBrains' Junie agent [put it perfectly](https://www.dolthub.com/blog/2025-04-23-coding-agents-suck-too/): the AI produced "impressive-looking outputs while avoiding actual, verifiable work completion" — what they called **"cosplay"** rather than real engineering.

### Why Do AI Models Do This?

It's not random. There are structural reasons your AI writes `// TODO` instead of actual code:

1. **Training data is saturated with stubs** — Stack Overflow answers use `// ...` ellipsis. Tutorials use `TODO` markers. Open-source repos are full of placeholder implementations. The model learned that incomplete code is normal because *in training data, it is.*

2. **Shorter outputs = lower compute costs** — Models are optimized (via RLHF and inference economics) to produce concise responses. Writing `pass` is cheaper than writing 40 lines of real logic. Multiple users independently documented an [~850 token output cap](https://community.openai.com/t/why-i-think-gpt-is-now-lazy/534332).

3. **Models think code is conversation** — LLMs treat `// rest of implementation here` as communicating intent to a "reader," like a colleague saying "you get the idea." The model doesn't understand that a compiler can't read your mind and `// TODO` is literally nothing.

4. **Context window degradation** — [Academic research](https://arxiv.org/html/2406.08731v1) shows longer problem descriptions cause models to "generate multiple functions until reaching the set length limit, rather than just generating the necessary function," leaving incomplete implementations.

The laziness isn't a bug. It's a feature of how these models were built. Which means you can't just ask nicely. You need enforcement.

---

## Before & After

**Without Goggins Mode** (your agent on the couch):
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

**With Goggins Mode** (your agent after running 100 miles):
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

## What Happens When You Try to Be Lazy

Real output from Goggins Mode catching an AI agent in the act. Every one of these is from an actual test run:

**Attempt:** Write a class full of TODO stubs
```javascript
class PaymentProcessor {
  processPayment(amount) {
    // TODO: implement payment processing
    return null;
  }
  refund(transactionId) {
    // FIXME: this doesn't actually work yet
    throw new Error("not implemented");
  }
}
```
**Goggins Mode:**
> `GOGGINS MODE WARNING: "NotImplementedError? Not implemented EFFORT is more like it." Violations: TODO/FIXME placeholder detected. Fix these before you move on.`

---

**Attempt:** Hand-wave an entire auth system
```python
def authenticate(username, password):
    """For brevity, the full OAuth2 flow is left as an exercise."""
    return True
```
**Goggins Mode:**
> `GOGGINS MODE WARNING: "'For brevity' means 'I got lazy.' Say it with your chest." Violations: Hand-waving detected. Fix these before you move on.`

That `return True` is doing a lot of heavy lifting for your security posture.

---

**Attempt:** Leave `console.log` debug spam everywhere
```typescript
export async function fetchUserData(userId: string) {
  console.log("DEBUG: fetching user", userId);
  // ...actual code...
  console.log("debug response:", JSON.stringify(data));
  return data;
}
```
**Goggins Mode:**
> `GOGGINS MODE WARNING: "You took a shortcut? Shortcuts are the long way around in disguise." Violations: Debug logging left in code. Fix these before you move on.`

Your users don't need to see `DEBUG: fetching user` in their browser console. Clean up after yourself.

---

**Attempt:** The ETL pipeline of broken dreams
```python
class DataPipeline:
    def extract(self, source):
        raise NotImplementedError
    def transform(self, data):
        pass
    def load(self, destination):
        ...
```
**Goggins Mode:**
> `GOGGINS MODE WARNING: "Stubs are for people who stub their toe and quit the race." Violations: NotImplementedError is a placeholder, not an implementation. Empty placeholder detected (pass/...). Fix these before you move on.`

Three methods. Three different flavors of doing nothing. Impressive commitment to non-commitment.

---

**Attempt:** The "same as above" copout
```ruby
class UserController
  def create
    # Same as above but for creating users
  end
  def update
    # For the sake of brevity, validation is omitted
  end
end
```
**Goggins Mode:**
> `GOGGINS MODE WARNING: "'For brevity' means 'I got lazy.' Say it with your chest." Violations: Hand-waving detected. "Similar to above" is not code. Fix these before you move on.`

"Same as above" is not a programming language. Write the code.

---

**Attempt:** Write clean, complete, actual code
```python
class DataPipeline:
    def extract(self, source: str) -> list[dict]:
        with open(source) as f:
            return [json.loads(line) for line in f if line.strip()]

    def transform(self, records: list[dict]) -> list[dict]:
        cleaned = []
        for record in records:
            normalized = {k.strip().lower(): v for k, v in record.items()}
            if self._validate(normalized):
                cleaned.append(normalized)
        return cleaned
```
**Goggins Mode:** *silence. Because real code doesn't need a motivational speech.*

---

## Install

### Option 1: Claude Code Plugin (Recommended)

Inside Claude Code, add the marketplace and install:

```
/plugin marketplace add sol-dev-44/goggins-mode
/plugin install goggins-mode@goggins-mode-marketplace
```

Then reload:
```
/reload-plugins
```

That's it. Three commands. Goggins Mode is now watching every file write, every edit, and every commit.

> **Note for HTTPS users:** If your machine uses HTTPS for GitHub (not SSH keys), and the install fails with `Permission denied (publickey)`, run this first:
> ```bash
> git config --global url."https://github.com/".insteadOf "git@github.com:"
> ```
> This tells git to use HTTPS instead of SSH for GitHub clones. Most developers with SSH keys set up won't need this. One-time fix.

### Option 2: Standalone Installer

For non-plugin usage — copies hooks and rules directly into your project:

```bash
# In your project directory:
curl -fsSL https://raw.githubusercontent.com/sol-dev-44/goggins-mode/main/install.sh | bash
```

Or clone and install:
```bash
git clone https://github.com/sol-dev-44/goggins-mode.git
cd goggins-mode
./install.sh /path/to/your/project
```

---

## What It Catches

| Anti-Pattern | Example | Goggins Says |
|---|---|---|
| TODO/FIXME placeholders | `// TODO: implement` | "Don't put a bookmark where your work ethic should be." |
| Stub implementations | `pass`, `NotImplementedError`, `...` | "Stubs are for people who stub their toe and quit the race." |
| Hand-waving | "for brevity", "left as exercise" | "Brevity is the soul of quitters." |
| Copy-paste excuses | "similar to above", "same as above" | "'Similar to above' — then write it. Repetition builds discipline." |
| Blind edits | Editing without reading first | "You wouldn't operate without looking at the patient." |
| Debug artifacts | `console.log("DEBUG...")` in production | "Clean up after yourself. This ain't a frat house." |
| Lazy commits | Committing files with TODO stubs | "You don't commit excuses." |

Smart enough to skip non-code files — your `README.md` can have all the TODOs it wants. Goggins Mode knows the difference between documentation and dereliction of duty.

---

## Soft Mode vs. Hard Mode

**Soft Mode** (default) — Catches violations and injects a Goggins quote as feedback. The agent sees the warning and self-corrects. Think of it as a drill sergeant standing behind you. You *can* keep going, but you know what you did.

```bash
# This is the default. Just install and go.
```

**Hard Mode** — Catches violations and **blocks execution entirely** until they're fixed. The agent literally cannot proceed with lazy code. The file write gets rejected. The commit gets blocked. No mercy. No appeals. No HR department.

```bash
export GOGGINS_MODE=hard
```

> "Soft mode is just the warmup. Hard mode is where you live."

---

## How It Works

### The Mindset (15 Rules)

Loaded as a Claude Code skill that reshapes the agent's behavior at the prompt level. These aren't suggestions. They're orders.

| # | Rule | Translation |
|---|------|-------------|
| 1 | No placeholders | If you write TODO, you're writing a lie |
| 2 | No hand-waving | "For brevity" means "I got lazy" |
| 3 | Make decisions | Don't present 3 options. Pick one and build it. |
| 4 | Read before you edit | No blind surgery |
| 5 | Write tests now | "Later" is where discipline goes to die |
| 6 | Clean up debug artifacts | This ain't a frat house |
| 7 | Finish what you start | You don't get credit for half a pullup |
| 8 | Keep it simple | Stop building a cathedral when they asked for a shelf |
| 9 | Do the work | Don't ask permission. Execute. |
| 10 | Handle your errors | Empty catch blocks are empty promises |
| 11 | Name things well | `temp`, `foo`, `data` — those aren't names, they're surrender |
| 12 | Face the wall | Debug it. Don't skip it. The wall is the way. |
| 13 | Don't repeat lazily | Copy-paste is not engineering |
| 14 | Delete dead code | Hoarding dead code is fear |
| 15 | Verify before victory | "This should work" — should? SHOULD? Prove it. |

### The Accountability (3 Hooks)

Shell-script hooks that fire automatically during Claude Code sessions. No configuration needed. No way to sweet-talk your way past them.

- **no-lazy-code** (PostToolUse on Write/Edit) — Scans every file write and edit for lazy patterns. Catches TODOs, stubs, hand-waving, debug artifacts, and placeholder functions. Skips non-code files like markdown and JSON.

- **read-before-write** (PreToolUse on Write/Edit) — Ensures existing files are read before being modified. Correctly allows writing new files. Because you wouldn't operate on a patient without looking at them first.

- **no-lazy-commits** (PreToolUse on Bash) — Intercepts `git commit` commands and scans staged changes for lazy patterns. Your TODO doesn't get to hide in a commit. Not on Goggins' watch.

Each violation delivers a contextually relevant Goggins quote from a library of 30+ quotes across 6 categories: laziness, quitting, excuses, shortcuts, comfort, and general motivation.

### Why Hooks Beat Prompts

You might think "I'll just put 'no TODOs' in my system prompt." Developers have tried that. Here's why it doesn't work:

- **Models ignore long instructions** — [Codex Discussion #7686](https://github.com/openai/codex/discussions/7686) documents Codex ignoring explicit anti-placeholder instructions as prompts grow longer
- **System prompts are suggestions, hooks are enforcement** — A system prompt says "please don't." A hook says "you literally can't."
- **Hooks can't be rationalized away** — An LLM can convince itself that `// TODO` is helpful context. It can't convince a regex.

Goggins Mode uses both: the skill reshapes intent, the hooks enforce behavior. Belt and suspenders. Because your code doesn't care about the model's intentions.

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `GOGGINS_MODE` | `soft` | Set to `hard` to block execution on violations |

That's it. One setting. Because over-configuring a discipline tool defeats the purpose.

---

## Test Results

We ran every type of lazy code we could think of through Goggins Mode. Here's the scorecard:

| # | Test | Language | Violations Triggered | Result |
|---|------|----------|---------------------|--------|
| 1 | `// TODO` + `// FIXME` stubs | JavaScript | TODO/FIXME placeholders | CAUGHT |
| 2 | "for brevity" + "left as exercise" + `...` | Python | Hand-waving, empty stubs | CAUGHT |
| 3 | `console.log("DEBUG...")` spam | TypeScript | Debug artifacts | CAUGHT |
| 4 | `NotImplementedError` + `pass` + `...` triple | Python | Stubs, placeholders | CAUGHT |
| 5 | Clean, complete, real code | Python | None | CLEAN PASS |
| 6 | "same as above" + "sake of brevity" | Ruby | Hand-waving, copouts | CAUGHT |
| 7 | TODOs in markdown docs | Markdown | N/A (non-code file) | CORRECTLY SKIPPED |

7 for 7. Every lazy pattern caught. Every clean file passed. Every markdown file left alone. Goggins doesn't do false positives.

---

## Troubleshooting

### Plugin install fails with "Permission denied (publickey)"

The Claude Code plugin system clones repos via SSH by default. If you authenticate to GitHub via HTTPS (like `gh` CLI), you'll need to tell git to rewrite SSH URLs:

```bash
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

Then retry the install. This is a one-time fix.

### Plugin not found in marketplace

Make sure you added the marketplace first:
```
/plugin marketplace add sol-dev-44/goggins-mode
```

Then install:
```
/plugin install goggins-mode@goggins-mode-marketplace
```

### Hooks not firing after install

Run `/reload-plugins` to reload all plugin hooks. If that doesn't work, restart Claude Code.

### False positive on a non-code file

Goggins Mode skips these extensions: `.md`, `.txt`, `.json`, `.yaml`, `.yml`, `.toml`, `.cfg`, `.ini`, `.env`, `.lock`. If you're hitting a false positive on another config format, open an issue.

---

## Uninstall

If you need to go back to being soft:

**Plugin:**
```
/plugin uninstall goggins-mode
```

**Standalone:**
```bash
./install.sh --uninstall
```

> "You thought you could quit? That's soft."

---

## Contributing

PRs welcome. But they better be complete. No TODOs in your PR. No stubs. No "I'll add tests later." If Goggins Mode catches lazy code in your contribution, that's poetic justice and your PR is getting rejected.

---

## License

MIT — because even discipline should be free.

---

## References

Research cited in this README:

- [GitClear — AI Code Quality 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research) — 40% code churn, 4x duplication increase
- [METR — AI Developer Productivity Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) — 19% slower, 39-point perception gap
- [Stack Overflow Developer Survey 2025](https://stackoverflow.blog/2026/01/28/are-bugs-and-incidents-inevitable-with-ai-coding-agents/) — 66% "almost right," 45.2% debugging AI output
- [CodeRabbit — AI vs Human Code Report](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report) — 1.7x more bugs
- [Apiiro — AI Coding Security Report 2024](https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/) — 322% more privilege escalation
- [OpenAI — GPT-4 Laziness Acknowledgment](https://www.analyticsvidhya.com/blog/2023/12/user-complained-gpt-4-being-lazy-openai-acknowledges/) — Officially confirmed
- [Gemini CLI Issue #4836](https://github.com/google-gemini/gemini-cli/issues/4836) — P1: Placeholder comments destroying real code
- [DoltHub — Coding Agents Suck Too](https://www.dolthub.com/blog/2025-04-23-coding-agents-suck-too/) — AI doing "cosplay" instead of engineering
- [Context Window Degradation Research](https://arxiv.org/html/2406.08731v1) — Why models degrade with longer prompts

---

*"Who's gonna carry the boats?!" — David Goggins*

*Your AI is. Now get to work.*
