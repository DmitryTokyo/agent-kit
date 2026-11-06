# agent-kit

**English** · [Русский](README.ru.md)

A set of agent skills for any coding harness, with which an agent takes a task from
its creation to a pull request: files it in the tracker, writes a plan, cuts it into small tickets, writes tests and
code, checks its own work and commits. You approve the key steps and look at the result in the pull request.

The kit is for you if you:

- work on a project alone and write code together with a coding agent, maybe in more than one harness;
- want the agent to follow one process in all your projects instead of rules you explain again each time;
- keep tasks in a tracker and want branches and commits tied to them;
- want code to go through tests and review, and the agent never to push to the main branch.

It isn't needed for one-off edits and questions: the process only gets in the way there.

## Tested with

- Harnesses: Claude Code, OpenCode, Codex.
- Models: Claude, DeepSeek.

Another harness works once `docs/agents/harness.md` has a section for it: `bootstrap` writes one from your answers.

## A starting point

The kit is a starting point, not a finished set. After the install the skills are plain files in the project's
`.agents/skills/`, and they are worth tailoring to the project: its stack, its tracker, your habits and the mistakes
the agent makes right here. Edit them in the project.

Drifting away from the kit is fine. `sync` asks about each edit whether it is shared or for this project only, and an
edit kept for this project survives updates from the kit. Send to the kit only what would help any project.

## Install

1. Clone the kit:

   ```bash
   git clone git@github.com:DmitryTokyo/agent-kit.git ~/dev/personal/agent-kit
   ```

2. Commit everything in the project: the install lands as one diff.
3. Open your agent in the project root and say:

   > Read `~/dev/personal/agent-kit/skills/bootstrap/SKILL.md` and follow it.

   Know some answers already? Add them to the same line, and the agent asks only about the rest:

   > Read `~/dev/personal/agent-kit/skills/bootstrap/SKILL.md` and follow it. Prefix ag, key AG, GitHub, Linear,
   > folder .ai.

4. The agent reads the project and sends its questions in one message, each with a suggested answer. Two answers are
   yours alone: the skill prefix (`ag` → the skills are called `/ag-develop`, `/ag-orchestrate`) and the task key in
   the tracker (`AG`).
5. The agent shows which files it will create and change. After your yes it installs the skills and sets up the
   project.
6. Finish by hand:
   - turn on the commit message check:

     ```bash
     pre-commit install --hook-type commit-msg
     ```

   - fill in what the agent couldn't fill itself — it lists those places in its report;
   - review `git diff` and commit.

## How to use it

Write to the agent in plain words — the right skill picks itself up. The examples use the prefix `ag` and the key
`AG`.

**A new task from start to finish:**

```text
File a task: the buyer picks a pickup point on the map.
Write a plan for AG-55.
/ag-to-tickets AG-55
/ag-orchestrate AG-55
```

`create-plan` first classifies the task — product value, work type, risk — and picks a route: a known local fix, or
research first. Then it writes one short `plan.md` for you: result, criteria, boundaries, the checks behind each
consequence, and whether you need to review the change. You approve it once; the agent comes back only on a
deviation. A small task goes straight to `develop`. A bigger one goes through `to-tickets`: one ticket is one commit of
at most 100 lines of code, tickets are grouped into parts, one part is one branch and one pull request.
`orchestrate` takes the next part and walks each ticket through: subagents write the tests and the code, review them
and commit.

**Review and pull request:**

```text
/ag-code-review AG-55 pickup-step          ← in a new session, another model welcome
/ag-merge-request                          ← pushes and opens the pull request
I've reviewed the PR, handle my comments.  ← you left comments on the diff
The PR is merged.                          ← /ag-close-merge-request: tracker, Done, cleanup
```

**Without tickets:**

```text
Fix: a full name with a trailing dot is rejected.
Add tests for picking a pickup point.
Prepare a commit.
Ask me about this plan one question at a time.
```

**Exchange edits with the kit** — send your skill edits to the kit and get what's new in the kit:

> Read `~/dev/personal/agent-kit/skills/sync/SKILL.md` and follow it.

### All skills

| Skill | What it does |
| --- | --- |
| `create-task` | files a task in the tracker |
| `create-plan` | classifies the task, writes its research, the developer plan and the agent instruction |
| `to-tickets` | cuts the plan into tickets and parts |
| `orchestrate` | walks the next part of tickets through, one commit per ticket |
| `tdd-develop` | does one ticket: test first, then code |
| `develop` | writes code without a ticket or for a no-tests ticket |
| `test-writer` | writes unit tests and E2E scenarios |
| `recon` | studies unfamiliar code before a task and returns a short summary |
| `code-review` | checks a part or a diff against the rules and the plan, sets the review level and the checks |
| `hygiene-review` | finds in changed files what the linters miss |
| `merge-request` | pushes, opens the pull request, works your review comments |
| `close-merge-request` | after the merge: links the pull request in the tracker, moves the task to Done, cleans up |
| `git-commit-message` | splits changes into commits and proposes messages |
| `grill-one` | asks about a plan one question at a time, looking for gaps and contradictions |
| `business-questions` | keeps questions to the business in the tracker; a module, off by default |

