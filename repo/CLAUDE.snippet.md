## Git

Never push to `{{main}}`: stop and tell the user to do it themselves. Push only the batch branch of `/{{p}}-orchestrate`. Agent commits are made as `Claude <noreply@anthropic.com>` with a `Co-Authored-By` trailer — never strip them, the user tells their changes from the agent's by them.

## Agent skills

### Development

When I ask you to write, develop, build or fix something in code, offer to invoke the `/{{p}}-develop` skill before starting. It covers layers and responsibility boundaries, verification commands, the layout inside an app, constant rules, Celery and code quality. Tests go through `/{{p}}-test-writer`, which `/{{p}}-develop` references. A batch of tickets from a task's map goes through `/{{p}}-orchestrate {{KEY}}-N`. A single ticket from `.ai/tasks/{{key}}-N-*/tickets/` is routed by its `Режим` (mode) field: `TDD` and `E2E` go through `/{{p}}-tdd-develop`, `без тестов` (no tests) goes through `/{{p}}-develop`.

Task chain and code review tags: `CONTRIBUTING.md` «Feature workflow» and «Code review».

<!-- module:codegraph -->
### Code search

CodeGraph indexes the Python code. A structural question goes to it, by its MCP tools when the `codegraph` server is connected, by the CLI otherwise:

- who calls a symbol → `codegraph callers <symbol>`
- what a change to a symbol reaches → `codegraph impact <symbol>`
- which tests cover changed files → `codegraph affected <files> -q`
- one symbol with its source and call trail → `codegraph node <name>`
- an unfamiliar area, full sources included (about 20 KB per call) → `codegraph explore <words>`, inside `/{{p}}-recon`

The CLI reads the index as of the last `codegraph sync`; run it after editing files. Text outside Python code — `docs/`, skills, string literals in tests — goes to grep.
<!-- /module:codegraph -->

### Issue tracker

Epics and tasks live in the tracker of `docs/agents/issue-tracker.md`. A task's working files are in `.ai/tasks/{{key}}-N-*/`. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` in the repository root. See `docs/agents/domain.md`.

<!-- module:business-questions -->
### Business questions gate

The business-questions project of `docs/agents/issue-tracker.md` «Business questions» is the gate: one theme per issue, `Done` means every question in the theme is answered and distributed. When starting a task, before handing over a manual check, and before moving a task to Done:

1. Read the task's «blocked by» relations. If any blocker from that project is not `Done`, stop and name the theme with its key and the questions from the task's «Ждёт от бизнеса» section. Continue only after the user moves it to `Done` or says to proceed.
2. List the project's issues with priority `Urgent` or `High` that are not `Done`, and name each with its key and what it blocks.

A business question that comes up in conversation goes into its theme right away through `/{{p}}-business-questions`; the same skill walks a theme for unasked questions and distributes the partner's answers.
<!-- /module:business-questions -->
