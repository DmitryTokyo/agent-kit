---
name: {{p}}-create-design
description: Write design.md for a workflow 3 task or an epic from its research.md — architecture, behaviour, contracts, interactions, boundaries and risks, with diagrams — and get the developer's approval before any plan. Use when the user asks for a design or architecture, or when /{{p}}-research hands over a workflow 3 task.
---

# Create design

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

The design agrees **how the system should work and why this approach**: the stage between research and plan in
workflow 3 (`CONTRIBUTING.md` «Classify a task before code»). It decides; the plan that follows orders the work and
names the checks.

## Where it lives

`design.md` next to `research.md`: the task folder `{{work}}/tasks/<key>-N-*/` or the epic folder
`{{work}}/epics/<epic-slug>/`. A large diagram goes to `design/<name>.md` beside it, linked from the document. No
`research.md` → stop and hand over to `/{{p}}-research`.

## Sources

- `research.md`: its requirements, findings and open questions are the input. A fact the design needs and research
  lacks → read the code for it (`/{{p}}-recon`) and add it to `research.md` «Key findings».
- `docs/adr/` and `docs/agents/code-rules.md`: the decisions and layer rules the design keeps or explicitly changes.
- The behaviour spec of `docs/agents/product.md`: behaviour the design changes is changed there before the code.

## Steps

1. **Approaches.** From research, come up with the real ways to build it and drop the ones the existing system or
   the requirements rule out. Ask the user (`docs/agents/harness.md` «Actions») in a message of its own: the two or
   three that remain, each concrete enough to picture in this codebase, with its trade-offs, and your pick with the
   reason. One sensible way only → say so and why the others don't fit. Done when the developer picked one.
2. **Draft** `design.md` in the format below, from research and the chosen approach. Every decision a builder would
   otherwise guess is in it, or listed in «Open questions».
3. **Grill the draft.** Invoke `/{{p}}-grill-one` (`docs/agents/harness.md` «Actions») with the draft and
   `research.md` as its subject: the concrete decisions — what happens to the old behaviour, which modules are reused,
   where new code plugs in, which of two conflicting sources wins. Its agreed text updates the draft. Done when
   grill-one ends with no gaps.
4. **Diagrams.** Add the to-be diagrams the decisions need, per [diagrams.md](diagrams.md).
5. **Builder check.** An explorer (`docs/agents/harness.md` «Roles») reads only `design.md` and `research.md` and
   reports how it would plan the work, and every question the two files leave open. Sort the questions:
   - answered by the conversation or the code → put the answer in the document;
   - minor, a builder settles it without changing the result → settle it, mark it `(agent's call)`;
   - only the developer answers it, and the answer changes the result → ask the user, all of them in one message,
     most important first.
   Done when a run reports no question of the third kind.
6. **Approve.** Ask the user with the summary section in full, the list of `(agent's call)` decisions and the path.
   Iterate until the developer approves. A significant open question that blocks the plan → back to
   `/{{p}}-research` or the conversation, not into the plan.
7. Copy the document to the tracker (`docs/agents/issue-tracker.md` «Document copies»).
8. Hand over the path and the next skill: a task → `/{{p}}-create-plan`; an epic → `/{{p}}-to-tasks`.

A design changed after approval (the plan hit a stop condition, the architecture proved wrong): rewrite the affected
sections, raise `Version`, ask the user with the changed lines, then copy the new version to the tracker.

## design.md

The main point on top, technical grounds below. Sections that do not apply are dropped, the order stays.

```markdown
# <KEY>-N: Design

Task: <tracker link>
Research: research.md
Version: <N>

## Summary and key decisions

- Architecture: <the proposed shape, two or three sentences>
- <decision> — <why this one>
- Approaches: <the option picked> over <the others> — <the trade-off that decided>

## How the system works

### Components and responsibilities

- <component> — <what it owns>; <new | changed | as is>

### Interactions

<who calls whom, in what order, sync or async; a sequence diagram when there are three or more steps>

### Data and contracts

<models, fields, links, API or message shapes, the invariants they keep; an ERD when models or links change>

### States

<statuses and transitions, who triggers each; a state diagram when there are more than two states>

## Boundaries, trade-offs, risks

- Untouched: <areas the design keeps as they are>
- Trade-off: <what is given up, and why that is acceptable>
- Failure: <scenario → what the system does>
- Limit: <a load, size or time the design holds up to>
- Open questions: <question> — <who answers it, before which stage>

## Technical grounds

- <research.md finding, `file:line`, ADR or doc the decision rests on>
```

- An epic: the title is `# <epic name>: Design`, `Task:` links the epic in the tracker.
- Domain words come from `CONTEXT.md`; a code name is a label beside its meaning.
- A decision that contradicts an ADR names it and says what changes; the ADR is updated with the code.
- The design holds no ticket order and no test list: they belong to the plan.
- **Version** starts at 1 and rises with each approval after the first.

English; UI texts verbatim; wrap at 120 characters, code blocks, tables and URLs unbroken. The chat with the user
stays in the user's language.

_Last modified: 2026-11-08_
