---
name: {{p}}-create-plan
description: Write task documents for a tracker <KEY>-N task into {{work}}/tasks/<key>-N-<slug>/ — research.md (investigation findings), plan.md (developer plan) + agent.md (agent instruction), or notes.md (conversation notes). Use when the user asks for a plan, research write-up, notes, or a hand-off for another agent or thread.
---

# Create plan

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

A task gets two documents with two readers:

- `plan.md` — the **developer plan**: one screen the developer reads and approves before code. Classification, route,
  result, criteria, boundaries, checks, stop conditions, developer review.
- `agent.md` — the **agent instruction**: where to look, what to change and how the checks become tests. It links the
  plan and never repeats it.

## Where it lives

```text
{{work}}/tasks/<key>-<N>-<short-kebab-description>/research.md
{{work}}/tasks/<key>-<N>-<short-kebab-description>/plan.md
{{work}}/tasks/<key>-<N>-<short-kebab-description>/agent.md
{{work}}/tasks/<key>-<N>-<short-kebab-description>/notes.md
```

Lowercase task key, 3–5 word description. One folder per task; reuse it if it exists. The key comes from the
conversation; no key → run `/{{p}}-create-task`, then use the key of the task it created.

## Sources

- The tracker issue `<KEY>-N` via the tracker tools of `docs/agents/issue-tracker.md`: Problem and Goal.
- Sibling issues in the same epic (titles only, full text only for the ones that look adjacent) — to catch work that
  belongs to a neighbour.
- The behaviour spec — screens, buttons, texts. The plan matches it, never reinvents it.
- `CONTEXT.md` — domain terms; use them, not synonyms.
- `docs/adr/` — decisions constraining this area.
- The code: run `/{{p}}-recon`, then read `docs/agents/code-rules.md` for its layer rules and function-vs-class test.

Behaviour none of these settle is a product gap: ask the user, or record it under «Open questions» of `research.md`.
Never invent it.

## Pick the mode

1. **Research** — `research.md` only.
2. **Plan** — `plan.md` + `agent.md`.
3. **Notes** — `notes.md` only.

Ask the user when the mode isn't clear from the conversation.

## Classify first

Mode 2 starts with the classifier: read `CONTRIBUTING.md` «Classify a task before code», do the first look at the code
and fill the plan's classification and route from it.

- Workflow 1 → plan.
- Workflow 2 with no `research.md` in the folder → mode 1 first, then the plan.
- Research shows a new mechanism, contract or interaction → propose workflow 3 to the user, naming the finding; the
  developer confirms the route.
- Workflow 3 → stop: tell the user workflow 3 has no skill support yet.

## plan.md

The developer reads it. Written per [writing-for-humans.md](writing-for-humans.md). Fits one screen.

```markdown
# <KEY>-N: <title>

Task: <tracker link>

## Classification

<Product Value> · <Work Type> · risk <Low|Medium|High>: <reasons for the risk, one sentence>

## Route

Workflow <1|2>. <basis: the pattern or confirmed cause; for 2 — link to research.md>

## Result

- <before → after, what the actor or the system sees>

## Criteria

- [ ] <checkable acceptance criterion>

## Boundaries

- Changes: <areas, in domain words>
- Untouched: <areas, neighbouring task key if any>

## Checks

- <condition → expected result> · <test: new | extend existing | e2e | manual | none — why>

## Stop conditions

- <finding that stops the work and returns it to route selection>

## Developer review

<yes | no> — <why>; <which changes to look at>

Delivery: <commits on the branch (~N lines) | tickets (~N lines)>
```

- **Criteria** and **Boundaries** are the task's acceptance criteria and scope; the tracker task holds only Problem,
  Goal and Links. A criterion is checkable against the diff; review ticks it.
- **Checks** are the only place tests are decided: one line per consequence the change can break. A test line names
  observable behaviour, never a query count or a private helper (`.agents/skills/{{p}}-test-writer/rules.md` «Test
  observable behavior», `docs/agents/testing.md`). `e2e` — the E2E actor of `docs/agents/product.md` can play it;
  `manual` — only a manual check shows it (`docs/agents/product.md` «Checks»). Development and tickets take tests from
  here and do not ask again.
- **Research**: workflow 2 links `research.md` in `Route` and builds on its findings; each fact lives in
  `research.md` alone.
- **Delivery**: workflow 1 → commits on the branch, no tickets. Workflow 2 → `tickets` when production lines of all
  edits exceed ~100 (`docs/agents/stack.md` «Line count»), else commits.

## agent.md

English, terse, domain concepts by their names in the code.

