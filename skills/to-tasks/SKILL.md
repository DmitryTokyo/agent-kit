---
name: {{p}}-to-tasks
description: Split an epic's approved design ({{work}}/epics/<slug>/design.md) into a roadmap.md of tracker tasks with their order, then create the epic and its tasks in the tracker.
disable-model-invocation: true
---

# To tasks

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

An epic's plan is its **roadmap**: which tracker tasks deliver the approved design, in what order, and what is checked
across them. Each task then gets its own `plan.md` through `/{{p}}-create-plan`, with the epic's design as its input.
The roadmap slices the design and adds no new decisions.

## 1. Gather context

The epic folder `{{work}}/epics/<epic-slug>/`: `design.md` (approved), `research.md`. Ask for the epic if the folder
is unclear.

- No approved `design.md` → stop and point to `/{{p}}-create-design`.
- The design lives in a task folder `{{work}}/tasks/<key>-N-*/` and turned out to span several tasks → ask the user
  whether to promote it to an epic. Yes → create `{{work}}/epics/<epic-slug>/`, move `research.md` and `design.md`
  into it, and ask whether `<KEY>-N` becomes the epic's first task or is closed in favour of the new ones.

## 2. Draft the roadmap

- One task per piece an actor or the system notices on its own once merged, named after what it delivers
  (`offer-api`, `price-sync`), sized as `/{{p}}-create-task` «Task shape» says. A piece that works only together with
  another is the same task.
- Each task names the design sections it implements; every component, contract and state of `design.md` «How the
  system works» lands in exactly one task.
- **Blocked by** — only tasks that genuinely gate it. Independent tasks keep the design's order.
- **Epic checks** — scenarios that cross tasks: what is checked, and after which task it can first run. A check inside
  one task belongs to that task's plan, not here.
- **Stop conditions** — findings that send the epic back to `/{{p}}-create-design`.
- **Checkpoints** — points where the developer takes part between tasks (look at data after a migration, try a flow
  on staging).

A design that cannot be sliced without a new decision (a component no task can own, a dependency loop) → stop and
show the finding to the user.

## 3. Approve

Ask the user (`docs/agents/harness.md` «Actions») with the full text of `roadmap.md`. Iterate until the developer
approves.

## 4. Write roadmap.md

```markdown
# <epic name>: Roadmap

Epic: <tracker link>
Design: design.md
Version: <N>

## Tasks

| # | Task | Delivers | Blocked by | Design |
| --- | --- | --- | --- | --- |
| 1 | <KEY>-N <slug> | <what an actor or the system gets, one line> | — | <design.md sections> |

## Epic checks

- <scenario across tasks → expected result> · after <task #>

## Stop conditions

- <finding → back to design>

## Checkpoints

- <after task # → what the developer does>
```

`Version` starts at 1 and rises with each approval after the first.

## 5. Tracker and folders

1. The epic: find it in the tracker (an epic is what `docs/agents/issue-tracker.md` «Conventions» says); none →
   create it with the epic's Problem / Goal / Links and the design summary in 3–5 lines.
2. Each task through `/{{p}}-create-task`, inside the epic, Product Value and Work Type confirmed once for all of them;
   «blocks» relations from the `Blocked by` column. Write each key into the table.
3. No task folders: `{{work}}/tasks/` holds only the work in progress, and the roadmap table is the queue. A task's
   folder and its link into the epic appear when `/{{p}}-create-plan` starts it.
4. Copy `research.md`, `design.md` and `roadmap.md` to the tracker (`docs/agents/issue-tracker.md` «Document
   copies»): copies that waited for the epic go now.

## 6. Report

The epic link, each task with its key, link and blockers, and the next step:
`/{{p}}-create-plan <KEY>-N` for the first task with no blocker.

A roadmap changed after approval: ask the user with the changed lines, raise `Version`, update the tracker, copy the
new version.

_Last modified: 2026-11-11_
