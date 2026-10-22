## Feature workflow

A feature is a task in the tracker (`docs/agents/issue-tracker.md`). Its working files live in `.ai/tasks/{{key}}-N-<slug>/`.

1. `/{{p}}-create-task` — the task in the tracker.
2. `/{{p}}-create-plan` — `plan.md` and `test-plan.md`.
3. `/{{p}}-to-tickets` — tickets and their map `tickets/00-map.md`: one ticket is one commit of at most 100 lines of
   production code. A section of the map is a batch: a part's development tickets, its E2E ticket and three gates —
   agent review, developer review, manual check. A part has at most 6 development tickets and is one pull request with
   one manual check at its end; a bigger part is split in two, each named after what it delivers (`checkout-map`,
   `pickup-step`), not numbered.
4. `/{{p}}-orchestrate {{KEY}}-N` — the first batch of the map with an unticked ticket, once the batches it follows have every
   gate ticked; each ticket goes through the skill of its `Режим`. Per TDD ticket the developer approves the behaviours
   and what happens to the tests; subagents write the tests, the code and review them; each ticket is committed on its
   own and ticked in the map. The batch lives on its own git branch `{{key}}-N-<part>`; at its end the branch is pushed and a
   pull request into `{{main}}` is opened (see «Branches and pull requests»). One ticket alone: `/{{p}}-tdd-develop {{KEY}}-N <ID>` or `/{{p}}-develop` with the ticket path —
   left uncommitted for the developer's `git diff`.
5. `/{{p}}-code-review {{KEY}}-N <part>` in a new session, another model welcome — findings into
   `.ai/tasks/{{key}}-N-<slug>/reviews/` with a Russian digest beside them; the developer answers in the digest, then
   `/{{p}}-develop` with the review file works them and ticks the gate.
6. Code review by the developer on the batch's pull request — tags in the code on the batch branch, see «Code review»;
   `/{{p}}-review-comments` pulls the branch, works the tags through, commits the fixes of one round as one commit and
   pushes. The developer ticks the gate and merges the pull request.
7. The check ticket — every case clicked in the product. A failed case becomes a new ticket of the batch. The developer
   ticks the gate; the next batch is free to start.
8. Every gate of the map ticked → `/{{p}}-develop` with `reviews/todo.md` fixes the deferred TODOs in one commit, then
   the developer moves the tracker task to Done.

## Branches and pull requests

- A **part** is a logical unit of the ticket map. A batch (a map section) gets a git branch `{{key}}-N-<part>` and a pull
  request into `{{main}}`; the developer merges it.
- The agent never pushes `{{main}}`: it stops and asks the developer to do it. `.claude/settings.json` denies those
  commands. Only the batch branch is pushed.
- Whose change is whose is read from the history: the agent commits as `Claude <noreply@anthropic.com>` with a
  `Co-Authored-By: Claude` trailer, the developer as themself. Pull requests are opened under the developer's account.

## Code review

The developer reviews the pull request of a batch, checks out its branch and leaves a tag
comment next to the code it is about, in the file's
own comment syntax (`# FIX: ...`, `{# NOTE: ... #}`).

| Tag | Means | Outcome |
| --- | --- | --- |
| `FIX:` | Issue: a defect — an input or state that crashes or gives a wrong result, or a broken documented rule; must change | Fixed. An objection only when the change contradicts the behaviour spec, an ADR, `CONTEXT.md` or the code rules, or changes approved behaviour; it names the place, the developer decides |
| `NOTE:` | Question: explain the code, or decide on a departure from `docs/`, the plan or the task | Explained, with a way to make the code clearer: someone stumbled here. A change inside one function is made, a larger one only proposed |
| `TODO:` | Nitpick: a code smell — worth changing, nothing breaks | Fixed when small and behaviour stays the same; otherwise a ticket |

The agent review (`/{{p}}-code-review {{KEY}}-N <part>`) writes its findings in English under the same three tags, numbered,
into `.ai/tasks/{{key}}-N-<slug>/reviews/<BB>-<part>.md`, and a Russian digest of them into `<BB>-<part>.ru.md`. The
developer answers in the digest, under each number. Its `NOTE:` is a question to the developer. Its `TODO:` is a
suggestion: the developer answers `делать` (fixed in the round), `отложить` (goes to `reviews/todo.md`, fixed before
Done) or `пропустить`, one line can cover every TODO; without an answer it stays open.

Any change beyond a review round (about 30 lines, another screen or another task) becomes a ticket. Every tag gets a
row in the answer table; none is skipped.

The developer commits the tags with the skip of the review-tag hook (`docs/agents/git.md` «Review tags») and pushes the batch branch; the
`no-review-comments` pre-commit hook rejects `FIX:`, `NOTE:` and `TODO:` in every other commit, the agent's included.
The agent's fix round removes the tags it handled, so none reaches `{{main}}`. Tasks live in the tracker, explanations in plain
comments.
