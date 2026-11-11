---
name: {{p}}-create-task
description: Create tasks in the project's tracker (docs/agents/issue-tracker.md). Use when the user asks to create, add, file, or register a task, issue, bug, or work item, or to cut an epic into tasks.
---

# Create tracker tasks

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

The tracker of `docs/agents/issue-tracker.md` holds the task's problem, goal, links, status and labels. Scope and acceptance criteria come later, in the developer plan of `/{{p}}-create-plan`; commit-sized tickets in `/{{p}}-to-tickets`.

## Defaults

- Team, tools, epic, language and what descriptions never carry: `docs/agents/issue-tracker.md` «Tracker» and
  «Conventions», even when a global skill has another default.
- Normal/default issue type.
- Domain terms from `CONTEXT.md`; actors from `docs/agents/product.md` «Actors».

## Collect missing fields

Infer what the user already supplied. Ask the user (`docs/agents/harness.md` «Actions») only for what's missing, in
one message, before creating anything:

- status — a short choice of the tracker's starting statuses (e.g. `Backlog`, `Todo`, `In Progress`), any other status
  accepted;
- priority — preserve the user's value; none given → ask, `Medium` as the recommended pick, `High` and `Urgent` as the
  other choices, any other priority accepted;
- project (epic), when the task clearly belongs to one and the user hasn't named it;
- Product Value and Work Type (`CONTRIBUTING.md` «Three axes») — classify the task yourself and ask to confirm, your
  pick first. Where they live in the tracker: `docs/agents/issue-tracker.md` «Conventions».

## Task shape

```markdown
## Problem
What is wrong or missing now, in the user's words, not improved.
Open: <one line per point the conversation has not settled>

## Goal
What an actor can do after this task, 1–2 sentences.

## Links
- <plan, research, pull request, related tasks; empty bullets are fine at creation>
```

Scope, acceptance criteria and decisions go into `plan.md` (`/{{p}}-create-plan`), never into the task.

A task is sized to one coherent behaviour an actor notices — several commits, one manual check pass. Bigger → propose splitting it into several tasks before creating anything.

## Create

1. Resolve team, project, status, assignee, Product Value and Work Type. Any value ambiguous or missing → ask; never
   silently switch.
2. Search the team for an existing matching task (titles only) to avoid duplicates on retries.
3. Create the issue.
4. Only with the business-questions module (`docs/agents/issue-tracker.md` «Business questions»): list the issues of
   its project that are not `Done`: these are themes of business questions. For each open question the new task cannot
   be finished without, record it on the task as `/{{p}}-business-questions` describes under «Development side».

## Business questions

Only with the business-questions module: a question to the partner or the business is a line in a theme of its
project, not a development task: use `/{{p}}-business-questions`.

## Report

Each task identifier with its clickable link, plus team, project, status, priority, assignee, Product Value and Work
Type. With the
business-questions module, for a new development task, also the business questions that block it.

_Last modified: 2026-11-11_
