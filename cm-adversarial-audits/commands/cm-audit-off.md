---
description: Disable the CM adversarial audit for this project
allowed-tools: Bash
---

Disable the CM adversarial audit for this project.

1. Remove the marker file (the auditor roster in `.claude/cm-audit.json` is left in place, so re-enabling
   restores the same panel):
   ```bash
   rm -f "${CLAUDE_PROJECT_DIR:-.}/.claude/cm-audit.enabled"
   ```
2. Confirm to the user: "CM adversarial audit is now OFF. Re-enable with `/cm-audit-on`. You can still run
   it any time by asking for an 'adversarial' / 'red-team' audit or invoking the `adversarial-audit`
   skill directly."
