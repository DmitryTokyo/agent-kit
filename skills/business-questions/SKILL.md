---
name: ag-business-questions
description: Business questions for tg-sales-bot, kept as themes in the Linear project «Вопросы к бизнесу». Use when a question for the partner or the business comes up, when the user asks to walk a theme for unasked questions, or when the partner has answered and the answers need distributing.
---

# Business questions

A **theme** is one area of the business (Упаковка, Корзина, Доставка) and one issue in the Linear project «Вопросы к бизнесу», team AG, label `Бизнес`. A question is a numbered line inside its theme. The partner reads themes in Linear and answers there, so a theme card is written entirely for the partner.

## Theme card

Title: the theme name alone. Description, in Russian:

```markdown
## Вопросы

2. Сколько коробок максимум уходит одним Заказом?

3. Какие коробки используем?
   - [ ] только стандартные — напишите размеры в комментарии
   - [ ] подбираем под каждый Заказ
   - [ ] обсудить

## Решили

1. 2026-10-12 — Тушь упаковываем отдельно, в плёнку.
```

- A question's number is permanent. A new question takes the next unused number; an answered one moves to «Решили» under its own number.
- Every sentence is one the partner could have said: business words and `CONTEXT.md` terms. A consequence is stated as what changes for the Покупатель, the money or the launch date.
- One question asks for one decision.
- How the business works today (packing, how managers handle a Заказ, returns) is asked open, without options. A product choice gets options, each with its consequence, and `обсудить` as the last one.
- A theme that depends on another theme gets `blockedBy` on it; each card keeps only its own questions.
- Status is set by urgency:
  - `Backlog` — looks to the future, nothing depends on it, may never be picked up;
  - `Todo` — not urgent, but must be answered eventually;
  - `In Progress` — to be discussed with the partner now;
  - `Done` — discussed, the answers are read and distributed;
  - `Need Details` — only for a theme that was already discussed: development found that a given answer conflicts with what exists or missed a case. Red: work that depends on it stops, the answer is needed urgently. A question never discussed before goes to one of the first three.
- Priority is what the theme's most pressing open question does to development:
  - `Urgent` — development has stopped right now;
  - `High` — work on the task goes on, but the task cannot be finished without the answer; it becomes `Urgent` when the work hits that point;
  - `Medium` — the current task can be finished without the answer.

## Development side

What a question holds is recorded where development reads it, as the line «<Тема>, вопрос N — <what the answer changes here>» under the heading `## Ждёт от бизнеса`:

- in the description of each development task the question holds, together with `blockedBy` on the theme;
- in the description of the epic (Linear project), when no task exists yet.

## Add a question

1. List the project's issues in every status: these are the themes. Pick the theme by business meaning; the task where the question surfaced plays no part. A question that spans two themes becomes one question in each. If no theme fits, propose a new theme name to the user and create it after they agree.
2. Read the theme's description and comments. A question already asked or answered there is reported with its number, and only its development-side line is added.
3. Write the question by the card rules and show the wording to the user. Append it to «Вопросы» after they approve.
4. Record the development side for every task the question holds.
5. Set the theme's status and priority. Report the theme link, the question number and what it holds.

Done when the question is in its theme and every task it holds has its line and its relation.

## Walk a theme

1. Read the theme's card and comments, then everything the repository says about the theme: `CONTEXT.md`, `docs/bot-design.md`, `docs/adr/`, `docs/data-model/`, and the code they describe.
2. Trace the theme the way the business lives it, from the Покупатель's action to the physical outcome. Every point where code or docs assume how the business works, with no answer in «Решили» and no ADR behind it, is a candidate question. Note the neighbouring themes each candidate touches.
3. Show the candidates to the user, grouped by theme. Add the approved ones through «Add a question».

Done when every assumption about the business in the theme's docs and code is either backed by a recorded answer or shown to the user as a candidate.

## Distribute answers

1. Read the theme's description for ticked options and every comment on it.
2. For each answered question, find its development-side lines: search the team's issues and projects for «<Тема>, вопрос N».
3. Show the user a table: question, answer, where the decision goes — ADR, `CONTEXT.md`, `docs/bot-design.md`, a task, an epic. An answer that grows a task past one coherent behaviour comes with a proposal to split the task. A question the partner marked `обсудить` or answered unclearly stays in «Вопросы».
4. After the user approves, write the decisions (see `docs/agents/domain.md`). In each task and epic, fold the decision into the description and delete the «Ждёт от бизнеса» line. Move the question to «Решили» with the date and the answer in the partner's words.
5. Remove `blockedBy` from a task once it has no line left for the theme. Move the theme to `Done` when «Вопросы» is empty.

Done when each answered question sits in «Решили» and no development-side line refers to it.

_Last modified: 2026-10-11_
