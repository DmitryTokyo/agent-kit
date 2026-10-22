---
name: ag-create-plan
description: Write task documents for a Linear AG-N task into .ai/tasks/ag-N-<slug>/ — research.md (investigation findings), plan.md + test-plan.md (implementation blueprint), or notes.md (conversation notes). Use when the user asks for a plan, research write-up, notes, or a hand-off for another agent or thread.
---

# Create plan

A plan is an **implementation blueprint**. Another agent opens it in a clean thread and needs to know where to look and what to change. Every extra line bloats its context and invites mistakes.

## Where it lives

```text
.ai/tasks/ag-<N>-<short-kebab-description>/research.md
.ai/tasks/ag-<N>-<short-kebab-description>/plan.md
.ai/tasks/ag-<N>-<short-kebab-description>/test-plan.md
.ai/tasks/ag-<N>-<short-kebab-description>/notes.md
```

Lowercase Linear key, 3–5 word description. One folder per task; reuse it if it exists. `.ai/` is gitignored — these are working files; the task itself lives in Linear.

## Sources

- The Linear issue `AG-N` via `mcp__linear__get_issue`: goal and acceptance criteria. No key in the conversation → ask.
- Sibling issues in the same Linear project (`mcp__linear__list_issues`, `fields: ["id", "title"]`, full text only for the ones that look adjacent) — to catch work that belongs to a neighbour.
- `docs/bot-design.md` — screens, buttons, texts. The plan matches it, never reinvents it.
- `CONTEXT.md` — domain terms; use them, not synonyms.
- `docs/adr/` — decisions constraining this area.
- The code: run `/ag-recon`, then load `/ag-develop` for its layer rules and function-vs-class test.

Behaviour none of these settle is a product gap: ask the user, or record it under «Open questions». Never invent it.

## Pick the mode

1. **Investigation now, implementation later** — `research.md` only.
2. **Investigation done, direction agreed** — `research.md`, then `plan.md` + `test-plan.md`. Root cause never goes in `plan.md`.
3. **Direct implementation or bugfix** — `plan.md` + `test-plan.md` only.
4. **Conversation notes** — `notes.md` only.

Ask the user when the mode isn't clear from the conversation.

## Agreement

Modes 2 and 3. Before `plan.md`, the user agrees on what will be built; the plan then details only that. The user reads
this, not the plan: write it in Russian, in `CONTEXT.md` terms, with no file paths, function names or layers.

Print it as a plain message and end the turn; `AskUserQuestion` hides both the text before it and its option `preview`
in the desktop app. The user's reply approves it or corrects it:

- **Что изменится** — 2–5 lines: what the Buyer or the seller sees now → after.
- **Решения** — every choice the Linear issue, `docs/bot-design.md` and the ADRs leave open and you settled, one line
  each: `<решение>; альтернатива: <отвергнутый вариант>`. Only what the Buyer or the seller would notice, or what is
  costly to reverse; layer, function-vs-class and naming choices stay in `plan.md`. None → «Решений нет».
- **Не делаем** — one line per item, with the neighbouring Linear key where there is one.
- **Критерии** — acceptance criteria added to or changed in the issue, as `screen → action → expected result`.

Done when the user approves it in this session. Then update the Linear issue description: «Решения» into a
`## Decisions` section after `## Scope`, «Не делаем» into `## Scope`, «Критерии» into `## Acceptance criteria`, a
changed goal into `## Goal`; every other line stays as it is.

A decision that surfaces while writing `plan.md` goes back to the user and into `## Decisions` before the plan uses it.
A decision changed after approval: edit `## Decisions` and add a comment to the issue — было → стало, причина.

## research.md

- Title: `# AG-N: Research`
- Findings, with the evidence behind each one.
- Root cause.
- Options considered, including why rejected ones were rejected — the only place that reasoning belongs.
- What the eventual fix won't cover, if anything.

Bullets + `file:line`, not an essay.

## notes.md

Title `# AG-N: Notes`, then freeform — whatever structure the conversation had.

## plan.md

Sections in this order:

