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

**Start with [INDEX.md](INDEX.md).** It is the guide: which skills to take for which project, which work alone, which
go as a set, how to take them and what each release changed. Give it to the agent with what you are building, and it
picks the skills.

## Tested with

- Harnesses: Claude Code, OpenCode, Codex.
- Models: Claude, DeepSeek.

Another harness works once `docs/agents/harness.md` has a section for it: copy one and map it to the new harness.

## A starting point

The kit is a starting point, not a finished set. After the install the skills are plain files in the project's
`.agents/skills/`, and they are worth tailoring to the project: its stack, its tracker, your habits and the mistakes
the agent makes right here. Edit them in the project.

Drifting away from the kit is fine. Send to the kit only what would help any project: change the skill here and
update `INDEX.md` in the same commit.

## Install

1. Clone the kit:

   ```bash
   git clone git@github.com:DmitryTokyo/agent-kit.git ~/dev/personal/agent-kit
   ```

2. Open your agent in the project root and say what you are building:

   > Read `~/dev/personal/agent-kit/INDEX.md`. I'm building a landing page. Pick the skills and take them into this
   > project, prefix ag.

3. The agent proposes the skills. After your yes it copies them, fills only the `docs/agents/` files they read and asks
   about what the project's files don't show. A small project gets a question or two, a large one a long interview.
4. Review `git diff` and commit.

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

`create-plan` first classifies the task — product value, work type, risk — and picks a route: a known local fix,
research first, or research and design first. Then it writes one short `plan.md` for you: result, criteria, boundaries,
the checks behind each consequence, and whether you need to review the change. You approve it once; the agent comes back
only on a deviation. A small task goes straight to `develop`. A bigger one goes through `to-tickets`: one ticket is one
commit of at most 100 lines of code, tickets are grouped into parts, one part is one branch and one pull request.
`orchestrate` takes the next part and walks each ticket through: subagents write the tests and the code, review them and
commit.

**A task that needs a design first** — new behaviour, a mechanism, a contract or an interaction:

```text
Research AG-60.        ← /ag-research: an open interview about what you want, then the code; research.md
Design AG-60.          ← /ag-create-design: you pick an approach, then a hard grilling; design.md with diagrams
Write a plan for AG-60.
```

An initiative of several tasks (a new integration, a move to another framework) is an epic: one research and one
design for all of it, then `/ag-to-tasks` writes the roadmap and creates the epic and its tasks in the tracker. The
documents live in the working folder, where you read them; each approved version is also copied to the tracker.

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

**Update from the kit:**

> Read `~/dev/personal/agent-kit/INDEX.md` and update this project's skills from the kit.

### All skills

| Skill | What it does |
| --- | --- |
| `create-task` | files a task in the tracker |
| `research` | gathers requirements and studies the existing system; writes `research.md` |
| `brainstorm` | an open interview about what you want and why, before anything is designed |
| `create-design` | agrees the architecture with you: approaches, a grilling, diagrams; writes `design.md` |
| `to-tasks` | cuts an epic's design into a roadmap of tracker tasks and creates them |
| `create-plan` | classifies the task, writes the developer plan and the agent instruction |
| `to-tickets` | cuts the plan into tickets and parts |
| `orchestrate` | walks the next part of tickets through, one commit per ticket |
| `tdd-develop` | does one ticket: test first, then code |
| `develop` | writes code without a ticket or for a no-tests ticket |
| `test-writer` | writes unit tests and E2E scenarios |
| `integration-test` | writes the one integration test of a task: a real request through the whole path, the stored state asserted |
| `recon` | studies unfamiliar code before a task and returns a short summary |
| `code-review` | checks a part or a diff against the rules and the plan, sets the review level and the checks |
| `hygiene-review` | finds in changed files what the linters miss |
| `merge-request` | pushes, opens the pull request with a description of only what a human must know, works your review comments |
| `close-merge-request` | after the merge: links the pull request in the tracker, moves the task to Done, cleans up |
| `git-commit-message` | splits changes into commits and proposes messages |
| `grill-one` | asks about a plan one question at a time, looking for gaps and contradictions |
| `business-questions` | keeps questions to the business in the tracker; a module, off by default |

## What you get

- **One process in every project.** The skills are shared, and everything about a given project — commands, tracker,
  code rules — lives in its `docs/agents/`. A new project takes the skills it needs from `INDEX.md`.
- **One short plan.** You read one screen before code — result, criteria, boundaries, checks — and approve it once.
- **Small steps.** A ticket is one commit, a part is one pull request. The ticket map shows what is done and what is
  left.
- **Review by risk.** The agent reviews every change and says in the pull request which consequence each check
  covers. You review only when the plan says so, and only the places it names.
- **A protected main branch.** The agent never pushes to it — each harness's permission file denies it. Its commits
  are signed by its harness (`Claude`, `OpenCode`, …), yours by you, so the history shows who changed what.
- **Edits aren't lost.** Fix a skill in one project, carry the fix into the kit, and the other projects get it on
  their next update.

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
