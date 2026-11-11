# Pull request description

Every call to the host is an operation of `docs/agents/git.md` «Pull requests».

## Build

1. Collect the sources from the task folder `{{work}}/tasks/<key>-N-*/`: `plan.md`, `research.md` and `design.md` if
   present (`plan.md` names an `Epic:` → the design of `{{work}}/epics/<epic-slug>/`), and the latest review file of
   this scope (`/{{p}}-code-review` step 8). No `plan.md` → stop and ask. The review file wins over the plan for review
   level, consequences and deviations.
2. Run every check from the review file's consequences, else from `plan.md` «Checks». A failed check → stop and report
   it: no pull request opens on a red check.
3. Write the description in English. Every line says what the diff and CI cannot: why, what stays unverified, what a
   human must check, where the work departs from the plan. Passed checks, met criteria and code read back as «passed»
   stay out. Sections in order:
   - No heading: one bold sentence on what the pull request does and why; then `Task: <tracker link>` ·
     `Risk: <plan.md «Classification» level>` · `Review: <Agent, Focused or Full>` (without a review file, derive it as
     `/{{p}}-code-review` step 7 does).
   - `## Needs a human` — one bullet each: a `file:line` range or decision with the question the developer must
     answer (Focused and Full review), a check that needs the developer's access or decision phrased as the action to
     take, the part's manual check cases. None → omit the section.
   - `## Deviations` — unticked criteria and departures from the plan (commits outside the task included), each with
     why. None → omit the section.
   - `## Plan` — `plan.md`, `research.md` and `design.md` in collapsed `<details>` blocks: `{{work}}/` is not in the
     repository. An epic's design goes in with its «Summary and key decisions» section only.

## Refresh after a push

Input: the sha of `@{upstream}` noted before the push.

1. Find the open pull request of the branch (`pr.md`, else the host). None → stop.
2. Read its description against `git diff <noted sha>..HEAD` and `git log --oneline <noted sha>..HEAD`.
3. Pick the smallest edit that covers the pushed commits:
   - they change what the pull request does → «Build» again, keeping the current `## Plan` blocks;
   - they change only what a human must check or a deviation → rewrite just that section by «Build» step 3;
   - neither → leave the description and skip step 4.
4. Update its description.
5. Report whether the description changed and which section.