## What you get

- **One process in every project.** The skills are shared, and everything about a given project — commands, tracker,
  code rules — lives in its `docs/agents/`. A new project gets the same process after one `bootstrap`.
- **One short plan.** You read one screen before code — result, criteria, boundaries, checks — and approve it once.
- **Small steps.** A ticket is one commit, a part is one pull request. The ticket map shows what is done and what is
  left.
- **Review by risk.** The agent reviews every change and says in the pull request which consequence each check
  covers. You review only when the plan says so, and only the places it names.
- **A protected main branch.** The agent never pushes to it — each harness's permission file denies it. Its commits
  are signed by its harness (`Claude`, `OpenCode`, …), yours by you, so the history shows who changed what.
- **Edits aren't lost.** Fix a skill in one project — `sync` offers to send the edit to the kit, and the other
  projects get it.

## How it works

The skills know nothing about a project. They read every fact — paths, commands, tracker, rules — from the project's
own `docs/agents/*.md`. These files are called the contract: the kit gives templates, the project fills them in.

### What's in the repository

| Folder | What | Where it lands in a project |
| --- | --- | --- |
| `skills/` | 15 skills plus `bootstrap` and `sync` | `.agents/skills/<prefix>-*` (`.claude/skills` links to it); `bootstrap` and `sync` are not copied |
| `contract/` | templates of `docs/agents/*.md`; `<!-- fill: ... -->` marks what the project fills in | `docs/agents/` |
| `packs/` | packs — stack rules: `python`, `django` | appended to `code-rules.md`, `hygiene.md`, `testing.md` |
| `repo/` | `CONTRIBUTING.md` sections, an `AGENTS.md` snippet, `.claude/settings.json`, Codex rules, pre-commit hooks | the project root |
| `scripts/render.sh` | the kit at a given commit with the prefix filled in | used by `bootstrap` and `sync` |
| `examples/tg-sales-bot/` | the filled contract of a live project | a sample to fill from |

### The contract: docs/agents/

| File | What it holds |
| --- | --- |
| `domain.md` | `CONTEXT.md`, ADRs, glossary |
| `issue-tracker.md` | tracker, task key, tools, task language, where working files live |
| `product.md` | behaviour spec, actors, what only a manual check shows, the E2E actor |
| `stack.md` | stack, code layout, the `check` / `unit` / `e2e` / `one-test` / `migrate` commands, line counting |
| `git.md` | commit format, main branch, task and part branches, how to open a PR and work its review threads, agent identity |
| `harness.md` | roles, tiers and actions mapped per harness: subagents, models, asking the user, agent identity |
| `code-rules.md` | layers, where code goes, ticket slicing, code rules |
| `hygiene.md` | the checklist for changed files |
| `testing.md` | test stack, database, mocks, file placement, E2E harness, reference tests |

### Modules

A module is an optional part of the kit. Modules are off by default; `bootstrap` asks about each:

- `business-questions` — business question themes in the tracker and the rule «a task isn't closed until the answers
  are in». Not needed for personal projects.
- `codegraph` — the «Code search» section of `AGENTS.md`; offered only when the project has `.codegraph/`.

### A stack without a pack

Packs exist for Python and Django. For another stack (FastAPI, Go) `bootstrap` fills `code-rules.md`, `hygiene.md`
and `testing.md` from your answers and the code. Once the rules settle, ask `sync` to turn them into a pack — the
next project on that stack gets them right away.

### How sync works

- **Project → kit.** `sync` shows every edit to skills and packs since the last sync. For each you answer `в ядро`
  (send to the kit), `оставить` (keep in this project only) or `откатить` (revert). Edits answered `в ядро` become a
  commit in `agent-kit`; pushed after your yes.
- **Kit → project.** Kit changes merge three-way on top of your local edits; `sync` shows conflicts and asks.
  Changes to `contract/` and `repo/` arrive as proposals.

A project fact — a path, a command, a tracker name — never goes into the kit: it belongs in `docs/agents/`.

### Placeholders and markers

| Mark | Where | Replaced by |
| --- | --- | --- |
| `{{p}}` | skills, contract, repo | the project's skill prefix |
| `{{work}}` | skills, contract, repo | the working folder of task files, `.ai` by default |
| `{{KEY}}`, `{{key}}`, `{{main}}` | repo | the task key, its lowercase form, the main branch |
| `<KEY>`, `<key>` | skills | stays: the skill reads the key from `docs/agents/issue-tracker.md` |
| `<!-- pack:NAME -->…<!-- /pack:NAME -->` | contract | the pack's text; `sync` finds it in the project by the markers |
| `<!-- module:NAME -->…<!-- /module:NAME -->` | contract, repo | kept or cut out along with the module |

In `examples/`, an empty `<!-- pack:NAME -->` pair stands for the pack's text.
