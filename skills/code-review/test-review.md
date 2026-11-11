# Test review — reviewer rules

You review the changed test files of a diff and report every assert that pins implementation instead of observable
behaviour, and every new test that stays green without the change. Report only: change no file, spawn nothing.

Your prompt carries the test file list and a diff base. The general test rules: `.agents/skills/{{p}}-test-writer/rules.md`
«Test observable behavior»; the project's process boundary: `docs/agents/testing.md` «Mocks».

## Steps

1. `git diff <diff base> -- <files>`. An untracked file has no diff: treat it as entirely new.
2. Read each test file in full, then the production code each changed test calls.
3. Run the **refactoring probe** on every assert, mock expectation and expected-error check added or changed in the
   diff.
4. Run the **red probe** on every new test.

Done when every added or changed assert and every new test in every file has been probed.

## Red probe

Name the production change in the branch diff whose revert turns the test red. None → the test passes on the old code
and checks the default. Report it.

Example: an endpoint test sends a new value and asserts only a success status, with the service that produces the
effect mocked, and the endpoint accepted that value before the branch → report.

## Refactoring probe

For each assert, name the smallest production change that turns it red. Then ask: does a user or the calling code see
that change?

- Seen — a different return value, response, saved or deleted row, raised error, a request that leaves the process →
  behaviour. Passes.
- Unseen — a log level or message, a query count, an ORM call shape, a private helper's call list → implementation.
  Report it.

Example: an assert on a mocked logger's `warning` turns red when `warning` becomes `error`. Nobody outside the process
sees the change → report.

## Implementation signals

Each is a strong hint; confirm it with the probe before reporting.

- A logger asserted: level, message text, structured keys, captured log records.
- Query-count checks, prefetch or join checks.
- Call assertions (`called`, call count, call arguments) on a project function, method or private helper. A mock at the
  process boundary of `testing.md` «Mocks» is behaviour: its call arguments are what leaves the process.
- An entry-point test (view, handler, command) asserting what the service computes or saves — that belongs in the
  service's own test.

## Report

One line per finding: `file:line — <test name> — red probe | refactoring probe — <what it pins or why it stays green> →
<what to assert instead, or drop>`. Nothing found → «No test findings.»
