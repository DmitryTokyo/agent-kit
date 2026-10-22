---
name: bootstrap
description: Install the agent-kit core into a project — skills under the project's prefix, the docs/agents contract filled for the project, stack packs, optional modules and the repo wiring. Run from the project's root by path, never installed into the project.
---

# Bootstrap

The user runs this from the root of the target project: «Read `<kit>/skills/bootstrap/SKILL.md` and follow it». `<kit>`
is the kit clone two levels above this file. Every path below without `<kit>/` is in the project.

## 1. Preconditions

Stop and tell the user when any of these fails:

- The project is a git repository and `git status --porcelain` is empty: the install is reviewed as one diff.
- `.claude/agent-kit.json` does not exist. It exists → the project is installed already: suggest `<kit>/skills/sync`.
- `git -C <kit> status --porcelain` is empty and `git -C <kit> fetch` shows `main` not behind `origin/main`. Behind →
  ask the user whether to `git -C <kit> pull --ff-only` first.

## 2. Read the project

Before asking anything, read what is there: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `CONTEXT.md`,
`docs/adr/`, `docs/agents/`, `.claude/settings.json`, `.claude/skills/`, `.pre-commit-config.yaml`, `.gitignore`, the
build and dependency files (`Makefile`, `pyproject.toml`, `package.json`, …), the source root, the test directories,
`.codegraph/`, `git remote -v`, the default branch.

From them, draft an answer to every question of step 3. A question the files answer gets the drafted answer to
confirm; never invent one the files don't support.

## 3. Ask

One plain message with every question, numbered, each with the drafted answer or «нет данных», then end the turn;
`AskUserQuestion` hides the text before it in the desktop app. The user answers by number.

1. Skill prefix: lowercase letters and digits. No default: the user chooses it.
2. Task key in the tracker, e.g. `AG`. No default: the user chooses it.
3. Tracker: name, team or project, URL, the tools to read, list and save issues; what an epic is.
4. Language of task titles and descriptions.
5. Main branch; where pull requests are opened and how (CLI or API, repository, token env var).
6. Stack and the packs: list `<kit>/packs/`. A stack without a pack → its rules come from the user and the code, and
   say so: `sync` can turn them into a pack later.
7. Commands: `check`, `unit`, `e2e`, `one-test`, `migrate` — each a command or «none».
8. Behaviour spec, actors, what only a manual check shows, the E2E actor and harness.
9. Optional modules, each «нет» unless the user says yes:
   - `business-questions` — the skill, its section in `issue-tracker.md` and the gate in `CLAUDE.md`; then the
     project and label in the tracker;
   - `codegraph` — the «Code search» section of `CLAUDE.md`; offered only with `.codegraph/` present.

A changed answer → ask again only what it touches. Done when every question has the user's answer.

## 4. Show the install

A plain message, then end the turn: the files to create, the files to change and what goes into each, one line per
file. A skill directory under the same name in `.claude/skills/` → name it as a conflict and ask: replace or keep.
Done when the user approves.

## 5. Install

1. Render: `<kit>/scripts/render.sh <kit HEAD> <prefix> <tmp>` into an empty scratch directory.
2. Skills: copy `<tmp>/skills/<prefix>-*` into `.claude/skills/`. `business-questions` off → skip
   `<prefix>-business-questions`.
3. Contract: for each file of `<kit>/contract/`, write `docs/agents/<file>`:
   - replace `{{p}}` with the prefix;
   - replace every `<!-- fill: ... -->` with the answer or what the files show; one left unfilled stays as it is and
     goes into the report;
   - `<!-- module:NAME -->…<!-- /module:NAME -->`: module on → drop the two marker lines, keep the text; off → drop
     the block;
   - `code-rules.md`, `hygiene.md`, `testing.md`: append each chosen pack's file from `<tmp>/packs/<pack>/`, markers
     included, in the order of the answer;
   - an existing `docs/agents/<file>` → merge: its facts stay, the template's sections are added around them.
4. Repo wiring from `<kit>/repo/`, with `{{p}}`, `{{KEY}}`, `{{key}}`, `{{main}}` replaced and modules handled as in 3:
   - `CONTRIBUTING.md` — its sections appended; a section of the same heading already there → show both and ask;
   - `CLAUDE.snippet.md` — appended to `CLAUDE.md` (created when missing);
   - `settings.json` — merged into `.claude/settings.json`: `permissions.allow` and `permissions.deny` as unions;
   - `pre-commit.yaml` — its hooks added to the `repo: local` entry of `.pre-commit-config.yaml`, created when missing;
     `pre-commit install --hook-type commit-msg` is the user's to run, put it in the report.
5. `.gitignore` gets `.ai/` when missing.
6. Write `.claude/agent-kit.json`:

   ```json
   {
     "kit": "<absolute kit path>",
     "remote": "<git -C kit remote get-url origin>",
     "commit": "<kit HEAD>",
     "prefix": "<prefix>",
     "key": "<KEY>",
     "main": "<main branch>",
     "packs": ["<pack>", "..."],
     "modules": ["<module>", "..."]
   }
   ```

## 6. Verify

- `grep -rn '{{' .claude/skills docs/agents CLAUDE.md CONTRIBUTING.md .pre-commit-config.yaml` — empty.
- Every `/<prefix>-…` and `.claude/skills/<prefix>-…` reference in the installed skills resolves to an installed
  skill; a reference to `business-questions` with the module off is a stop.
- `.claude/settings.json` and `.claude/agent-kit.json` parse as JSON; `pre-commit validate-config` passes when
  pre-commit is installed.

Done when every check passes. Nothing is committed: the user reviews `git diff` and commits.

## 7. Report

In Russian: the skills installed, the files created and changed, every `<!-- fill -->` left with its file and what it
waits for, the commands for the user (`pre-commit install --hook-type commit-msg`), and the next step — commit the
install, then `/<prefix>-create-task` for the first task.

_Last modified: 2026-10-22_
