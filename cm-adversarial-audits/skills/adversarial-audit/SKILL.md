---
name: adversarial-audit
description: Run a panel of independent, grounded adversarial auditors over a plan or a proposed change before committing to it. Each auditor attacks from a distinct lens, grounds every finding in real code (file:line), and the driver independently verifies each claim before harvesting only the confirmed ones. The roster (names + how many) is a config option. Use before applying any plan, before a risky refactor, or whenever the user asks for an "adversarial", "red-team", or "X-lens" audit.
tags: [audit, adversarial, audit, verification]
---

# CM Adversarial Audit

A method for catching real defects in a plan or change **before** implementing it, by generating diverse skeptical perspectives, grounding them in the actual code, and verifying before trusting.

The shape is: **generate (a panel of grounded skeptics) → verify (driver re-checks each claim) → harvest (only confirmed findings)**. It is a manual panel, not an automated vote — the driver stays in the loop.

## When to run

- Before `apply` on any non-trivial plan (the default trigger when this skill is enabled).
- Before a risky refactor, a money/security/data-integrity change, or a migration.
- Whenever the user asks for an adversarial / red-team / "X-lens" audit.

Skip for trivial or already-verified changes (one-line edits, doc tweaks).

## Step 0 — Read the auditor roster (config)

The number of auditors is **not fixed** — it is exactly the roster you are given. Read
`${CLAUDE_PROJECT_DIR:-.}/.claude/cm-audit.json` and use its `auditors` array:

```json
{ "auditors": ["Tom", "Mary", "Joan"] }
```

- Each entry is an auditor. A string is a name (you assign its lens in Step 1); an object
  `{ "name": "Tom", "lens": "…" }` pins that auditor's lens explicitly.
- **The auditor count = the roster length** (Tom, Mary, Joan → 3). Two names → 2 auditors; five → 5.
- If the file is missing or has no `auditors`, default to three: **Tom, Mary, Joan**.

Refer to auditors by their roster names throughout (findings, harvest attribution).

## Step 1 — Assign each auditor a non-overlapping lens

Decompose the *failure space* of the thing under audit so the auditors don't all find the same easy bug. Give each roster auditor a distinct lens that fits the domain (honor any pinned `lens`). Starter sets — pick/extend to match the roster size:

- **Code change**: correctness / edge cases / fail-closed · security / auth / input trust · architecture / SSOT / maintainability.
- **Money or payments**: money-correctness & idempotency · external-API semantics & server isolation · tenancy / ledger / audit-defensibility.
- **Data / migration**: data-loss & rollback · concurrency & ordering · schema/constraint integrity & backfill.
- **API / service**: contract & error handling · performance & resource limits · compatibility & versioning.

If the roster is larger than a starter set, split the space finer (e.g. add a dedicated observability, performance, or compliance lens) so no two auditors overlap. State each auditor's lens and why the set covers the space.

## Step 2 — Launch the auditors concurrently

Spawn one subagent **per roster auditor, in a single message** (so they run in parallel). Give each:

1. The artifact under audit (the plan file, the diff, or the specific files).
2. The exact source files + seams it touches (so it can ground).
3. Its name + lens, with a short list of concrete things to attack.
4. These non-negotiable rules, verbatim:
   - **Ground every finding in real code with `file_path:line` + a short quote. If you cannot ground it, drop it.**
   - **Rank by severity** (BLOCKER / CRITICAL / HIGH / nice).
   - **Be adversarial** — you are looking for defects, not reassurance. Report honest negatives (things you checked that are actually fine) so the driver knows the coverage.
   - **Do not edit anything.** Return a findings report only.

Prefer read-only auditor agents.

## Step 3 — Verify before harvesting (the part that matters)

Subagents confidently hallucinate. **Their findings are leads, not conclusions.** For each finding you intend to act on, the driver independently re-reads the cited `file:line` and confirms the defect is real. Only confirmed findings are harvested. A finding that doesn't survive verification is dropped (note it).

Convergence is signal: when multiple lenses independently flag the same issue, that's a strong indicator it's real — but still verify it.

## Step 4 — Harvest into the plan/change

Fold the confirmed findings back into the artifact as an explicit, numbered fix list (e.g. `HR-1..HR-n`) with, for each: severity, the defect, the grounding `file:line`, and the concrete fix. If auditing a plan, add/adjust acceptance criteria to lock in each fix. Record which auditor(s)/lens(es) raised it and that it was driver-verified. Then proceed to implement against the hardened artifact.

## Scale to the ask

- "quick look" → the roster, single-pass, verify the top findings.
- "thorough" / "be comprehensive" → after harvest, spawn a second round of verifiers to adversarially refute the surviving findings (majority-refute → drop), and a completeness critic ("what modality/claim wasn't checked?").
- Need more/fewer perspectives for one run? Adjust the roster in `.claude/cm-audit.json` (or via `/cm-audit-on Name1 Name2 …`).

## Anti-patterns

- Trusting a subagent's "BLOCKER" without reading the code yourself.
- Auditors with overlapping lenses (redundant coverage, blind spots elsewhere).
- Harvesting ungrounded findings ("this could be a problem" with no file:line).
- Silent truncation — if you only audited part of the change, say so.
