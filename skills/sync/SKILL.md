---
name: sync
description: Sync a project installed by bootstrap with the agent-kit core both ways — local edits of skills and packs go back to the kit on the user's choice, kit changes since the install come into the project, a project's stack rules can become a new pack. Run from the project's root by path.
---

# Sync

The user runs this from the root of an installed project: «Read `<kit>/skills/sync/SKILL.md` and follow it». Every
path below without `<kit>/` is in the project. The install record is `.agents/agent-kit.json`; `<base>` is its
`commit`, `<prefix>` its `prefix`, `<work>` its `work` (`.ai` when the record has none: an install made before the
working folder was asked).

## 1. Preconditions

Stop and tell the user when any of these fails:

- `.agents/agent-kit.json` exists. Only `.claude/agent-kit.json` → an install made before the `.agents/` layout:
  migrate first (below). Neither → suggest `<kit>/skills/bootstrap`.
- `git status --porcelain` is empty in the project and in `<kit>`.
- `git -C <kit> fetch`; `main` behind `origin/main` → ask whether to `git -C <kit> pull --ff-only` first.
- `<base>` exists in the kit history.

### Migrate to `.agents/`

Show the moves as a plain message and end the turn; after the user's yes:

1. `git mv .claude/skills/<prefix>-* .agents/skills/`, then `.claude/skills` becomes a symlink to `../.agents/skills`
   (other skills in it move along).
2. `git mv .claude/agent-kit.json .agents/agent-kit.json`; add `"harnesses": ["claude-code"]` plus any harness the
   user names.
3. `CLAUDE.md`: the sections of the kit's old `CLAUDE.snippet.md` move to `AGENTS.md`, and `CLAUDE.md` opens with
   `@AGENTS.md`.
4. `docs/agents/harness.md` from `<kit>/contract/harness.md`, filled for the harnesses of the record.

The migration is part of this sync's diff; continue with step 2.

## 2. Render

Into empty scratch directories: `<kit>/scripts/render.sh <base> <prefix> <work> <base-dir>` and
`<kit>/scripts/render.sh HEAD <prefix> <work> <head-dir>`.

What is compared:

- **skill files** — `.agents/skills/<prefix>-*/**` against `<dir>/skills/`, only the skills the record installed (a
  module off → its skill is not there);
- **pack sections** — in `docs/agents/{code-rules,hygiene,testing}.md`, the text between `<!-- pack:NAME -->` and
  `<!-- /pack:NAME -->` of each pack in the record, against `<dir>/packs/<NAME>/<file>` without its marker lines;
- **harness sections** — in `docs/agents/harness.md`, the text between `<!-- harness:NAME -->` markers, against the
  same block of `<kit>/contract/harness.md` at `<base>`; a section the kit lacks is a local edit too. Filled
  `<!-- fill -->` values are project facts and never go to the kit.

## 3. Local edits → kit

1. For each compared item: `diff -u <base-dir item> <project item>`. Every difference is a local edit.
2. Show the user a numbered list in Russian: the file, what changed in plain words, the hunk. Each edit gets one
   answer:
   - `в ядро` — the edit is good for every project;
   - `оставить` — it stays in this project only;
   - `откатить` — the project gets the base version back.
   Print the list as a plain message and end the turn.
3. `в ядро`: take the patch from the base item to the project item, turn `<prefix>-<skill name>` back into
   `{{p}}-<skill name>` and `<work>/` into `{{work}}/`, apply it to the kit file with `git -C <kit> apply`. A project fact in the patch (a path, a
   command, a tracker name) → stop and ask: it belongs in `docs/agents/`, not the kit. Then one kit commit for all of
   them, under the agent identity:

   ```bash
   git -C <kit> <agent identity of docs/agents/harness.md> commit -m "<type>: <description>"
   ```

   Push only after the user's yes, and never with `--force`.
4. `откатить`: copy the base item into the project.
5. `оставить`: nothing now; step 4 merges kit changes around it.

Re-render `<head-dir>` when the kit got a commit.

## 4. Kit changes → project

1. Per compared item, three-way: `git merge-file <project item> <base item> <head item>`. Exit code 0 → merged; above
   0 → conflicts: show each with both sides in plain words and ask which one wins, or a mix.
2. A skill or skill file new in `<head-dir>` → copied in; gone from `<head-dir>` → ask before deleting. A new skill of
   a module that is off → skipped.
3. A new pack in `<kit>/packs/` → named in the report, not installed.
4. `contract/` and `repo/`: `git -C <kit> diff <base> HEAD -- contract repo`. Each change is a proposal for the
   project's `docs/agents/`, `AGENTS.md`, `CONTRIBUTING.md`, a harness permission file or `.pre-commit-config.yaml`:
   show it, apply after the user's yes, with the record's values for `{{p}}`, `{{KEY}}`, `{{key}}`, `{{main}}`, `{{work}}`.
5. Set `commit` in `.agents/agent-kit.json` to the kit `HEAD`; add `"work": "<work>"` when the record has none.

## 5. New pack (on request)

When the user asks to make a pack from this project's rules (a stack the kit has no pack for):

1. Ask for the pack name and which sections of `docs/agents/{code-rules,hygiene,testing}.md` belong to the stack, not
   to the project. Show the user the split and wait for approval.
2. Write them to `<kit>/packs/<name>/<file>` wrapped in `<!-- pack:<name> -->` markers, without project facts.
3. In the project, wrap the same sections in the markers and add `<name>` to `packs` in the record.
4. Kit commit and push as in step 3.

## 6. Verify

The checks of `<kit>/skills/bootstrap/SKILL.md` step 6, and `diff -r` of `<head-dir>/skills` against
`.agents/skills/<prefix>-*` shows only the edits answered `оставить`.

Nothing is committed in the project: the user reviews `git diff` and commits.

## 7. Report

In Russian: the base and the new kit commit, the edits sent to the kit with the kit commit and whether it was pushed,
the edits kept local, the kit changes merged, conflicts and how each was settled, proposals applied and declined, new
packs available.

_Last modified: 2026-11-06_
