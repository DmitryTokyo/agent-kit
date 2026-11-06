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
- Neither `.agents/agent-kit.json` nor `.claude/agent-kit.json` (an install made before the `.agents/` layout) exists.
  One exists → the project is installed already: suggest `<kit>/skills/sync`.
- `git -C <kit> status --porcelain` is empty and `git -C <kit> fetch` shows `main` not behind `origin/main`. Behind →
  ask the user whether to `git -C <kit> pull --ff-only` first.

## 2. Read the project

Before asking anything, read what is there: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `CONTEXT.md`,
`docs/adr/`, `docs/agents/`, `.agents/`, `.claude/`, `.opencode/`, `.codex/`, `.pre-commit-config.yaml`, `.gitignore`,
the build and dependency files (`Makefile`, `pyproject.toml`, `package.json`, …), the source root, the test directories,
`.codegraph/`, `git remote -v`, the default branch.

From them, draft an answer to every question of step 3. A question the files answer gets the drafted answer to
confirm; never invent one the files don't support.

## 3. Ask

One plain message with every question, numbered, each with the drafted answer or «нет данных», then end the turn.
The user answers by number.

1. Skill prefix: lowercase letters and digits. No default: the user chooses it.
2. Task key in the tracker, e.g. `AG`. No default: the user chooses it.
3. Harnesses the project runs in: the sections of `<kit>/contract/harness.md` (`claude-code`, `opencode`, `codex`), and
   the values it leaves to fill — tiers, agent identity. A harness without a section → it gets one from the user's
   answers, and say so: `sync` can send it to the kit.
4. Tracker: name, team or project, URL, the tools to read, list and save issues; what an epic is; the status a
   finished task moves to (`Done`).
5. Working folder: where task files live, relative to the root, default `.ai`. It gets `tasks/` (the open tasks) and
   `done/` (the merged ones) and is gitignored.
6. Language of task titles and descriptions.
7. Main branch; the host and how each operation of `<kit>/contract/git.md` «Pull requests» runs (`gh`, or an API
   wrapper that keeps the token inside its process), repository.
8. Stack and the packs: list `<kit>/packs/`. A stack without a pack → its rules come from the user and the code, and
   say so: `sync` can turn them into a pack later.
9. Commands: `check`, `unit`, `e2e`, `one-test`, `migrate` — each a command or «none».
10. Behaviour spec, actors, what only a manual check shows, the E2E actor and harness.
11. Optional modules, each «нет» unless the user says yes:
    - `business-questions` — the skill, its section in `issue-tracker.md` and the gate in `AGENTS.md`; then the
      project and label in the tracker;
    - `codegraph` — the «Code search» section of `AGENTS.md`; offered only with `.codegraph/` present.

A changed answer → ask again only what it touches. Done when every question has the user's answer.

## 4. Show the install

A plain message, then end the turn: the files to create, the files to change and what goes into each, one line per
file. A skill directory under the same name in `.agents/skills/` → name it as a conflict and ask: replace or keep.
Done when the user approves.

## 5. Install

1. Render: `<kit>/scripts/render.sh <kit HEAD> <prefix> <work> <tmp>` into an empty scratch directory.
2. Skills: copy `<tmp>/skills/<prefix>-*` into `.agents/skills/`. `business-questions` off → skip
   `<prefix>-business-questions`. `claude-code` chosen → `.claude/skills` is a symlink to `../.agents/skills`; a real
   `.claude/skills/` directory → move its skills into `.agents/skills/` first, a name clash is a step 4 conflict.
3. Contract: for each file of `<kit>/contract/`, write `docs/agents/<file>`:
   - replace `{{p}}` with the prefix, `{{work}}` with the working folder;
   - replace every `<!-- fill: ... -->` with the answer or what the files show; one left unfilled stays as it is and
     goes into the report;
   - `<!-- module:NAME -->…<!-- /module:NAME -->`: module on → drop the two marker lines, keep the text; off → drop
     the block;
   - `harness.md`: `<!-- harness:NAME -->…<!-- /harness:NAME -->` blocks as modules, on for the chosen harnesses, but
     the marker lines stay: `sync` finds the sections by them;
   - `code-rules.md`, `hygiene.md`, `testing.md`: append each chosen pack's file from `<tmp>/packs/<pack>/`, markers
     included, in the order of the answer;
   - an existing `docs/agents/<file>` → merge: its facts stay, the template's sections are added around them.
4. Repo wiring from `<kit>/repo/`, with `{{p}}`, `{{KEY}}`, `{{key}}`, `{{main}}`, `{{work}}` replaced and modules
   handled as in 3:
   - `CONTRIBUTING.md` — its sections appended; a section of the same heading already there → show both and ask;
   - `AGENTS.snippet.md` — appended to `AGENTS.md` (created when missing);
   - `claude-code` chosen → `CLAUDE.md` opens with the line `@AGENTS.md` (created when missing); its rules that
     every harness needs move to `AGENTS.md`, Claude Code specifics stay;
   - `claude-code` chosen → `settings.json` merged into `.claude/settings.json`: `permissions.allow` and
     `permissions.deny` as unions;
   - `codex` chosen → `codex.rules` appended to `.codex/rules/default.rules` (created when missing), rules already
     there stay. Codex loads it only for a trusted project: put that in the report;
   - another harness's permission file gets the same denies when the user names its format;
   - `pre-commit.yaml` — its hooks added to the `repo: local` entry of `.pre-commit-config.yaml`, created when missing;
     `pre-commit install --hook-type commit-msg` is the user's to run, put it in the report.
5. `.gitignore` gets `<work>/` when missing.
6. Write `.agents/agent-kit.json`:

   ```json
   {
     "kit": "<absolute kit path>",
     "remote": "<git -C kit remote get-url origin>",
     "commit": "<kit HEAD>",
     "prefix": "<prefix>",
     "key": "<KEY>",
     "main": "<main branch>",
     "work": "<working folder>",
     "harnesses": ["<harness>", "..."],
     "packs": ["<pack>", "..."],
     "modules": ["<module>", "..."]
   }
   ```

## 6. Verify

- `grep -rn '{{' .agents/skills docs/agents AGENTS.md CONTRIBUTING.md .pre-commit-config.yaml .codex/rules` — empty.
- Every `/<prefix>-…` and `.agents/skills/<prefix>-…` reference in the installed skills resolves to an installed
  skill; a reference to `business-questions` with the module off is a stop.
- `docs/agents/harness.md` has a section for every chosen harness. `claude-code` chosen → `.claude/skills` resolves
  to `.agents/skills` and `CLAUDE.md` contains `@AGENTS.md`.
- `.agents/agent-kit.json` and every harness permission file written parse; `pre-commit validate-config` passes when
  pre-commit is installed; `codex execpolicy check --rules .codex/rules/default.rules -- git push origin <main>`
  reports `forbidden` when Codex is installed.

Done when every check passes. Nothing is committed: the user reviews `git diff` and commits.

## 7. Report

In Russian: the skills installed, the files created and changed, every `<!-- fill -->` left with its file and what it
waits for, the commands for the user (`pre-commit install --hook-type commit-msg`), and the next step — commit the
install, then `/<prefix>-create-task` for the first task.

_Last modified: 2026-11-06_
