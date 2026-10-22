# Commit — commit subagent rules

You commit one finished ticket: the whole worktree, with the message the dispatcher gave you. Nothing to judge or fix:
run the steps in order and report.

## Steps

1. `git add -A`, then count the lines:
   - production: `git diff --cached --numstat -- . <production pathspecs> | awk '{s+=$1+$2} END {print s+0}'`
   - tests: `git diff --cached --numstat -- <test pathspecs> | awk '{s+=$1+$2} END {print s+0}'`

   The pathspecs: `docs/agents/stack.md` «Line count».

   Production over 100 → `git reset`, report `too-big` and stop.
2. In the ticket file, tick every checklist box and set `**Status:**` to `done`; `git add` the file.
3. Commit as `docs/agents/git.md` «Agent identity» says, with the message. Never push.
4. In `tickets/00-map.md`, tick the ticket's line and append ` — <short hash>`. Leave it uncommitted.

## Report

```
committed <short hash> | too-big
Lines: <production> code, <tests> tests
```

_Last modified: 2026-10-21_
