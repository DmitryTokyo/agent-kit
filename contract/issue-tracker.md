# Issue tracker: Linear

Epics and tasks live in Linear, team **AG**: `https://linear.app/zipsale/team/AG/overview`.

## Conventions

- An epic is a Linear project, a task is an issue in the project. Status lives only in Linear.
- A task is written in Russian: goal, scope, acceptance criteria with manual checks, references. It is created with the `/ag-create-task` skill.
- An epic is cut into tasks when it is taken into work. The post-MVP plan is projects in the Backlog status.
- A task's working files: `.ai/tasks/ag-N-<slug>/` — `plan.md`, `test-plan.md`, `tickets/NN-*.md` (a ticket is one commit), `tickets/00-map.md` (batches and their progress), `reviews/` (agent review per batch with its Russian digest, `todo.md` for deferred TODOs). They are not committed.
- Blocking uses Linear's native «blocks» relations.
- Questions to external services (YooKassa, Ozon): `docs/questions/`, one file per addressee.

## Business questions

Business questions live in Linear: project «Вопросы к бизнесу», label `Бизнес`. One issue is one theme of the business («Упаковка», «Корзина», «Доставка»); a question is a numbered line inside its theme.

- The partner reads the theme card and answers in it: ticks options, chooses «обсудить», writes a comment. The card's text is business language only.
- What a question holds in development is recorded in the development task or the epic, in the section «Ждёт от бизнеса»; the task gets a «blocked by» relation on the theme.
- A theme that depends on another theme gets «blocked by» on it.
- `Done` — every question in the theme is answered and the answers are distributed to ADRs, `CONTEXT.md`, `docs/bot-design.md`, epics and tasks.
- A question that comes up in conversation goes into its theme right away.

The card format, statuses and steps are in the `/ag-business-questions` skill: add a question, walk a theme, distribute answers.

## When a skill says "publish to the tracker"

Create an issue in Linear through `/ag-create-task`.

## When a skill says "load the ticket"

Read the issue from Linear by its `AG-N` key; commit-sized tickets come from `.ai/tasks/ag-N-*/tickets/`.
