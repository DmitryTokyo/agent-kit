# Issue tracker

## Tracker

- <!-- fill: tracker, team or project, URL. -->
- Task key: `<KEY>` = <!-- fill: e.g. AG -->. A task is `<KEY>-N`.
- <!-- fill: the tools to read, list and save issues, e.g. `mcp__linear__get_issue`, `list_issues`, `save_issue`. -->

## Conventions

- An epic is <!-- fill: a Linear project | a milestone | a parent issue -->; its tasks are issues in it. Status lives
  only in the tracker.
- Title and description in <!-- fill: language -->. Code identifiers, statuses and UI texts stay as in the code.
- Assignee: the current user unless the user names another person.
- <!-- fill: what task descriptions never carry, e.g. «no feature flags». -->
- Blocking uses the tracker's native «blocks» relations.

## Working files

A task's working files live in `.ai/tasks/<key>-N-<slug>/`, gitignored: `research.md`, `plan.md`, `test-plan.md`,
`notes.md`, `tickets/` (a ticket is one commit, `00-map.md` is the batches and their progress), `reviews/` (the agent
review per batch with its Russian digest, `todo.md` for deferred TODOs).

## When a skill says "publish to the tracker"

Create an issue through `/{{p}}-create-task`.

## When a skill says "load the ticket"

Read the issue by its `<KEY>-N` key; commit-sized tickets come from `.ai/tasks/<key>-N-*/tickets/`.

<!-- module:business-questions -->
## Business questions

Business questions live in the tracker: <!-- fill: project and label, e.g. project «Вопросы к бизнесу», label
`Бизнес` -->. One issue is one theme of the business; a question is a numbered line inside its theme.

- The partner reads the theme card and answers in it: ticks options, chooses «обсудить», writes a comment. The card's
  text is business language only.
- What a question holds in development is recorded in the development task or the epic, in the section «Ждёт от
  бизнеса»; the task gets a «blocked by» relation on the theme.
- A theme that depends on another theme gets «blocked by» on it.
- `Done` — every question in the theme is answered and the answers are distributed to ADRs, `CONTEXT.md`, the
  behaviour spec, epics and tasks.
- A question that comes up in conversation goes into its theme right away.

The card format, statuses and steps are in `/{{p}}-business-questions`.
<!-- /module:business-questions -->
