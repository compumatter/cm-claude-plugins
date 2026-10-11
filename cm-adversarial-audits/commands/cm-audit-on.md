---
description: Enable the CM adversarial audit — run an auditor panel before applying plans / risky changes
allowed-tools: Bash
---

Enable the CM adversarial audit for this project, and (optionally) set the auditor roster.

The number of auditors is NOT baked into the command — it is simply how many names are in the roster
config (e.g. `Tom, Mary, Joan` = 3 auditors, each given a distinct lens).

1. Create the marker file so the on/off state persists across sessions:
   ```bash
   mkdir -p "${CLAUDE_PROJECT_DIR:-.}/.claude" && touch "${CLAUDE_PROJECT_DIR:-.}/.claude/cm-audit.enabled"
   ```

2. Set the auditor roster. If the user passed names as arguments ($ARGUMENTS — a comma/space-separated
   list like `Tom, Mary, Joan`), write them; otherwise seed a default roster of three ONLY IF no config
   already exists (never clobber an existing roster):
   ```bash
   CFG="${CLAUDE_PROJECT_DIR:-.}/.claude/cm-audit.json"
   ARGS="$ARGUMENTS"
   if [ -n "$ARGS" ]; then
     # Turn "Tom, Mary, Joan" (or space-separated) into a JSON array of names.
     NAMES=$(printf '%s' "$ARGS" | tr ',' ' ' | xargs -n1 2>/dev/null | awk 'NF' | \
       awk 'BEGIN{printf "["} {printf "%s\"%s\"", (NR>1?", ":""), $0} END{print "]"}')
     printf '{\n  "auditors": %s\n}\n' "$NAMES" > "$CFG"
     echo "Auditor roster set to: $ARGS"
   elif [ ! -f "$CFG" ]; then
     printf '{\n  "auditors": ["Tom", "Mary", "Joan"]\n}\n' > "$CFG"
     echo "Seeded a default 3-auditor roster (Tom, Mary, Joan). Edit .claude/cm-audit.json to change it."
   else
     echo "Kept the existing auditor roster in .claude/cm-audit.json."
   fi
   ```

3. Confirm to the user: "CM adversarial audit is now ON. Before applying any plan or non-trivial change,
   I'll run the `adversarial-audit` skill — a panel of the configured auditors (see `.claude/cm-audit.json`,
   one distinct lens each) → independently verify each finding against real code → harvest only the confirmed
   ones. Change the roster by editing `.claude/cm-audit.json` or re-running `/cm-audit-on Tom Mary Joan`.
   Turn it off with `/cm-audit-off`."

From now on, whenever you are about to apply a plan, do a risky refactor, or make a money/security/
data-integrity change, invoke the `adversarial-audit` skill first.
