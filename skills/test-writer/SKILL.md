---
name: {{p}}-test-writer
description: Write tests — unit tests for the project's modules and E2E actor scenarios. Use when the user asks to write, add, or improve tests, E2E scenarios or test coverage.
---

# Test writer

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands». Actors: `docs/agents/product.md` «Actors».

All testing rules live in `rules.md` next to this file and in `docs/agents/testing.md`. Read them only when a branch below tells you to write the tests yourself.

**You are a sub-agent** (spawned to run this skill) — read `rules.md` and do everything it says yourself. Delegate nothing further.

**You are the main agent on Opus** — delegate, then verify. Leave `rules.md` and the source code unread until verification needs them.

1. Pin down the scope from the user's request: which module, function or class, and which behaviours — or, for E2E, which actor scenarios. Ask the user if that is unclear.
2. Spawn one sub-agent with the `Agent` tool:
   - `subagent_type`: `general-purpose`, `model`: `sonnet` — never `fork`: a fork inherits this context and saves nothing
   - prompt: the scope from point 1, stated concretely, plus: *"Read `.claude/skills/{{p}}-test-writer/rules.md` and follow it end to end. You are the sub-agent — do not spawn anything. You cannot talk to the user: if you hit a STOP condition, stop and return it as your result."*
3. One sub-agent per run, even for several target modules. Reviewing its work is your job, not a second sub-agent's.
4. Relay its final report to the user in your own message — the sub-agent's report is not shown to them. A STOP condition → relay it verbatim and stop; production code stays untouched.

Then verify, as far as the result warrants:

- `check` green and the test list matches the scope → read the test file once, confirm the parametrize merges and the AAA/naming rules hold, done.
- `check` not green, tests drift outside the scope, or the report is vague about merges → read `rules.md`, `docs/agents/testing.md`, the test file and the source under test, fix it yourself inline.

**You are the main agent on a model below Opus** — read `rules.md` and write the tests yourself. Delegating Sonnet to Sonnet buys nothing.

_Last modified: 2026-10-22_