1. **Title** — `# <KEY>-N: Agent instruction`, then `Plan: plan.md` — the approved plan wins on any conflict.
2. **Implementation shape** — where new code lives (the layer of `docs/agents/code-rules.md` «Layers»), what is
   reused as-is.
3. **Parts** — workflow 2 with tickets only: core edits, then parts independent of each other that are each checkable
   in the product on their own. One line per part: name and its edits. Omit for a single part.
4. **What to fix** — one numbered heading per edit. A line about required ordering first, if there is one.
5. **Tests** — per test line of the plan's `Checks`, by its mark. Omit when the plan has no test lines.

### How to write a fix

A heading and a few sentences:

- **where** — file, function, model; the layer per `docs/agents/code-rules.md`;
- **what's wrong or missing** — one sentence, with a number if there is one;
- **what to do** — the direction, precise enough to remove guesswork, including the edge case if one exists (no
  active photo, a second press of the same button, an empty list);
- **function or class** — only when non-obvious: the one-line verdict of the function-vs-class test of
  `code-rules.md`, not the reasoning.

```markdown
### 2. Second "Buy" press

`orders/services/cart.py`, `get_or_create_cart`: a second press creates a second `Cart`. Look up the Customer's open
`Cart` and replace its `CartItem`. Function in the domain service; the Channel adapter only calls it.
```

### How to write the tests

- **`new` / `extend existing`** — one heading per behaviour or function: the seam (a layer of `code-rules.md`
  «Layers»), the case, the expected value as a literal, and the test file: existing to extend, or the new location of
  `docs/agents/testing.md` «File placement».
- **`e2e`** — one bullet per scenario under its actor flow, grouped by part: a bold title naming the behaviour in plain
  words, then `Given` (data the reader needs to follow the steps; omit when empty), `Steps` (commands, button texts,
  message numbers where a later step refers to them), `Expected` (what the product sent and what is in the DB, as
  literals). The seam is the whole E2E harness of `docs/agents/testing.md`.
- **`manual`** — nothing here: the check line in the plan is the case.

### What stays out of agent.md

- anything the plan already says: classification, result, criteria, checks, boundaries;
- justifications, benefits, comparison of options — they live in `research.md`;
- finished code or test code — the agent writes it, looking at the named file;
- logs and measurements.

## research.md

One document for the developer and the agent. It reads top-down: the summary alone carries the decision.

```markdown
# <KEY>-N: Research

Task: <tracker link>

Question: <what the research answers, one sentence>

## Summary

- <the answer and the decision it leads to>
- Route: <workflow 2 holds | workflow 3 — the new mechanism, contract or interaction>
- Critical risks: <risk → consequence>

## Key findings

Confirmed:

- <fact> — `file:line` | <number, query, log line>

Hypotheses:

- <claim> — <what confirms or refutes it>

## Open questions

- <question> — <who answers: the developer, the business, a check>

## Evidence

- <sources read: files, queries, logs, measurements>
```

- **Confirmed** holds facts read this session in code, data or logs; everything else is a hypothesis.
- A rejected option is a confirmed finding: the option and the fact that rules it out. What the eventual fix won't
  cover goes there too.
- The document records results, in the order a reader needs them; the order of the search stays in the chat.

Bullets + `file:line`, not an essay.

## notes.md

Title `# <KEY>-N: Notes`, then freeform — whatever structure the conversation had.

## Formatting

All documents are English. UI texts and button labels stay verbatim in any document. Wrap at 120 characters — code
blocks, tables and URLs stay unbroken. The chat with the user stays in the user's language.

## Workflow

1. Resolve the task key and folder, pick the mode. Mode 2: classify per «Classify first».
2. Read the sources. What's missing — ask the user, they'll find it faster.
3. Write `research.md` / `notes.md` if the mode calls for it. Modes 1 and 3 stop here.
4. Draft `plan.md` and ask the user with its full text (`docs/agents/harness.md` «Actions»). Iterate until the
   developer approves; then write `plan.md`. The tracker task stays as it is.
5. Write `agent.md`, then check it against «What stays out of agent.md» and cut what is found.
6. **Builder check** — an explorer (`docs/agents/harness.md` «Roles») reads only `plan.md` and `agent.md` and reports
   which files it would open, what it would change, which tests it would write, and every question the two files leave
   open. A question the sources settle → fix `agent.md` and run the check again; a question only the developer can
   answer → ask the user. Done when a run reports no open question.
7. Hand over the file paths written and the next skill: `Delivery: tickets` → `/{{p}}-to-tickets`, commits →
   `/{{p}}-develop`.

A plan changed after approval: ask the user with the changed lines before editing `plan.md`.

_Last modified: 2026-11-08_
