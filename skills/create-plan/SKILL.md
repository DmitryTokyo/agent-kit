---
name: {{p}}-create-plan
description: Write task documents for a tracker <KEY>-N task into .ai/tasks/<key>-N-<slug>/ — research.md (investigation findings), plan.md + test-plan.md (implementation blueprint), or notes.md (conversation notes). Use when the user asks for a plan, research write-up, notes, or a hand-off for another agent or thread.
---

# Create plan

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

A plan is an **implementation blueprint**. Another agent opens it in a clean thread and needs to know where to look and what to change. Every extra line bloats its context and invites mistakes.

## Where it lives

```text
.ai/tasks/<key>-<N>-<short-kebab-description>/research.md
.ai/tasks/<key>-<N>-<short-kebab-description>/plan.md
.ai/tasks/<key>-<N>-<short-kebab-description>/test-plan.md
.ai/tasks/<key>-<N>-<short-kebab-description>/notes.md
```

Lowercase task key, 3–5 word description. One folder per task; reuse it if it exists. `.ai/` is gitignored — these are working files; the task itself lives in the tracker.

## Sources

- The tracker issue `<KEY>-N` via the tracker tools of `docs/agents/issue-tracker.md`: goal and acceptance criteria. No key in the conversation → ask.
- Sibling issues in the same epic (titles only, full text only for the ones that look adjacent) — to catch work that belongs to a neighbour.
- the behaviour spec — screens, buttons, texts. The plan matches it, never reinvents it.
- `CONTEXT.md` — domain terms; use them, not synonyms.
- `docs/adr/` — decisions constraining this area.
- The code: run `/{{p}}-recon`, then read `docs/agents/code-rules.md` for its layer rules and function-vs-class test.

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

- **Что изменится** — 2–5 lines: what an actor sees now → after.
- **Решения** — every choice the tracker issue, the behaviour spec and the ADRs leave open and you settled, one line
  each: `<решение>; альтернатива: <отвергнутый вариант>`. Only what an actor would notice, or what is
  costly to reverse; layer, function-vs-class and naming choices stay in `plan.md`. None → «Решений нет».
- **Не делаем** — one line per item, with the neighbouring task key where there is one.
- **Критерии** — acceptance criteria added to or changed in the issue, as `screen → action → expected result`.

Done when the user approves it in this session. Then update the tracker issue description: «Решения» into a
`## Decisions` section after `## Scope`, «Не делаем» into `## Scope`, «Критерии» into `## Acceptance criteria`, a
changed goal into `## Goal`; every other line stays as it is.

A decision that surfaces while writing `plan.md` goes back to the user and into `## Decisions` before the plan uses it.
A decision changed after approval: edit `## Decisions` and add a comment to the issue — было → стало, причина.

## research.md

- Title: `# <KEY>-N: Research`
- Findings, with the evidence behind each one.
- Root cause.
- Options considered, including why rejected ones were rejected — the only place that reasoning belongs.
- What the eventual fix won't cover, if anything.

Bullets + `file:line`, not an essay.

## notes.md

Title `# <KEY>-N: Notes`, then freeform — whatever structure the conversation had.

## plan.md

Sections in this order:

1. **Title** — `# <KEY>-N: <title>` and the tracker link.
2. **Order** — one line on required ordering of edits. Omit when any order works.
3. **Problem / goal** — what an actor sees now and should see after. Numbers only where the agent relies on them.
4. **Boundaries** — files and layers touched, and not touched. Work that belongs to a neighbouring tracker issue is named here with its key and left out of «Edits».
5. **Implementation shape** — where new code lives (the layer of `docs/agents/code-rules.md` «Layers»), what is reused as-is.
6. **Parts** — core edits, then parts independent of each other that are each checkable in the product on their own. One line per part: name and its edits. Omit for a single part.
7. **Edits** — one heading per edit, see below.
8. **Later** — out of scope, one line per item.
9. **Manual checks** — in Russian, copied verbatim into the check ticket the user runs. One case per line: screen → action → expected result. Start from the tracker issue's acceptance criteria, add the edge cases the plan introduces. A case the E2E actor can play is an E2E scenario and lives in `test-plan.md`; «Manual checks» keeps what only a manual check shows (`docs/agents/product.md` «Checks»). With parts — grouped by part.

