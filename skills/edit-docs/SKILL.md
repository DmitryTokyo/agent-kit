---
name: edit-docs
description: Edit skills, rules, AGENTS.md, CLAUDE.md, CONTRIBUTING.md or docs/ — files that are not application code — with a task folder, a short plan and one commit, no research or agent instruction. Use when the user asks to fix, tweak or extend a skill, a rule or documentation.
---

# Edit docs

Repository rules: read `docs/agents/skills/edit-docs.md` first, if it exists; its rules win over this skill's text. Say which file you read, or that there is none.

A light path for changes to instructions and documentation. The plan is two to five lines; no `agent.md`, research or
recon. Application code, tests and migrations are out of scope: use `/develop`.

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

## 1. Task

Take the tracker task from the conversation. None → create it through `/create-task` and continue with its key.

Done when: the task key is known.

## 2. Branch and folder

Get onto the task branch (`docs/agents/git.md` «Branches»). Create `.ai/tasks/<key>-<N>-<short-kebab-slug>/` if it is
missing.

Done when: the branch is the task's branch and the folder exists.

## 3. Plan

Write a short `plan.md` in the folder, in the format of `/create-plan` («plan.md») with only these parts:

```markdown
# <KEY>-N: <title>

Task: <tracker link>
Version: 1

## Route

Workflow 1. Documentation change.

## Result

- <before → after, one or two sentences>

## Boundaries

- Changes: <files, `path:line`>
- Untouched: application code
```

Two to five lines in `Result` and `Boundaries` together. No `Classification`, `Criteria` or `Checks`; no `agent.md`.
English, wrapped at 120 characters. Ask the user with its text (`docs/agents/harness.md` «Actions») only when the
request leaves the files or the intent unclear; otherwise go on.

Done when: `plan.md` lists every file the change touches.

## 4. Edit

- Change each file in place with targeted edits; never rewrite a whole file.
- Touch only the files in `plan.md` `Boundaries`. A new file or a wider change → add it there and tell the user.
- Skill, rule, `AGENTS.md` or `CLAUDE.md` → follow `/writing-for-agents`; ask the user to invoke it if it is not
  loaded.
- Update `_Last modified:_` in a skill that has the line.

Done when: every change in `plan.md` is applied.

## 5. Commit

Show `git diff --stat`, then commit through `/git-commit-message`. The first push of the branch goes through
`/merge-request`.

Done when: the commit exists.

_Last modified: 2026-11-17_
