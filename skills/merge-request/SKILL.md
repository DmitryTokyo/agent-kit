---
name: {{p}}-merge-request
description: "Push the task or part branch and open its pull request, or work through the developer's review comments on it. Use when the user asks to push, open a PR or MR, or handle their review comments. A merged pull request goes to /{{p}}-close-merge-request."
---

# Merge request

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands».

Every call to the host is an operation of `docs/agents/git.md` «Pull requests», run as that table says. A token never
reaches the command line or the chat.

## Open a pull request

1. Check all three, stop and name the failing one:
   - the current branch is a task or part branch of `docs/agents/git.md` «Branches», never the main branch;
   - `git status --porcelain` is empty;
   - `git log --oneline <main>..HEAD` lists commits.
2. A batch of the ticket map → its `Agent review` gate is ticked; unticked → stop and suggest `/{{p}}-code-review`.
3. Push only what the remote does not have yet:
   - `git rev-parse --abbrev-ref @{upstream}` fails → `git push -u origin <branch>`;
   - it resolves and `git log --oneline @{upstream}..HEAD` lists commits → `git push`;
   - it lists nothing → skip and say so.
4. Collect the sources from the task folder `{{work}}/tasks/<key>-N-*/`: `plan.md`, `research.md` and `design.md` if
   present (`plan.md` names an `Epic:` → the design of `{{work}}/epics/<epic-slug>/`), and the latest review file of
   this scope (`/{{p}}-code-review` step 7). No `plan.md` → stop and ask. The review file wins over the
   plan for review level, consequences and deviations.
5. Build the description in English, these sections in order:
   - `## Changes` — 2–5 bullets on what changed; `Task: <tracker link>`.
   - `## Risk` — the `plan.md` «Classification» line.
   - `## Review level` — Agent, Focused or Full with its reason. Focused and Full list the exact `file:line` ranges or
     decisions the developer must read. Without a review file, derive it as `/{{p}}-code-review` step 6 does.
   - `## Deviations` — unticked criteria and departures from the plan, each with why. None → `none`.
   - `## Consequences` — one line per significant consequence: `<consequence> → <check> → <result>`. Take them from
     the review file, else from `plan.md` «Checks». Run every check you can; a check that needs the developer's access
     or decision gets `not run: <what blocks it>`.
   - `## Criteria` — every `plan.md` «Criteria» item with its result: `met`, or `not met: <why>`.
   - `## Manual check` — the part's check ticket cases, when there is one.
   - `## Plan` — `plan.md`, `research.md` and `design.md` in collapsed `<details>` blocks: `{{work}}/` is not in the
     repository. An epic's design goes in with its «Summary and key decisions» section only.
6. Find the open pull request of the branch. One exists → update its description. None → open it into the main branch
   with the title of `git.md` «Pull requests».
7. Record it in the task folder's `pr.md`, one line per branch; this branch's line is replaced, the others stay.
   `/{{p}}-close-merge-request` finds the pull request by it:

   ```markdown
   - <branch>: <link> (<id>)
   ```

8. Report the pull request link, and the gates of the map section still open on it.

## Work through review comments

1. List the unresolved review threads of the branch's pull request. None → say so and stop.
2. Ask the user (`docs/agents/harness.md` «Actions») which to work, one numbered line per thread: `<file>:<line>` (or
   `general`), the first comment. The user picks numbers.
3. Per chosen thread, read the code around it and the commit that brought it (`git blame`):
   - a defect or a rule breach → fix it per `docs/agents/code-rules.md`, update the tests it touches, run them;
   - a question → answer in plain words; a clearer version inside one function is made, a larger one only proposed;
   - a change that alters approved behaviour, a test's expected value or the plan's Boundaries → an objection: the
     argument and the place it rests on (the behaviour spec, an ADR, `CONTEXT.md`, the plan); the developer decides;
   - beyond a review round (about 30 lines, another screen or another task) → a new ticket per
     `.agents/skills/{{p}}-to-tickets/SKILL.md` «Ticket rules», or a tracker task when it lies outside this task.
4. Run `check`; green → commit the fixes of the round as one commit under the agent identity (`docs/agents/git.md`),
   with a message in the format of `/{{p}}-git-commit-message` step 4. The user started this skill: no confirmation
   question. Then `git push`.
5. Reply in each worked thread: `Fixed in <short sha>`, the answer, the objection, or the new ticket. The developer
   resolves threads.

_Last modified: 2026-11-08_
