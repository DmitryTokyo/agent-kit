---
name: {{p}}-integration-test
description: Write the integration test a task's integration.md specifies — one real request to an entry point through the whole path inside the system, asserting the stored state. Use when the code of a task is done and its folder has integration.md, or when the user asks for an integration test.
---

# Integration test

Commands (`check`, `one-test`) are keys of `docs/agents/stack.md` «Commands».

An integration test sends one real request to an entry point (an endpoint, a handler, a command) and runs the whole
path inside the system. It mocks every call that leaves the process, `docs/agents/testing.md` «Mocks»: external APIs,
payment providers, the project's other services. A test against a real external service is end-to-end and needs its
own environment. Project code is never mocked: services and validators run for real, their data comes from the
project's factories or fixtures.

You write the test yourself; never delegate it.

## Input

`{{work}}/tasks/<task>/integration.md`: Test, Path, Arrange, Assert, Domain, Mocks, Replaces, Goes red when, Run. No
file → ask the user (`docs/agents/harness.md` «Actions») for the path to test and write the same sections into a new
`integration.md` first.

## Rules

From `.agents/skills/{{p}}-test-writer/rules.md` apply «Testing rules» and «Parametrize»; from `docs/agents/testing.md`
«Database», «Mocks» and «Integration tests». The workflow of `rules.md` is for unit tests.

- One request in Act; the asserts read the stored state after it: records, statuses, the requests that left the
  process.
- `parametrize` rows are literals, one row per value of `Domain`: the whole domain the path serves, not only the value
  the task adds.
- A response-only test of the same path named in `Replaces` is deleted once this test is green.

## Steps

1. Read `integration.md` and the entry point and services on its path. Done when every Arrange line maps to a factory
   or fixture you found.
2. Write the test where `Test` says. Done when it matches every Assert line and mocks only what `Mocks` lists.
3. Run the `Run` command. Green → step 4. Red → fix the test; a failure that points at production code is a finding:
   stop and report it.
4. Red check: for each `Goes red when` line, revert that production line, run, restore it. Done when each revert turned
   the test red and `git diff --stat` of the production files matches the one before this step.
5. Run `check`.
6. Report: test name and file, run result, each red check with its failure line, `check` result, the replaced test
   deleted, every departure from `integration.md`.

_Last modified: 2026-11-11_
