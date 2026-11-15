# agent-kit

This repository is the kit, not a project that uses it. It holds generic agent skills and contract templates that
take a task from the tracker to a pull request. They grew out of real work and are meant to be reused across many
repositories. A project takes the skills it needs by `INDEX.md`, fills the contract `docs/agents/*.md` they read
and tailors its copy; edits good for every project come back here.

Everything here stays project-agnostic: a path, command, tracker name or stack rule of a specific project belongs in
that project's `docs/agents/`, a shared stack rule in `packs/`. Folder layout, placeholders (`{{p}}`, `{{KEY}}`) and
markers: «How it works» below.

`INDEX.md` is the guide: which skills to take for which project, which work alone, which go as a set. A commit that
adds, removes or changes a skill updates it in the same commit.

## How it works

The skills know nothing about a project. They read every fact — paths, commands, tracker, rules — from the project's
own `docs/agents/*.md`. These files are called the contract: the kit gives templates, the project fills them in.

### What's in the repository

| Folder | What | Where it lands in a project |
| --- | --- | --- |
| `skills/` | 20 skills | `.agents/skills/<prefix>-*` (`.claude/skills` links to it); optional subagent definitions go to `.agents/agents/` (`.claude/agents` links to it) |
| `contract/` | templates of `docs/agents/*.md`; `<!-- fill: ... -->` marks what the project fills in | `docs/agents/` |
| `packs/` | packs — stack rules: `python`, `django` | appended to `code-rules.md`, `hygiene.md`, `testing.md` |
| `repo/` | `CONTRIBUTING.md` sections, an `AGENTS.md` snippet, `.claude/settings.json`, Codex rules, pre-commit hooks | the project root |
| `examples/tg-sales-bot/` | the filled contract of a live project | a sample to fill from |

### The contract: docs/agents/

| File | What it holds |
| --- | --- |
| `domain.md` | `CONTEXT.md`, ADRs, glossary |
| `issue-tracker.md` | tracker, task key, tools, task language, where working files live, where document copies go |
| `product.md` | behaviour spec, actors, what only a manual check shows, the E2E actor |
| `stack.md` | stack, code layout, the `check` / `unit` / `e2e` / `one-test` / `migrate` commands, line counting |
| `git.md` | commit format, main branch, task and part branches, how to open a PR and work its review threads, agent identity |
| `harness.md` | roles, tiers and actions mapped per harness: subagents, models, asking the user, agent identity |
| `code-rules.md` | layers, where code goes, ticket slicing, code rules |
| `hygiene.md` | the checklist for changed files |
| `testing.md` | test stack, database, mocks, file placement, E2E harness, reference tests |

### Modules

A module is an optional part of the kit, off unless you take it:

- `business-questions` — business question themes in the tracker and the rule «a task isn't closed until the answers
  are in». Not needed for personal projects.
- `codegraph` — the «Code search» section of `AGENTS.md`; offered only when the project has `.codegraph/`.

### A stack without a pack

Packs exist for Python and Django. For another stack (FastAPI, Go) the agent fills `code-rules.md`, `hygiene.md`
and `testing.md` from your answers and the code. Once the rules settle, move the stack's part into
`packs/<stack>/` — the next project on that stack gets it right away.

A project fact — a path, a command, a tracker name — never goes into the kit: it belongs in `docs/agents/`.

### Placeholders and markers

| Mark | Where | Replaced by |
| --- | --- | --- |
| `{{p}}` | skills, contract, repo | the project's skill prefix |
| `{{work}}` | skills, contract, repo | the working folder of task files, `.ai` by default |
| `{{KEY}}`, `{{key}}`, `{{main}}` | repo | the task key, its lowercase form, the main branch |
| `<KEY>`, `<key>` | skills | stays: the skill reads the key from `docs/agents/issue-tracker.md` |
| `<!-- pack:NAME -->…<!-- /pack:NAME -->` | contract | the pack's text, marked so an update finds it in the project |
| `<!-- module:NAME -->…<!-- /module:NAME -->` | contract, repo | kept or cut out along with the module |

In `examples/`, an empty `<!-- pack:NAME -->` pair stands for the pack's text.
