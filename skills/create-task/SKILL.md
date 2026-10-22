---
name: {{p}}-create-task
description: Create tasks in the project's tracker (docs/agents/issue-tracker.md). Use when the user asks to create, add, file, or register a task, issue, bug, or work item, or to cut an epic into tasks.
---

# Create tracker tasks

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

The tracker of `docs/agents/issue-tracker.md` is the single source of truth for tasks: goal, acceptance criteria, status. Plans and commit-sized tickets come later, locally, via `/{{p}}-create-plan` and `/{{p}}-to-tickets`.

## Defaults

- Team, tools, epic, language and what descriptions never carry: `docs/agents/issue-tracker.md` «Tracker» and
  «Conventions», even when a global skill has another default.
- Normal/default issue type.
- Domain terms from `CONTEXT.md`; actors from `docs/agents/product.md` «Actors».

## Collect missing fields

Infer what the user already supplied. Ask only for what's missing, in one message, before creating anything:

- status: «Какой статус задачи?» — free-form answer, no choices offered;
- priority: «Какой приоритет?» — preserve the user's value, never invent one;
- project (epic), when the task clearly belongs to one and the user hasn't named it.

## Task shape

```markdown
## Goal
What an actor can do after this task, 1–2 sentences.

## Scope
- bullets; what's out of scope, if it's easy to confuse with a neighbouring task

## Acceptance criteria
- [ ] <screen → action → expected result>   ← manual checks
- [ ] <non-UI criterion>

## References
- the behaviour spec, section <N>
- ADR-000X
```

A task is sized to one coherent behaviour an actor notices — several commits, one manual check pass. Bigger → propose splitting it into several tasks before creating anything.

## Create

1. Resolve team, project, status, assignee. Any value ambiguous or missing → ask; never silently switch.
2. Search the team for an existing matching task (titles only) to avoid duplicates on retries.
3. Create the issue.
4. Only with the business-questions module (`docs/agents/issue-tracker.md` «Business questions»): list the issues of
   its project that are not `Done`: these are themes of business questions. For each open question the new task cannot
   be finished without, record it on the task as `/{{p}}-business-questions` describes under «Development side».

## Business questions

Only with the business-questions module: a question to the partner or the business is a line in a theme of its
project, not a development task: use `/{{p}}-business-questions`.

## Report

Each task identifier with its clickable link, plus team, project, status, priority, assignee. With the
business-questions module, for a new development task, also the business questions that block it.

_Last modified: 2026-10-22_
