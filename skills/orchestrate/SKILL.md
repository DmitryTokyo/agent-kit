---
name: ag-orchestrate
description: Run the next batch of a task's ticket map (.ai/tasks/ag-N-*/tickets/00-map.md) end to end, each ticket through the skill of its `Режим`. Use when the user gives a Linear key without a ticket ID and wants the tickets developed.
---

# Orchestrate

## Input

`AG-N`. Task folder: `.ai/tasks/ag-N-*/` (case-insensitive).

The **batch**: the first section of `tickets/00-map.md` (format: `.claude/skills/ag-to-tickets/SKILL.md` «Map») with an
unticked ticket line; its unticked tickets in list order.

- No `tickets/` folder or no `00-map.md` → stop, suggest `/ag-to-tickets`.
- A ticket ID given → stop and name the skill for its `Режим` from «Route».

## Role

Read `.claude/skills/ag-tdd-develop/SKILL.md` once, now: you are its dispatcher, under its «Role», for every ticket of
the batch. Its ticket sections and «Output» apply; this skill replaces its «Input» and «Close». Its stops stop the
batch.

## Start

1. `git status --porcelain` not empty → stop and tell the user: each ticket's commit takes the whole worktree.
2. A section in the batch's «После» with an unticked gate → stop and name the section and its unticked gates.
3. The batch's git branch is `ag-N-<part>` (the section's part name). On `master` → `git pull --ff-only`, then
   `git switch -c <branch>`. Already on `<branch>` → continue it. On any other branch, or `<branch>` exists and is not
   checked out → stop and tell the user.

## Route

Each ticket of the batch, by its `**Режим:**` line:

| Режим | Run |
| --- | --- |
| `TDD` | `ag-tdd-develop` «TDD ticket» |
| `E2E` | `ag-tdd-develop` «E2E ticket» |
| `без тестов` | subagent, `model: sonnet`, prompt *"Read `.claude/skills/ag-develop/SKILL.md` and follow it for `<ticket path>`. You are the subagent — do not spawn anything, you cannot talk to the user. The manual check is the user's: report how to do it and leave the checklist to the dispatcher."*; then `make check` green |
| missing | stop: the mode is set by `/ag-to-tickets` |

Then «Commit», and the next ticket.

## Commit

The user authorized these commits by starting this skill; they go without a confirmation question. They are made as
Claude (see `commit.md`), so the developer's commits and the agent's stay apart in the history and in the PR.

1. Write the message `AG-N: <type>: <description>` — the format of `/ag-git-commit-message` step 4, taken from the
   ticket title and the reports: `feat`/`fix` for a TDD ticket, `test` for an E2E ticket, `docs` for documentation.
2. Subagent, `model: haiku`, prompt *"Read `.claude/skills/ag-orchestrate/commit.md` and follow it for `<ticket path>`
   with the message `<message>`. You are the subagent — do not spawn anything, you cannot talk to the user."*
3. Its report `too-big` → stop and tell the user the production line count: the ticket is too big for one commit.

## Publish

After the batch's last ticket:

1. Current branch is `master` → stop: never push to `master`. Tell the user: «Я не пушу в master, сделай это сам».
2. `git push -u origin <branch>`. Only this branch is ever pushed.
3. Open the pull request into `master` through the GitVerse API (`https://api.gitverse.ru`, repository
   `AURA_PACIFIC/sales_tg_bot`, header `Accept: application/vnd.gitverse.object+json;version=1`, token from
   `$GITVERSE_TOKEN` — never print it): `POST /repos/AURA_PACIFIC/sales_tg_bot/pulls` with `head`, `base: master`, a
   title `AG-N: <part>` and a body of the batch's tickets, one line each, ending with
   `🤖 Generated with [Claude Code](https://claude.com/claude-code)`. The API call fails → report the pushed branch and
   ask the user to open the PR. The PR is opened under the developer's account; the agent's commits are told apart by
   their author, `Claude`.

## Review rounds

The developer pulls the branch, leaves `FIX:`/`NOTE:`/`TODO:` tags in the code per `CONTRIBUTING.md` «Code review»,
commits them with `SKIP=no-review-comments git commit` and pushes. Their «review is done» starts
`/ag-review-comments`, which pulls the branch, fixes the tags, commits as Claude and pushes the branch. Rounds repeat
until no tag is left; the developer merges the PR.

## Output

After each ticket — `ag-tdd-develop` «Output».

At the batch end: the commits in order, each with its departures, the manual checks of `без тестов` tickets, the PR
link, then the section's gates in order — the first one is `/ag-code-review AG-N <part>` in a new session.

_Last modified: 2026-10-21_