1. **Title** — `# AG-N: <title>` and the Linear link.
2. **Order** — one line on required ordering of edits. Omit when any order works.
3. **Problem / goal** — what the Buyer or the seller sees now and should see after. Numbers only where the agent relies on them.
4. **Boundaries** — files and layers touched, and not touched. Work that belongs to a neighbouring Linear issue is named here with its key and left out of «Edits».
5. **Implementation shape** — where new code lives (domain service vs `bot/` adapter, per ADR-0007), what is reused as-is.
6. **Parts** — core edits, then parts independent of each other that are each checkable in the bot on their own. One line per part: name and its edits. Omit for a single part.
7. **Edits** — one heading per edit, see below.
8. **Later** — out of scope, one line per item.
9. **Manual checks** — in Russian, copied verbatim into the check ticket the user runs. One case per line: screen → action → expected result. Start from the Linear acceptance criteria, add the edge cases the plan introduces. A case the Buyer can play through the dispatcher is an E2E scenario and lives in `test-plan.md`; «Manual checks» keeps what only real Telegram or the Django admin shows — what the chat renders, the real age of a message, a real payment. With parts — grouped by part.

### How to write an edit

A heading and a few sentences:

- **where** — file, function, model; the layer per `/ag-develop`;
- **what's wrong or missing** — one sentence;
- **what to do** — the direction, precise enough to remove guesswork, including the edge case if one exists (a Product with no active photo, a second `Купить` press, an empty catalog);
- **function or class** — only when non-obvious: apply `/ag-develop`'s test and write the one-line verdict, not the reasoning.

```markdown
### 2. Second «Купить» press

`orders/services/cart.py`, `get_or_create_cart`: a second press creates a second `Cart`. Look up the Customer's open
`Cart` and replace its `CartItem`. Function in the domain service; `bot/` only calls it.
```

### What stays out of plan.md

Even when it was discussed:

- tests of any kind — cases, files, commands, any mention of `test-plan.md`;
- justifications, benefits, "what we'll get";
- option comparisons — «Later» gets one line with the verdict;
- finished code — the agent writes it, looking at the named file;
- logs and measurements beyond the numbers in «Problem / goal».

## test-plan.md

Sibling file, own document, written for whoever runs `/ag-test-writer` or `/ag-tdd-develop`, not for the implementer.

1. **Title** — same key.
2. **Unit tests** — one heading per behaviour/function: where, which case, expected value as a literal. Seam per case: model, domain service, or handler (handler tests check only the service call and the reply). A ticket is developed against these.
3. **E2E scenarios** — one heading per Buyer flow; under it one bullet per scenario: a bold title naming the behaviour it checks in plain words, readable without the plan, then three sub-bullets — `Given` (data and whatever the reader must know to follow the steps; omit when empty), `Steps` (command, button texts, with message numbers where a later step refers to them), `Expected` (what the bot sent — text, buttons, the same message edited or a new one — and what is in the DB, as literals; plain words first, the Telegram method name in brackets). The seam is the whole dispatcher. With parts — grouped by part: a part's scenarios become its E2E ticket. Nothing for the Buyer to do in the bot → the line «No E2E scenarios».
4. **Files** — existing test files to extend, or new locations: `{app}/tests/unit/test_{module}.py`, `bot/tests/e2e/test_{flow}.py`.
5. **Edge cases** — bullets.

Only behaviours worth a dedicated test: what the Buyer, the seller or the calling code can observe, per «Test observable behavior» in `.claude/skills/ag-test-writer/rules.md`. An implementation property (query count, prefetch) belongs to the edit in `plan.md`. Same exclusions as plan.md: no justification, no finished test code.

## Formatting

`plan.md` and `test-plan.md` are for agents: English, terse, domain concepts by their names in the code (`Cart`,
`Customer`, `Product`). Bot texts, button labels and «Manual checks» stay Russian, verbatim. The Agreement screen,
the Linear issue, `research.md` and `notes.md` are for the user: Russian, `CONTEXT.md` terms. Wrap at 120 characters — code blocks, tables and URLs stay unbroken.

## Workflow

1. Resolve the Linear key, the folder, the mode.
2. Read the sources. What's missing — ask the user, they'll find it faster.
3. Write `research.md` / `notes.md` if the mode calls for it. Modes 1 and 4 stop here.
4. Agree per «Agreement» and update the Linear issue.
5. Write `plan.md`.
6. Write `test-plan.md` as a separate pass — leave `plan.md`'s implementation framing behind.
7. Proofread each against its exclusions and cut what you find.
8. Audit `plan.md` for any test mention and `test-plan.md` for any plan reference; remove the cross-contamination.
9. Check: can an agent from a clean thread, reading only `plan.md`, tell which files to open and what to change? Same check for `test-plan.md` against `/ag-test-writer`.
10. Hand over the paths written, the Linear issue link, the list of edit headings, and the open questions.

Edit an existing document only after an explicit "yes" from the user.

_Last modified: 2026-10-18_
