---
name: {{p}}-review-comments
description: Work through the user's review tags (`FIX:`, `NOTE:`, `TODO:`) left in the code after they reviewed a batch's pull request — fix, explain, argue or ticket each one, then commit the fixes and push the batch branch. Use when the user says the review is done or asks to handle their review comments.
disable-model-invocation: true
---

# Review comments

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands».

The user reviews the batch's pull request, checks out its branch, leaves tags in the code per `CONTRIBUTING.md` «Code review», commits them and pushes.

## Input

task key (`<KEY>-N`) for the commit message. Not in the conversation → ask.

Current branch is the main branch or not the batch's `<key>-N-*` branch (`docs/agents/git.md` «Branches») → stop. `git status --porcelain` not empty → stop and tell the user: the fix commit takes the whole worktree. Then `git pull --ff-only`: the tags arrive with the developer's pushed commits.

## Role

You are the dispatcher, on Opus: the code and the tags stay unread by you, a subagent works through them. Running on another model (see «You are powered by» in the system prompt) → stop and tell the user to switch with `/model`.

## Workflow

1. Spawn the subagent: `subagent_type: general-purpose`, `model: opus`, prompt *"Read `.claude/skills/{{p}}-review-comments/fix.md` and follow it. You are the subagent — do not spawn anything, you cannot talk to the user."*
2. Show the user its table: each tag with its outcome, explanations and objections in full.
3. The user answers an explanation or an objection → pass the answer via `SendMessage` to the same subagent, show its new rows. Repeat until the user has nothing left to answer.
4. Run `check`; green → `git add -A`, commit as `docs/agents/git.md` «Agent identity» says, with `<KEY>-N: <type>: <description>` in the format of `/{{p}}-git-commit-message` step 4: one commit for the round, `refactor` unless a fix changes behaviour. Then `git push origin <the batch branch>`. No confirmation question: the user started this skill. Never push the main branch: on it stop and tell the user to do it themselves.

## Output

The commit and the push, then the tags that changed nothing, each with its outcome in one line.

_Last modified: 2026-10-15_
