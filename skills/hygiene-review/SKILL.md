---
name: ag-hygiene-review
description: Scan changed or new files in tg-sales-bot for hygiene issues ruff and mypy miss — Channel leaks into domain apps, constants and enums outside their modules, dynamic log messages, member and function ordering. Use after implementing a change, on the changed files.
---

# Hygiene review

Spawn an Explore subagent to scan the changed/new files for the issues below. Report findings; fixing needs a judgement call, so ask before touching.

## Steps

1. Spawn `Agent(subagent_type="Explore")` with the prompt below, `{CHANGED_FILES}` filled in.
2. Report each finding to the user.

## Subagent prompt

```
Scan these changed/new files in tg-sales-bot for hygiene issues. Report only, fix nothing.

Files:
{CHANGED_FILES}

## Channel leak into domain apps (ADR-0007)
Domain apps: tg_sales_bot/{catalog,customers,orders,payments,delivery,core}/.
- An `aiogram` import, or a button text / keyboard built in a domain app → report:
  "CHANNEL LEAK: <file>:<line> — domain code must not know the Channel; move to tg_sales_bot/bot/"
- A business rule (a decision about Cart, Order, Consent, prices, availability) inside
  tg_sales_bot/bot/handlers/ or tg_sales_bot/bot/services/ → report:
  "RULE IN ADAPTER: <file>:<line> — move the decision into a domain service, keep screen building in bot/"

## Blocking ORM in async code
- A synchronous ORM call (`.get(`, `.filter(...)` evaluated, `.save(`, `.create(`) inside an `async def`,
  not wrapped in `sync_to_async` and not an `a*` async ORM method → report:
  "SYNC ORM IN ASYNC: <file>:<line> — use the async ORM method or sync_to_async at the service boundary"

## Constants outside constants.py
- A module-level `UPPER_CASE = ...` constant in a file that is neither `constants.py` nor a test `conftest.py`
  (test settings live there; in `test_*.py` it is still a finding — move it to the nearest `conftest.py`) → report:
  "CONSTANT OUTSIDE constants.py: <file>:<line> — move `<NAME>` to tg_sales_bot/<app>/constants.py"
- A class in `constants.py`, or an enum (`StrEnum`, `TextChoices`, `IntegerChoices`) outside `enums.py` → report:
  "CLASS OUTSIDE ITS MODULE: <file>:<line> — move `<Name>` to tg_sales_bot/<app>/enums.py (enum) or dto.py (DTO)"

## Logging
- A loguru message built from runtime values (f-string, `.format`, `%`, concatenation) → report:
  "DYNAMIC LOG MESSAGE: <file>:<line> — keep the message static, pass values via logger.bind(**kwargs)"
- A `logger.bind(key=...)` value that branches (ternary, `and`/`or` picking a value) → report:
  "LOGGER BUSINESS LOGIC: <file>:<line> — compute `<key>` in a variable before logger.bind()".
  Plain attribute access (`order.pk`, `customer.id`) is fine and is not a finding.

## Own function call buried in an expression
- A call to one of our functions (defined in tg_sales_bot/ or config/) used directly inside a bigger
  expression — chained, passed as an argument, returned inline — instead of first landing in its own
  variable → report: "BURIED CALL: <file>:<line> — assign `<call>` to a descriptive variable first".
  Exceptions, not findings: builtin constructors (`list(...)`, `set(...)`) around a variable,
  classmethods of our Enum/TextChoices classes, ORM/stdlib chains built from scratch, methods of our
  custom QuerySet or Manager chained like ORM methods (`PickupPoint.objects.selectable().filter(...)`).

## Class member ordering
Django models: ruff's DJ012 fixes the start (fields → manager → Meta → __str__ → save → get_absolute_url);
the categories below apply to the methods after that block.
Other classes: members after fields/Meta, in this order:
1. properties (`@property`, `@cached_property`)
2. static methods
3. class methods
4. public instance methods
5. private methods (leading `_`)
6. framework hooks — dunder methods and overridden lifecycle methods (`__str__`, `save`, `clean`,
   `get_queryset`, etc.)
A new/changed member goes at the bottom of its own category block.
- A member added or moved in the diff out of place → report:
  "MEMBER ORDER: <file>:<line> — `<name>` is a <category>; move it to the end of the <category> block"

## Module-level function ordering
Public functions first, private (leading `_`) helpers below them.
- A private function above a public one → report:
  "MODULE FUNCTION ORDER: <file>:<line> — `<name>` is private; move it below the public functions"

Output: one line per finding, in the formats above. Nothing found → "No hygiene issues found."
```

_Last modified: 2026-10-20_
