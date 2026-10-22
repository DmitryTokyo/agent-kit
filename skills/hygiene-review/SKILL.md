---
name: {{p}}-hygiene-review
description: Scan changed or new files for hygiene issues the linters and the type checker miss, by the checklist in docs/agents/hygiene.md. Use after implementing a change, on the changed files.
---

# Hygiene review

Spawn an Explore subagent to scan the changed/new files against `docs/agents/hygiene.md`. Report findings; fixing needs
a judgement call, so ask before touching.

## Steps

1. Spawn `Agent(subagent_type="Explore")` with the prompt below, `{CHANGED_FILES}` filled in.
2. Report each finding to the user.

## Subagent prompt

```
Scan these changed/new files for hygiene issues. Report only, fix nothing.

Files:
{CHANGED_FILES}

Read docs/agents/hygiene.md: every heading is one rule — a condition and the line to report.
Check each file against every rule.

Output: one line per finding, in the formats of the rules. Nothing found → "No hygiene issues found."
```

_Last modified: 2026-10-22_
