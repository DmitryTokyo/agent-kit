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
- A finished task moves to <!-- fill: the Done status, e.g. `Done` -->.
- <!-- fill: what task descriptions never carry, e.g. «no feature flags». -->
- Blocking uses the tracker's native «blocks» relations.
- A task description has three sections: Problem, Goal, Links. Scope and acceptance criteria live in `plan.md`.
- Product Value and Work Type (`CONTRIBUTING.md` «Three axes») live in <!-- fill: label groups `Product Value` and
  `Work Type` | custom fields | the Problem section, when the tracker has neither -->.

## Working files

`{{work}}/` is gitignored: edit and move files in it freely. A task's working files live in
`{{work}}/tasks/<key>-N-<slug>/`: `research.md`, `design.md` (workflow 3, with large diagrams in `design/`), `plan.md`
(the developer plan), `agent.md` (the agent instruction), `notes.md`, `tickets/` (a ticket is one commit, `00-map.md`
is the batches and their progress), `reviews/` (the agent review rounds, per batch or for the whole task), `pr.md`
(the pull request of each branch). A finished task's folder moves to `{{work}}/done/`.

An epic's working files live in `{{work}}/epics/<epic-slug>/`: `research.md`, `design.md`, `roadmap.md` (its tasks and
their order) and `tasks/` — a symlink per started task to its folder in `{{work}}/tasks/` or `{{work}}/done/`. A task
gets its folder when its work starts, so `{{work}}/tasks/` holds only the work in progress. A finished epic moves to
`{{work}}/done/epics/`.

The local files are the working copy: skills read and edit only them.

## Document copies

The tracker keeps a copy of each approved document so it is not lost and its history is visible. The copy goes one
way, local → tracker, and is never read back.

- A task's documents: <!-- fill: where a task's copies go, e.g. «a comment on the task» | «none» -->.
- An epic's documents: <!-- fill: where an epic's copies go, e.g. «a project update (`save_status_update`)» | «a
  comment on the parent issue» | «none» -->.

When a skill says "copy the document to the tracker": post a new entry there — earlier entries stay, so the tracker
shows every version. The entry is:

```markdown
**<file name> v<Version>** — copy of `{{work}}/<path>`; edited locally, not here.
Changed: <one line: what this version changed; «first version» for v1>

<the document in full>
```

`research.md`, `design.md`, `plan.md` and `roadmap.md` are copied; `agent.md`, `notes.md`, tickets and reviews are
not. An epic not yet created in the tracker → its copies wait for `/{{p}}-to-tasks`. «none» → skip the step.

## When a skill says "publish to the tracker"

Create an issue through `/{{p}}-create-task`.

## When a skill says "load the ticket"

Read the issue by its `<KEY>-N` key; commit-sized tickets come from `{{work}}/tasks/<key>-N-*/tickets/`.

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
