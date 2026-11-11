# agent-kit: index for an agent

Read this file first. It tells you what the kit is, where things are, which skills belong together, and what changed
in each release. You do not need to read the skills to use it.

**Current version: v0.0.5** (git tag; `git -C <kit> describe --tags`). `<kit>` is the checkout of this repository.

## Upgrade a project: what to do

A project records its install in `.agents/agent-kit.json`: `commit` (the kit commit it is based on), `prefix` (skill
name prefix), `work` (working folder, `.ai` when absent).

1. Find the project's version: `git -C <kit> describe --tags --abbrev=0 <commit>` with `<commit>` from the record. If
   the commit is between tags, the version is the last tag before it, plus some commits.
2. Read «Releases» below, every section after that version. Each one says which skills changed, which skills must
   move as a set, and whether `contract/` or `repo/` changed (those are proposals for the project's own files, never
   merged automatically).
3. Decide per set, not per skill: a set in «Sets that move together» is taken whole or not at all.
4. To apply: run `<kit>/skills/sync/SKILL.md` from the project root. It does the three-way merge of skills and
   packs, keeps the project's local edits, and shows `contract/` and `repo/` changes as proposals. To see what a
   release changed without applying it: `git -C <kit> diff <old-tag> <new-tag> --stat -- skills contract packs repo`.

Never copy a skill by hand: the project's copy is rendered (`{{p}}` → prefix, `{{work}}` → work folder) and may carry
local edits. `sync` is the only path.

## What is where

| Path | What | Lands in a project |
| --- | --- | --- |
| `skills/<name>/` | the skills; `SKILL.md` is the entry, other `.md` files in the folder are read by it | `.agents/skills/<prefix>-<name>/` |
| `skills/bootstrap`, `skills/sync` | install and update; run from the kit by path | not copied |
| `contract/*.md` | templates of the project's facts; `<!-- fill: ... -->` is what the project writes | `docs/agents/` |
| `packs/<stack>/` | stack rules (`python`, `django`) | appended to `code-rules.md`, `hygiene.md`, `testing.md` |
| `repo/` | `CONTRIBUTING.md` sections, `AGENTS.snippet.md`, `.claude/settings.json`, `codex.rules`, `pre-commit.yaml` | project root |
| `scripts/render.sh` | renders the kit at a commit for a prefix and a work folder | used by `bootstrap`, `sync` |
| `examples/` | a filled contract of a live project | a sample |
| `README.md` | the human guide: install, usage, placeholders, markers | — |

Rule: skills hold no project facts. A path, command or tracker name lives in the project's `docs/agents/*.md`.

## Skills

The feature chain runs top to bottom. `/p-` is the project's prefix.

| Step | Skill | Does | Output |
| --- | --- | --- | --- |
| 1 | `create-task` | files a task in the tracker | tracker task |
| 2 | `create-plan` | classifies the task (workflow 1, 2 or 3), routes it, writes the plan | `plan.md`, `agent.md`, or `notes.md` |
| 2a | `research` | requirements, the existing system, risks (workflow 2 and 3, epics) | `research.md` |
| 2b | `brainstorm` | open interview about what and why; feeds `research` | requirements |
| 2c | `create-design` | architecture, contracts, diagrams, approved before the plan (workflow 3, epics) | `design.md` |
| 2d | `to-tasks` | cuts an epic's design into tracker tasks and a roadmap | `roadmap.md`, tracker tasks |
| 3 | `to-tickets` | cuts the plan into commit-sized tickets and a map of batches | `tickets/`, `00-map.md` |
| 4 | `orchestrate` | walks the next batch, one commit per ticket | commits |
| 4a | `tdd-develop` | one ticket, test first (`Mode: TDD` and `E2E`) | one commit |
| 4b | `develop` | code without a ticket, `Mode: no tests`, `Delivery: commits`, review fixes | code |
| 4c | `test-writer` | unit tests and E2E scenarios | tests |
| 4d | `recon` | maps unfamiliar code before a task | short summary |
| 5 | `code-review` | reviews a part or a diff: Standards and Spec axes | `reviews/` file |
| 5a | `hygiene-review` | finds what linters miss in changed files | findings |
| 6 | `merge-request` | pushes, opens the pull request, works the developer's review threads | pull request |
| 7 | `close-merge-request` | after the merge: links the PR, moves the task to Done, cleans up | closed task |
| — | `git-commit-message` | splits changes into commits and proposes messages | commits |
| — | `grill-one` | one-question-at-a-time interview about a plan | gaps found |
| — | `business-questions` | module, off by default: questions to the business in the tracker | tracker themes |

