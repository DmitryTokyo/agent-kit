# agent-kit: guide

A set of agent skills that take a task from an idea to a merged pull request. Take only the skills a project needs:
one skill for a small script, the whole chain for a large product.

**Current version: v0.0.5** (git tag; `git -C <kit> describe --tags`). `<kit>` is the checkout of this repository.

## Pick by project

| Project | Take |
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
| `git-commit-message` | splits changes into commits, proposes messages, commits on your yes | `harness`, `git`, `issue-tracker` |
| `create-task` | files a task in the tracker | `harness`, `issue-tracker`, `product` |
| `code-review` | reviews a diff on two axes: the project's rules and the task's plan | most of them |

## Sets that work together

One skill writes files the next one reads: take a set whole.

| Set | Skills | Flow |
| --- | --- | --- |
| Ticket chain | `create-plan`, `to-tickets`, `orchestrate`, `tdd-develop`, `develop`, `test-writer`, `code-review` | plan → tickets → one commit per ticket, test first → review |
| Workflow 3: research and design | `research`, `brainstorm`, `create-design`, `to-tasks`, `create-plan` | requirements → design approved by you → epic cut into tasks → plan |
| Pull request cycle | `merge-request`, `close-merge-request` | push and open the PR, answer review threads → after the merge, close the task |
| Business questions | `business-questions`, `create-task` | questions to the business kept as themes in the tracker |

The full chain, top to bottom: `create-task` → `create-plan` (→ `research` → `create-design` → `to-tasks` for large
tasks) → `to-tickets` → `orchestrate` → `code-review` → `merge-request` → `close-merge-request`.

## Take skills into a project

1. Copy `skills/<name>/` to `.agents/skills/<prefix>-<name>/` in the project. `<prefix>` is a short name for the
   project's skills, e.g. `zip`. Claude Code reads `.claude/skills/`: make it a symlink to `../.agents/skills`.
2. In the copied files replace `{{p}}` with the prefix and `{{work}}` with the folder for task files (`.ai`, add it to
   `.gitignore`):

   ```bash
   find .agents/skills/<prefix>-* -name '*.md' -exec perl -pi -e 's/\{\{p\}\}/<prefix>/g; s/\{\{work\}\}/.ai/g' {} +
   ```

3. For each file the skill reads (the tables above), copy `contract/<file>.md` to `docs/agents/<file>.md` and fill
   its `<!-- fill: ... -->` places from the project. `harness.md` is read by almost every skill: start with it.
4. Write down what you took in `.agents/agent-kit.json`: `{"commit": "<kit commit>", "prefix": "<prefix>",
   "work": ".ai", "skills": ["<name>", "..."]}`.

`packs/` holds stack rules (`python`, `django`) to append to `code-rules.md`, `hygiene.md`, `testing.md`. `repo/`
holds optional project wiring: `CONTRIBUTING.md` sections, `AGENTS.md` snippet, harness permissions, pre-commit hooks.

## Update a project

1. Take `commit` from `.agents/agent-kit.json` and read «Releases» below after that version.
2. For each skill the project has: `git -C <kit> diff <commit> HEAD -- skills/<name>`. Apply the change to the
   project's copy, keep its local edits, replace `{{p}}` and `{{work}}` as when taking it.
3. Set `commit` to the kit's `HEAD`.

A local edit good for every project goes back to the kit: change `skills/<name>/` here and update this file.

## Releases

Newest first.

### Unreleased — the guide replaces the installer
- **Removed:** `bootstrap`, `sync`, `scripts/render.sh`. Skills are taken and updated by hand or by an agent reading
  this file («Take skills into a project», «Update a project»).
- **Epic task folders:** `to-tasks` no longer creates a folder for every task of an epic; `create-plan` creates it and
  its epic link when the task starts, so `{{work}}/tasks/` shows only the work in progress. `close-merge-request`
  finishes an epic only when every task of `roadmap.md` is in `done/`. `contract/issue-tracker.md` «Working files»
  says the same.
- **To take:** for the folder fix, `to-tasks`, `create-plan` and `close-merge-request` together. The installer
  removal needs nothing; a project installed by `bootstrap` keeps working, its `.agents/agent-kit.json` gives the
  commit to update from.

### v0.0.5 — workflow 3: research, design, plan
- **New skills:** `research`, `brainstorm`, `create-design`, `to-tasks`.
- **Rewritten:** `create-plan` (routes workflow 2 and 3 into `research` and `create-design`; takes an epic's design as
  input).
- **Small edits to read the new files:** `code-review`, `merge-request` (read `design.md`, the epic's design),
  `close-merge-request` (moves an epic with its tasks), `tdd-develop` (reads the `agent.md` items its ticket names),
  `bootstrap`.
- **Contract:** `issue-tracker.md` gets «Document copies» and epic folders `{{work}}/epics/`; `repo/CONTRIBUTING.md`
  gets «Feature workflow» and «Research and design».
- **To take:** the whole workflow 3 set, or skip it and keep the old `create-plan` (no epics).

### v0.0.4 — Codex, test and review rules
- **Skills:** `bootstrap` (takes install answers from the request, writes Codex deny rules), `code-review` (reviewers
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
