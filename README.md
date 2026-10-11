# cm-claude-plugins

CompuMatter's plugins for Claude Code. This repository is a Claude Code plugin marketplace: add it once, then
install the plugins you want from it.

```bash
claude plugin marketplace add compumatter/cm-claude-plugins
```

## cm-adversarial-audits (free, MIT)

Before Claude applies a plan or a non-trivial change, a panel of independent auditors attacks it first. Each
auditor gets a distinct lens (for example correctness, security, blast radius), must ground every finding in
real code with file and line, and ranks it by severity. The driving session then re-checks each finding itself
and keeps only the confirmed ones, which are folded back into the plan as a numbered fix list before any code
is written. The roster is a config option: the number of auditors is simply how many names you list. Details
in [cm-adversarial-audits/README.md](cm-adversarial-audits/README.md).

Install:
```bash
claude plugin install cm-adversarial-audits@cm-claude-plugins
```
Or, inside a Claude Code session, in one step: `/plugin install cm-adversarial-audits --marketplace compumatter/cm-claude-plugins`

The plugin installs disabled. Enable it, then restart Claude Code:
```bash
claude plugin enable cm-adversarial-audits@cm-claude-plugins
```
Then in each project where you want audits run `/cm-audit-on`. Nothing runs until you do. Each audit launches one agent per auditor (three by default), so it costs tokens; `/cm-audit-off` stops it.

## cm-autoclear (paid)

A Claude Code plugin that packages the "auto-clear handoff" framework CompuMatter built and proved on two
machines in October 2026: a launcher script that opens a fresh Claude session in a new tmux window with a
self-sufficient opening prompt, a `claude-ac` shell command that starts Claude inside a per-project tmux
session, an always-on rule (injected by a SessionStart hook) that tells every session when and how to hand
off, four slash commands (setup, handoff, cleanup, status), and plain-language docs. A long session that
decides it is time to hand off writes the handoff and starts its own successor, so unattended work keeps
going without anyone pressing /clear.

Price: $19.00 one-time, updates included. It will be sold as a zip download from aicodeplugins.com; the store
is not open yet. The zip contains the plugin, its licence and the install instructions. cm-autoclear is not in
this repository and is not covered by this repository's MIT licence.

Requirements: Linux (tested on Ubuntu 22.04; macOS untested), bash 4+, tmux 2.6+, Claude Code 2.1+ logged in.
Sessions it starts run with permissions bypassed by default (configurable).

## Issues and support

Issues here are for cm-adversarial-audits; cm-autoclear support comes with the purchase.

## Layout (for contributors)

```
.claude-plugin/marketplace.json     marketplace manifest (repo root); its plugin version and
                                    cm-adversarial-audits/.claude-plugin/plugin.json move together
cm-adversarial-audits/              the plugin: plugin.json, README, LICENSE, commands/, hooks/, skills/
LICENSE                             MIT, for this repository and the free plugin
```