The routing rules (which workflow, which ticket mode) live in `repo/CONTRIBUTING.md` «Feature workflow» and in each
skill's description.

## Sets that move together

Take a set whole. A skill from a set without its partners breaks the chain: the files one writes are the files the
next one reads.

| Set | Skills | Also needs |
| --- | --- | --- |
| Workflow 3 (research and design) | `research`, `brainstorm`, `create-design`, `to-tasks`, `create-plan` | `contract/issue-tracker.md` (document copies, epic folders), `repo/CONTRIBUTING.md` |
| Ticket chain | `to-tickets`, `orchestrate`, `tdd-develop`, `develop`, `test-writer`, `code-review` | `contract/testing.md`, `contract/code-rules.md` |
| Pull request cycle | `merge-request`, `close-merge-request` | `contract/git.md` (operations table) |
| Install and update | `bootstrap`, `sync`, `scripts/render.sh` | change together: they share the install record format |
| Design-aware readers | `code-review`, `merge-request`, `close-merge-request` | read `design.md` and epics since v0.0.5; need the workflow 3 set to be useful |

## Releases

Newest first. «Skills» are files under `skills/`. «Proposals» are changes to `contract/` or `repo/` that `sync` offers
to the project's own files.

### v0.0.5 — workflow 3: research, design, plan
- **New skills:** `research`, `brainstorm`, `create-design`, `to-tasks`.
- **Rewritten:** `create-plan` (routes workflow 2 and 3 into `research` and `create-design`; takes an epic's design as
  input).
- **Small edits to read the new files:** `code-review`, `merge-request` (read `design.md`, the epic's design),
  `close-merge-request` (moves an epic with its tasks), `tdd-develop` (reads the `agent.md` items its ticket names),
  `bootstrap`.
- **Proposals:** `contract/issue-tracker.md` gets «Document copies» (project fills where task and epic copies go) and
  epic folders `{{work}}/epics/`; `repo/CONTRIBUTING.md` «Feature workflow» and «Research and design».
- **To take:** the whole workflow 3 set. A project that does not want workflow 3 may skip the four new skills and
  `create-plan`, but then keeps the old `create-plan` and loses epics.

### v0.0.4 — Codex, test and review rules
- **Skills:** `bootstrap` (takes install answers from the request, writes Codex deny rules), `code-review` (reviewers
  end with «Declined to judge»), `create-plan` (Builder check by an explorer), `test-writer/rules.md` (every scenario
  names its break; no change-detector tests; literal expected values), `tdd-develop` (runs `unit` before `e2e`).
- **Proposals:** `contract/harness.md` maps Codex instead of pi; new `repo/codex.rules`.
- **To take:** each skill stands alone. `test-writer` and `tdd-develop` are worth taking together.

### v0.0.3 — close-merge-request and a configurable work folder
- **New skill:** `close-merge-request`. `merge-request` loses its «After the merge» section and records `pr.md`.
- **Work folder:** `{{work}}` replaces the hard-coded `.ai/` in skills; `render.sh` takes `<work>`; the install
  record gets `work`.
- **Proposals:** `contract/git.md` (operation «find the merged pull request of a branch»),
  `contract/issue-tracker.md` (Done status, `{{work}}` layout, `pr.md`), `repo/` snippets.
- **To take:** `close-merge-request` + `merge-request` + the `contract/git.md` proposal together; `bootstrap`, `sync`
  and `render.sh` together.

### v0.0.2 — baseline
Harness-agnostic skills, the `docs/agents/` contract, `bootstrap` and `sync`, skills installed into `.agents/`.

## Keeping this file current

On every release (tag): bump «Current version», add a section to «Releases», update «Skills» and «Sets that move
together» when a skill or a dependency was added.