### How to write an edit

A heading and a few sentences:

- **where** — file, function, model; the layer per `docs/agents/code-rules.md`;
- **what's wrong or missing** — one sentence;
- **what to do** — the direction, precise enough to remove guesswork, including the edge case if one exists (an item with no active photo, a second press of the same button, an empty list);
- **function or class** — only when non-obvious: apply the function-vs-class test of `code-rules.md` and write the one-line verdict, not the reasoning.

```markdown
### 2. Second «Купить» press

`orders/services/cart.py`, `get_or_create_cart`: a second press creates a second `Cart`. Look up the Customer's open
`Cart` and replace its `CartItem`. Function in the domain service; the Channel adapter only calls it.
```

### What stays out of plan.md

Even when it was discussed:

- tests of any kind — cases, files, commands, any mention of `test-plan.md`;
- justifications, benefits, "what we'll get";
- option comparisons — «Later» gets one line with the verdict;
- finished code — the agent writes it, looking at the named file;
- logs and measurements beyond the numbers in «Problem / goal».

## test-plan.md

Sibling file, own document, written for whoever runs `/{{p}}-test-writer` or `/{{p}}-tdd-develop`, not for the implementer.

1. **Title** — same key.
2. **Unit tests** — one heading per behaviour/function: where, which case, expected value as a literal. Seam per case: a layer of `docs/agents/code-rules.md` «Layers». A ticket is developed against these.
3. **E2E scenarios** — one heading per actor flow; under it one bullet per scenario: a bold title naming the behaviour it checks in plain words, readable without the plan, then three sub-bullets — `Given` (data and whatever the reader must know to follow the steps; omit when empty), `Steps` (command, button texts, with message numbers where a later step refers to them), `Expected` (what the product sent — text, buttons, the same message edited or a new one — and what is in the DB, as literals; plain words first, the API method name in brackets). The seam is the whole E2E harness of `docs/agents/testing.md`. With parts — grouped by part: a part's scenarios become its E2E ticket. Nothing for an actor to do in the product → the line «No E2E scenarios».
4. **Files** — existing test files to extend, or new locations per `docs/agents/testing.md` «File placement».
5. **Edge cases** — bullets.

Only behaviours worth a dedicated test: what an actor or the calling code can observe, per «Test observable behavior» in `.claude/skills/{{p}}-test-writer/rules.md` and `docs/agents/testing.md`. An implementation property (query count, prefetch) belongs to the edit in `plan.md`. Same exclusions as plan.md: no justification, no finished test code.

## Formatting

`plan.md` and `test-plan.md` are for agents: English, terse, domain concepts by their names in the code. UI texts, button labels and «Manual checks» stay Russian, verbatim. The Agreement screen,
the tracker issue, `research.md` and `notes.md` are for the user: Russian, `CONTEXT.md` terms. Wrap at 120 characters — code blocks, tables and URLs stay unbroken.

## Workflow

1. Resolve the task key, the folder, the mode.
2. Read the sources. What's missing — ask the user, they'll find it faster.
3. Write `research.md` / `notes.md` if the mode calls for it. Modes 1 and 4 stop here.
4. Agree per «Agreement» and update the tracker issue.
5. Write `plan.md`.
6. Write `test-plan.md` as a separate pass — leave `plan.md`'s implementation framing behind.
7. Proofread each against its exclusions and cut what you find.
8. Audit `plan.md` for any test mention and `test-plan.md` for any plan reference; remove the cross-contamination.
9. Check: can an agent from a clean thread, reading only `plan.md`, tell which files to open and what to change? Same check for `test-plan.md` against `/{{p}}-test-writer`.
10. Hand over the paths written, the tracker issue link, the list of edit headings, and the open questions.

Edit an existing document only after an explicit "yes" from the user.

_Last modified: 2026-10-18_
