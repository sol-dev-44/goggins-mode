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

Inside Claude Code:
```
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
