# agent-kit: guide

A set of agent skills that take a task from an idea to a merged pull request. Take only the skills a project needs:
one skill for a small script, the whole chain for a large product.

**Current version: v0.0.6** (git tag; `git -C <kit> describe --tags`). `<kit>` is the checkout of this repository.

## Pick by project

| Project | Install and use |
| --- | --- |
| A small script or tool | `grill-one`, `git-commit-message` |
| A landing page, a small app | `brainstorm`, `grill-one`, `recon`, `test-writer`, `git-commit-message` |
| A product with a tracker | the above + `create-task`, `create-plan`, the ticket chain, the pull request cycle |
| A large or hard system (a compiler, a platform) | everything, with workflow 3 for research and design |

## Good alone

Each works without the other skills. A mention of another skill inside it is a hint: skip it when that skill is not
installed.

| Skill | Does | Reads in `docs/agents/` |
| --- | --- | --- |
| `grill-one` | asks one question at a time to find gaps in a plan or an idea | nothing |
| `brainstorm` | open interview: what you want and why, before any design | `product` (optional) |
| `recon` | maps unfamiliar code in a subagent, returns a short summary | `harness`, `stack`, `product` |
| `hygiene-review` | finds what linters miss in changed files | `harness`, `hygiene` |
| `test-writer` | writes unit tests and E2E scenarios | `harness`, `stack`, `testing`, `product` |
| `integration-test` | writes one integration test: a real request through the whole path, the stored state asserted | `harness`, `stack`, `testing` |
| `git-commit-message` | splits changes into commits, proposes messages, commits on your yes, pushes a branch already pushed | `harness`, `git`, `issue-tracker` |
| `create-task` | files a task in the tracker | `harness`, `issue-tracker`, `product` |
| `review-diff` | reviews a diff on two axes: the project's rules and the task's plan | most of them |

## Sets that work together

One skill writes files the next one reads: take a set whole.

| Set | Skills | Flow |
| --- | --- | --- |
| Ticket chain | `create-plan`, `to-tickets`, `orchestrate`, `tdd-develop`, `develop`, `test-writer`, `integration-test`, `review-diff` | plan → tickets → one commit per ticket, test first → the task's integration test → review |
| Workflow 3: research and design | `research`, `brainstorm`, `create-design`, `to-tasks`, `create-plan` | requirements → design approved by you → epic cut into tasks → plan |
| Pull request cycle | `merge-request`, `close-merge-request` | push and open the PR, answer review threads → after the merge, close the task |
| Business questions | `business-questions`, `create-task` | questions to the business kept as themes in the tracker |

The full chain, top to bottom: `create-task` → `create-plan` (→ `research` → `create-design` → `to-tasks` for large
tasks) → `to-tickets` → `orchestrate` → `review-diff` → `merge-request` → `close-merge-request`.

## Install skills (once per machine)

Skills are shared: one copy in the kit, linked into the harnesses. An edit in the kit is seen by every repository at
once. A skill has no prefix and reads project facts only from the project's own `docs/agents/`.

1. For each skill you use, link it into both harnesses (`<kit>` is the checkout of this repository):

   ```bash
   for s in <name> <name>; do
     ln -s <kit>/skills/$s ~/.claude/skills/$s    # Claude Code
     ln -s <kit>/skills/$s ~/.agents/skills/$s    # Codex
   done
   ```

2. The description of every installed skill takes room in the context of every repository: install what you use.
3. Subagent definitions, if a project wants any, go to the project's `.agents/agents/` (`contract/harness.md`
   «Agent definitions»); the kit's skills need none.

## Set up a project

1. For each file the project's skills read (the tables above), copy `contract/<file>.md` to `docs/agents/<file>.md`
   and fill its `<!-- fill: ... -->` places from the project. `harness.md` is read by almost every skill: start
   with it.
2. A repository nuance of a skill goes to `docs/agents/skills/<skill>.md`, not into a copy of the skill. The skill
   reads this file as its first step, names it (or says there is none), and its rules win over the skill's text.
3. The chain of steps is the project's `CONTRIBUTING.md` «Feature workflow» (`repo/CONTRIBUTING.md`). Nobody reads it
   whole at the start: `to-tickets` copies the gates into the task's ticket map, later steps hand over along the
   map, and without a map a skill reads one line after its own step. A step is a call by exact name, `/<skill>`.
   A skill that is not found stops the work and is reported; it is never skipped or retold. A step the project does
   not want is cut from «Feature workflow» or switched off in the skill's rules file.
4. A project step that works differently from the shared one is a skill of the repository,
   `.agents/skills/<own-name>/` (`.claude/skills` links to it), with a name unlike any shared skill, and a line in
   «Feature workflow».
5. Write down the kit commit the contract was filled from: `.agents/agent-kit.json`, `{"commit": "<kit commit>"}`.

`packs/` holds stack rules (`python`, `django`) to append to `code-rules.md`, `hygiene.md`, `testing.md`. `repo/`
holds optional project wiring: `CONTRIBUTING.md` sections, `AGENTS.md` snippet, harness permissions, pre-commit hooks.

## Update

