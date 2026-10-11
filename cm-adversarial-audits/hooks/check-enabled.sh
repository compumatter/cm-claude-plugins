#!/usr/bin/env bash
# UserPromptSubmit hook for the cm-adversarial-audits plugin.
# Fires only when the project marker (.claude/cm-audit.enabled) is present — i.e. after /cm-audit-on.
# When enabled, injects a short reminder so the model runs the adversarial-audit skill before applying
# a plan or making a non-trivial change. Silent (no-op) when disabled, so the plugin costs nothing until
# the user opts in.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
MARKER="$PROJECT_DIR/.claude/cm-audit.enabled"

# Drain stdin (the hook receives a JSON payload we don't need here).
cat >/dev/null 2>&1 || true

if [ -f "$MARKER" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[cm-adversarial-audits ON] Before applying a plan or making a non-trivial / money / security / data-integrity change, invoke the `adversarial-audit` skill first. Read the auditor roster from .claude/cm-audit.json (the `auditors` array — the number of auditors is just its length; default Tom, Mary, Joan). Give each auditor a distinct lens, independently verify each finding against real code (file:line), and harvest only the confirmed ones. Skip for trivial edits. Turn off with /cm-audit-off."
  }
}
EOF
fi

exit 0
