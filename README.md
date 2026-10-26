# agent-kit

**English** · [Русский](README.ru.md)

A core of Claude Code skills for taking a task end to end: task → plan → tickets → orchestrator → TDD → review →
commit. The skills know nothing about a project: they read every project fact from the project's own
`docs/agents/*.md`.

## What's inside

| Folder | What | Where it lands in a project |
| --- | --- | --- |
| `skills/` | 14 skills plus `bootstrap` and `sync` | `.claude/skills/<prefix>-*`; `bootstrap` and `sync` are not copied |
| `contract/` | templates of `docs/agents/*.md`; `<!-- fill: ... -->` marks what the project fills in | `docs/agents/` |
| `packs/` | stack rules: `python`, `django` | appended to `code-rules.md`, `hygiene.md`, `testing.md` |
| `repo/` | `CONTRIBUTING.md` sections, a `CLAUDE.md` snippet, `.claude/settings.json`, pre-commit hooks | the project root |
| `scripts/render.sh` | the core at a given commit with the prefix filled in | used by `bootstrap` and `sync` |
| `examples/tg-sales-bot/` | the filled contract of a live project | a sample to fill from |

### The contract: docs/agents/

| File | What it holds |
| --- | --- |
| `domain.md` | `CONTEXT.md`, ADRs, glossary |
| `issue-tracker.md` | tracker, task key, tools, task language, where working files live |
| `product.md` | behaviour spec, actors, what only a manual check shows, the E2E actor |
| `stack.md` | stack, code layout, the `check` / `unit` / `e2e` / `one-test` / `migrate` commands, line counting |
| `git.md` | commit format, main branch, batch branch, how to open a PR, agent identity, review tags |
| `code-rules.md` | layers, where code goes, ticket slicing, code rules |
| `hygiene.md` | the checklist for changed files |
| `testing.md` | test stack, database, mocks, file placement, E2E harness, reference tests |

## Set up a new project

1. Clone the core if it isn't there yet:

   ```bash
   git clone git@github.com:DmitryTokyo/agent-kit.git ~/dev/personal/agent-kit
   ```

2. Commit everything in the project: the install lands as one diff.
3. Open Claude Code in the project root and say:

   > Read `~/dev/personal/agent-kit/skills/bootstrap/SKILL.md` and follow it.

4. `bootstrap` reads the project and asks its questions in one message: skill prefix, task key, tracker, main branch
   and pull requests, stack and packs, commands, behaviour and actors, modules. You pick the prefix and the key.
5. It lists the files. After your yes it installs the skills, fills `docs/agents/`, extends `CLAUDE.md`,
   `CONTRIBUTING.md`, `.claude/settings.json`, `.pre-commit-config.yaml`, and writes `.claude/agent-kit.json`.
6. Finish by hand:
   - go through the `<!-- fill -->` marks left — `bootstrap` lists them in its report;
   - `pre-commit install --hook-type commit-msg`;
   - review `git diff` and commit.

### Modules

Off by default; `bootstrap` asks about each:

- `business-questions` — business question themes in the tracker and the rule «a task isn't closed until the answers
  are in». Not needed for personal projects.
- `codegraph` — the «Code search» section of `CLAUDE.md`; offered only when the project has `.codegraph/`.

### A stack without a pack

Packs exist for Python and Django. For another stack (FastAPI, Go) `bootstrap` fills `code-rules.md`, `hygiene.md`
and `testing.md` from your answers and the code. Once the rules settle, ask `sync` to turn them into a pack — the
next project on that stack gets them right away.

## Sync

In the root of an installed project:

> Read `~/dev/personal/agent-kit/skills/sync/SKILL.md` and follow it.

- **Project edits → core.** `sync` shows every edit to skills and packs since the last sync. For each you answer
  `в ядро` (to the core), `оставить` (keep in this project only) or `откатить` (revert). Edits sent to the core
  become a commit in `agent-kit`; pushed after your yes.
- **Core → project.** Core changes merge three-way on top of your local edits; `sync` shows conflicts and asks.
  Changes to `contract/` and `repo/` arrive as proposals.

A project fact — a path, a command, a tracker name — never goes into the core: it belongs in `docs/agents/`.

## Placeholders and markers

| Mark | Where | Replaced by |
| --- | --- | --- |
| `{{p}}` | skills, contract, repo | the project's skill prefix |
| `{{KEY}}`, `{{key}}`, `{{main}}` | repo | the task key, its lowercase form, the main branch |
| `<KEY>`, `<key>` | skills | stays: the skill reads the key from `docs/agents/issue-tracker.md` |
| `<!-- pack:NAME -->…<!-- /pack:NAME -->` | contract | the pack's text; `sync` finds it in the project by the markers |
| `<!-- module:NAME -->…<!-- /module:NAME -->` | contract, repo | kept or cut out along with the module |

In `examples/`, an empty `<!-- pack:NAME -->` pair stands for the pack's text.