- Skills: `git -C <kit> pull`. Projects need nothing.
- A project's contract: read «Releases» below after the project's `commit`, then
  `git -C <kit> diff <commit> HEAD -- contract/ repo/`. Carry what applies into `docs/agents/`, keep the project's
  edits, set `commit` to the kit's `HEAD`.

A repository edit good for every project goes back to the kit: change `skills/<name>/` here and update this file.

## Releases

Newest first.

### v0.0.6 — the guide replaces the installer, integration tests, a shorter PR description
- **Removed:** `bootstrap`, `sync`, `scripts/render.sh`. Skills are taken and updated by hand or by an agent reading
  this file («Take skills into a project», «Update a project»).
- **Epic task folders:** `to-tasks` no longer creates a folder for every task of an epic; `create-plan` creates it and
  its epic link when the task starts, so `{{work}}/tasks/` shows only the work in progress. `close-merge-request`
  finishes an epic only when every task of `roadmap.md` is in `done/`. `contract/issue-tracker.md` «Working files»
  says the same.
- **New skill:** `integration-test` — one integration test per task from `integration.md`, which `create-plan` now
  writes when a change alters what a request leaves in the stored state; `develop` and `tdd-develop` «Last ticket» run
  it. `contract/testing.md` gets «Integration tests».
- **Pull request description:** `merge-request/description.md` — only what the diff and CI cannot say (a bold summary,
  «Needs a human», «Deviations»), no PR on a red check, and «Refresh after a push». `git-commit-message` pushes a task
  branch that is already pushed and refreshes the description.
- **Review:** `review-diff` reviews inline by default, asks how to review a diff over ~800 lines, runs the hygiene scan
  and a new test reviewer (`test-review.md`: red probe, refactoring probe) in the background.
- **Tests:** `test-writer/rules.md` filters scenarios before code («Dropped scenarios» in the report), one happy path
  per function, a case must go red without its change; the main agent confirms inferred behaviours first.
  `create-plan` «Checks» names the change that turns a test red, `test: none — default` otherwise.
- **Smaller edits:** `create-plan` (every data fact has a source read this session; a fact of another repository
  becomes questions for its agent), `research` (another repository's agent answers questions), `develop` (code-rules
  scan of the changed lines; the repository's rules win over a ticket), `hygiene-review` (checks the changed lines
  against a diff base), `tdd-develop` and `orchestrate` («Last ticket»: the whole branch against `Criteria`),
  `create-task` (asks priority, `Medium` recommended), `to-tickets` (common slicing seams), `contract/harness.md`
  («Agent definitions», `.agents/agents/`).
- **To take:** for the folder fix, `to-tasks`, `create-plan` and `close-merge-request` together; `integration-test`
  with `create-plan`, `develop` and `tdd-develop`; `merge-request` with `git-commit-message`. The installer
  removal needs nothing; a project installed by `bootstrap` keeps working, its `.agents/agent-kit.json` gives the
  commit to update from.

### v0.0.5 — workflow 3: research, design, plan
- **New skills:** `research`, `brainstorm`, `create-design`, `to-tasks`.
- **Rewritten:** `create-plan` (routes workflow 2 and 3 into `research` and `create-design`; takes an epic's design as
  input).
- **Small edits to read the new files:** `review-diff`, `merge-request` (read `design.md`, the epic's design),
  `close-merge-request` (moves an epic with its tasks), `tdd-develop` (reads the `agent.md` items its ticket names),
  `bootstrap`.
- **Contract:** `issue-tracker.md` gets «Document copies» and epic folders `{{work}}/epics/`; `repo/CONTRIBUTING.md`
  gets «Feature workflow» and «Research and design».
- **To take:** the whole workflow 3 set, or skip it and keep the old `create-plan` (no epics).

### v0.0.4 — Codex, test and review rules
- **Skills:** `bootstrap` (takes install answers from the request, writes Codex deny rules), `review-diff` (reviewers
  end with «Declined to judge»), `create-plan` (Builder check by an explorer), `test-writer/rules.md` (every scenario
  names its break; no change-detector tests; literal expected values), `tdd-develop` (runs `unit` before `e2e`).
- **Contract:** `harness.md` maps Codex instead of pi; new `repo/codex.rules`.
- **To take:** each skill alone; `test-writer` and `tdd-develop` are better together.

### v0.0.3 — close-merge-request and a configurable work folder
- **New skill:** `close-merge-request`. `merge-request` loses its «After the merge» section and records `pr.md`.
- **Work folder:** `{{work}}` replaces the hard-coded `.ai/` in skills.
- **Contract:** `git.md` (operation «find the merged pull request of a branch»), `issue-tracker.md` (Done status,
  `{{work}}` layout, `pr.md`).
- **To take:** `close-merge-request` + `merge-request` + the `git.md` change together.

### v0.0.2 — baseline
Harness-agnostic skills, the `docs/agents/` contract, `bootstrap` and `sync`, skills installed into `.agents/`.

## Keeping this file current

Every commit that adds, removes or changes a skill updates this file in the same commit: the tables when a skill or a
dependency changed, «Releases» when it is tagged.
