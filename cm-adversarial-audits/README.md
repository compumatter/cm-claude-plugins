# CM Adversarial Audit (Claude Code plugin)

Catch real defects in a plan or change **before** implementing it: spin up a panel of independent, grounded
adversarial auditors (each with a distinct lens), **independently verify** every finding against the real
code, and harvest only the confirmed ones. A manual panel, with the driver staying in the loop, not an
automated vote.

> generate (a panel of grounded skeptics) -> verify (driver re-checks each claim) -> harvest (only confirmed findings)

**The roster is a config option.** The number of auditors is simply how many names you list: `Tom, Mary,
Joan` is a 3-auditor panel; add or remove names to change it. Nothing about the count is baked into the
command or skill.

## Not tied to any workflow

This plugin is **standalone**: it works for a plain Claude Code user with no other framework. The hook fires
on *your* prompts (when enabled) and reminds Claude to run the audit before applying a plan or a non-trivial
change, where "a plan" means any plan or change you are about to implement, not a specific tool's apply step.

## Install

```bash
claude plugin marketplace add compumatter/cm-claude-plugins
claude plugin install cm-adversarial-audits@cm-claude-plugins
```
Or, inside a Claude Code session, in one step: `/plugin install cm-adversarial-audits --marketplace compumatter/cm-claude-plugins`

The plugin installs disabled (`defaultEnabled` is `false`). Enable it, then restart Claude Code (plugins load at
startup):
```bash
claude plugin enable cm-adversarial-audits@cm-claude-plugins
```
Even enabled, the hook is a deliberate no-op until a per-project marker exists, so in each project where you want
audits run `/cm-audit-on`. It is zero-cost until wanted. Each audit launches one agent per auditor, so it
costs tokens; `/cm-audit-off` stops it.

## What's in the box

| Piece | File | Role |
|-------|------|------|
| Skill (the method) | `skills/adversarial-audit/SKILL.md` | Read the roster, assign lenses, grounding rules, verify-before-harvest, harvest format |
| Toggle on | `commands/cm-audit-on.md` | `/cm-audit-on [Name ...]`: creates the project marker and (optionally) sets the roster |
| Toggle off | `commands/cm-audit-off.md` | `/cm-audit-off`: removes the marker (keeps the roster) |
| Auto-trigger | `hooks/hooks.json` + `hooks/check-enabled.sh` | When the marker is present, injects a per-turn reminder to run the skill before applying plans / risky changes |

Two per-project files hold the state:
- `.claude/cm-audit.enabled`: the on/off marker (persists across sessions).
- `.claude/cm-audit.json`: the auditor roster, e.g. `{ "auditors": ["Tom", "Mary", "Joan"] }`. Entries can
  be names (the skill assigns each a lens) or `{ "name": "...", "lens": "..." }` to pin a lens.

- Want it enabled just for *you* in this repo? Keep `.claude/cm-audit.enabled` (and `.json`) out of git;
  they stay a personal, per-machine setting.
- Want the whole team to get it for this repo? Commit them instead.

## Usage

- **Ad hoc**: just ask for an "adversarial" / "red-team" audit, or invoke the `adversarial-audit` skill; no toggle needed.
- **Always-on for a repo**: run `/cm-audit-on` (optionally `/cm-audit-on Tom Mary Joan` to set the roster).
  From then on, before applying a plan or a non-trivial change, Claude runs the audit first. `/cm-audit-off` stops it.

`hooks/check-enabled.sh` must stay executable; if you ever copy this tree by a route that strips the bit,
`chmod +x` it again.

## Design notes / where to improve

- **Roster is a config option.** The auditor count and names live in `.claude/cm-audit.json`; the skill reads them and gives each a distinct lens.
- **Lenses are domain-specific.** The skill lists starter sets (code / money / data / API); extend them, and split finer for a larger roster.
- **The verify step is the point.** LLM auditors hallucinate confident "blockers"; the value is grounding plus an independent re-check before trusting.
- **Scale knob.** "thorough" mode adds a second refute round and a completeness critic.
- Possible additions: per-auditor pinned lens presets, a severity threshold that blocks apply via a `PreToolUse` hook, or emitting the harvest to a file.

## Licence

MIT, see [LICENSE](LICENSE). Copyright (c) 2026 CompuMatter.
