---
name: {{p}}-hygiene-review
description: Scan changed or new files for hygiene issues the linters and the type checker miss, by the checklist in docs/agents/hygiene.md. Use after implementing a change, on the changed files.
---

# Hygiene review

Spawn an explorer (`docs/agents/harness.md` «Roles») to scan the changed/new files against `docs/agents/hygiene.md`.
Report findings; fixing needs a judgement call, so ask before touching.

## Steps

1. Spawn the explorer, cheap tier, with the prompt below, `{CHANGED_FILES}` and `{DIFF_BASE}` filled in.
   `{DIFF_BASE}` is `HEAD` for uncommitted work, otherwise the commit or branch the change started from.
2. Report each finding to the user.

## Subagent prompt

```
Scan these changed/new files for hygiene issues. Report only, fix nothing.

Files:
{CHANGED_FILES}

Diff base: {DIFF_BASE}

Read docs/agents/hygiene.md: every heading is one rule — a condition and the line to report.
Run `git diff {DIFF_BASE} -- <file>` for each file; an untracked file is entirely new. Check the added and changed
lines against every rule; the rest of the file is context.

Output: one line per finding, in the formats of the rules. Nothing found → "No hygiene issues found."
```

_Last modified: 2026-11-11_
