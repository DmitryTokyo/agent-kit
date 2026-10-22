# Issue tracker

## Tracker

- Linear, team `Aura Group` (`AG`): `https://linear.app/zipsale/team/AG/overview`. Use this team even when a global
  skill has another default.
- Task key: `<KEY>` = `AG`. A task is `AG-N`.
- Tools: `mcp__linear__get_issue`, `mcp__linear__list_issues` (`fields: ["id", "title"]` for lists),
  `mcp__linear__save_issue`, `mcp__linear__list_projects`.

## Conventions

- An epic is a Linear project; its tasks are issues in it. Status lives only in Linear. An epic is cut into tasks when
  it is taken into work; the post-MVP plan is projects in the Backlog status.
- Title and description in Russian, the same for projects. Code identifiers, model names and statuses stay as in the
  code (`Cart`, `shipment_failed`); bot button labels and screen texts stay verbatim. Domain terms from `CONTEXT.md`
  (Покупатель, Заказ, Корзина, Канал).
- Assignee: the current user unless the user names another person.
- No feature flags in this project — task descriptions carry none.
- Blocking uses the tracker's native «blocks» relations.
- Questions to external services (YooKassa, Ozon): `docs/questions/`, one file per addressee.

## Working files

A task's working files live in `.ai/tasks/<key>-N-<slug>/`, gitignored: `research.md`, `plan.md`, `test-plan.md`,
`notes.md`, `tickets/` (a ticket is one commit, `00-map.md` is the batches and their progress), `reviews/` (the agent
review per batch with its Russian digest, `todo.md` for deferred TODOs).

## When a skill says "publish to the tracker"

Create an issue through `/ag-create-task`.

## When a skill says "load the ticket"

Read the issue by its `AG-N` key; commit-sized tickets come from `.ai/tasks/ag-N-*/tickets/`.

<!-- module:business-questions -->
## Business questions

Business questions live in the tracker: project «Вопросы к бизнесу», label `Бизнес`. One issue is one theme of the
business («Упаковка», «Корзина», «Доставка»); a question is a numbered line inside its theme.

- The partner reads the theme card and answers in it: ticks options, chooses «обсудить», writes a comment. The card's
  text is business language only.
- What a question holds in development is recorded in the development task or the epic, in the section «Ждёт от
  бизнеса»; the task gets a «blocked by» relation on the theme.
- A theme that depends on another theme gets «blocked by» on it.
- `Done` — every question in the theme is answered and the answers are distributed to ADRs, `CONTEXT.md`, the
  behaviour spec, epics and tasks.
- A question that comes up in conversation goes into its theme right away.

The card format, statuses and steps are in `/ag-business-questions`.
<!-- /module:business-questions -->
