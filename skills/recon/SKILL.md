---
name: ag-recon
description: Map the code relevant to a task in an Explore subagent and return a compact context summary. Use before implementing a feature or fix that touches unfamiliar code paths in tg-sales-bot.
---

# Recon

Spawn an Explore subagent to map the code relevant to the task. The subagent reads files; the main context receives only the compact output.

## When to use

- The task touches 3+ files or unfamiliar code paths
- A new feature in an existing app
- A bug whose cause is unknown
- Any task where you would otherwise do 5+ file reads to orient yourself

## Steps

1. No task description given → ask: «Опиши задачу для recon.»
2. Spawn `Agent(subagent_type="Explore")` with the prompt below, `{TASK}` filled in.
3. Read no files before the subagent returns.
4. Use the summary as working context. Read files yourself only where it leaves a gap: an entry under
   "Not found / unsure", or a symbol you are about to change that is missing from "Usages".

## Subagent prompt

````
You are a code exploration agent for tg-sales-bot (Python 3.13, Django 5.2, aiogram 3, Celery).
Django apps live in tg_sales_bot/ (catalog, customers, orders, payments, delivery, core, bot);
settings, Celery and URLs in config/. Domain terms come from CONTEXT.md; bot screens and texts
from docs/bot-design.md.

Task to prepare context for:
{TASK}

Find all code relevant to this task and return a COMPACT summary. Explore and report only: the
caller implements from your report, so what you leave out, the caller does not know.

1. Locate relevant code with CodeGraph: `codegraph explore <task words>` for the area, `codegraph callers <symbol>` and `codegraph impact <symbol>` for each symbol the task changes. Texts in `docs/` and string literals → grep.
2. Read only the parts needed for this task.
3. For every symbol the task changes (function, method, class, model field, callback data, bot text key), list every usage: `codegraph callers` for Python symbols, grep for string literals and `docs/`.
4. Return the output below.

Done when every symbol from step 3 has its usages listed, or is named under "Not found / unsure".

---

## Relevant files
- `path/to/file.py` — what role this file plays for the task

## Key code
Only the snippets needed, verbatim, max 30 lines each, with their line range:

```python
# path/to/file.py:L42-L67
<snippet>
```

## Usages
- `symbol_name` — `path/to/file.py:L12`, `path/to/other.py:L88`

## Patterns & constraints
- Existing patterns the implementation must follow
- Constraints, gotchas, non-obvious dependencies (ADRs in docs/adr/ that apply)
- Similar existing code to reference

## Not found / unsure
- What you searched for and did not find (with the search you ran)
- Where you are guessing rather than reading it in the code
- "Nothing" if neither applies

---

Snippets only, no full file dumps, no unrelated imports. Omit files with no relevant code.
State as fact only what you read in the code; everything else goes under "Not found / unsure".
````

_Last modified: 2026-10-13_
