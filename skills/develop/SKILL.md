---
name: ag-develop
description: Code conventions for writing or modifying Python in tg-sales-bot directly, without a ticket — layers, verification commands, app layout, constants, Celery, code quality. A ticket from .ai/tasks/ag-N-*/tickets/ with `Режим: TDD` goes to /ag-tdd-develop; with `Режим: без тестов` — here.
---

# tg-sales-bot development rules

Project context, domain language and guardrails live in `CLAUDE.md`, `AGENTS.md` and `CONTEXT.md`. This file covers how code is written.

## Before implementing

Input is a ticket with `Режим: без тестов` → its description and checklist are the task; tests are not needed, skip the question about them. Do the manual check from the ticket's tests line, then tick the checklist and set `Status: done`; once committed, tick its line in `tickets/00-map.md` with ` — <short hash>`. A ticket with `Режим: TDD` → stop, suggest `/ag-tdd-develop`.

Input is a review file from `.ai/tasks/ag-N-*/reviews/` → its unticked findings are the task. The developer's answers
are in its digest, `<review>.ru.md`, under the same numbers; a line for all TODOs covers every TODO without its own
answer. Each finding by its tag:

- `FIX` → the outcome in `CONTRIBUTING.md` «Code review».
- `NOTE` → as its answer says.
- `TODO` → `делать`: fixed in this round; `отложить`: appended to `.ai/tasks/ag-N-*/reviews/todo.md` as an unticked
  line with the review file, its number and the finding; `пропустить`: closed unchanged.

A `NOTE` or `TODO` without an answer, or no digest → stop and ask the user, naming those numbers. Existing tests are
the check, new ones only when the finding asks for them. A finding that changes approved behaviour, or that you
disagree with → ask the user. Each closed finding gets its box ticked, and the fixes are one commit per
`/ag-git-commit-message`, at most 100 lines of production code. Every finding ticked → tick `Ревью агентом` in the
map section for that batch. The final report lists every finding by number with its outcome: fixed, done as answered,
deferred or skipped.

Input is `.ai/tasks/ag-N-*/reviews/todo.md` → its unticked lines are the task, as `делать` TODOs, in one commit; each
fixed line gets its box ticked.

When a concrete task is known (feature, fix, refactor), run `/ag-recon` first and use its summary as context — do not re-read those files. Skip recon only for a single-file change at a known location.

If the user did NOT explicitly ask for tests, ask whether tests are needed before implementing. Fixing a test that your change breaks is allowed; keep the fix minimal. When tests are agreed, invoke `/ag-test-writer`.

### Scope

The user's task is the only scope. Read callers and dependents only to see what a choice would break, never to fix or refactor them on your own initiative. When anything about how to proceed is unknown or ambiguous — a new contract not covering what the old one did, an effect reaching beyond what was asked — stop and ask one question instead of deciding.

### Simplicity

Minimum code that solves the task: no features, abstractions, configurability or error handling for cases nobody asked for. If 200 lines could be 50, rewrite.

## Commands

```bash
make check          # ruff --fix, then ruff + mypy + makemigrations --check (run after every change)
make test           # unit tests: tg_sales_bot/<app>/tests/unit/
make parallel_test  # same, 4 workers
make e2e            # E2E scenarios: tg_sales_bot/bot/tests/e2e/, one process

# Run a single test
uv run pytest tg_sales_bot/catalog/tests/unit/test_pricing.py::test_calculate_total -q
```

`make check` must pass before reporting a change as done. `make test` and `make e2e` cover `tg_sales_bot` only — tests under `config/` need `uv run pytest config`.

## Layer responsibilities

Domain apps (`catalog`, `customers`, `orders`, `payments`, `delivery`, `core`) know nothing about the Channel (ADR-0007). `bot` is the Telegram Channel adapter; `mini_app` holds the Telegram Mini App pages.

**Model** — only logic tied to this model's data: fetching data in the required shape, atomic updates across several fields, state that belongs to the object itself.

**Domain service** (`<app>/services/`) — all business logic, orchestration across models, calls to external APIs (YooKassa, Ozon). Takes and returns domain data («нужно Согласие», «Товар недоступен», «сводка с суммами»); never imports aiogram, never returns button texts or keyboards.

**Channel adapter service** (`bot/services/`) — turns a domain service result into a screen: text, keyboard, dialog state. The dialog state holds only the current step; checkout data lives in the Cart (ADR-0006).

**Bot handler** (`bot/handlers/`) — parse the aiogram update, call one service, send the reply. A handler holds no business rules, no multi-model orchestration, no external API calls.

**Admin** (`admin.py`) — display and validation configuration only.

> **Forbidden:** business logic in `handlers/*.py` or `bot/services/`. Where to put it instead:
> - Logic inspects model state → method on the model
> - Anything else → a domain service

Services are async-aware: a service called from a handler must not do blocking ORM work. Use Django's native async ORM methods (`aget`, `acreate`, `aupdate_or_create`, `acount`, etc.) when available; otherwise wrap the synchronous ORM call in `sync_to_async` at the service boundary, never in the handler.

## Where code goes inside an app

```
tg_sales_bot/<app>/
    models.py
    admin.py
    constants.py       # all module-level constants for the app
    enums.py           # every enum of the app, model choices included
    services/          # one module per business operation
    tasks.py           # Celery tasks
    tests/
        __init__.py
        factories.py       # factory_boy factories for this app's models
        conftest.py        # fixtures for this app
        unit/
            __init__.py
            test_<module>.py   # mirrors the module under test, whatever its depth
        e2e/                   # only in bot: Buyer scenarios through the dispatcher
            test_<flow>.py
```

Create `services/`, `constants.py`, `enums.py`, or `tests/` on first need — do not pre-create empty packages.

## Models

Inside a model, declare in this order: plain fields, then `ForeignKey`/`OneToOneField`, then `ManyToManyField`, then a custom manager. `class Meta`, `__str__`, `save`, `get_absolute_url` and other methods follow, in that order.

```python
class Order(models.Model):
    status = models.CharField(...)
    total_amount = models.DecimalField(...)
    customer = models.ForeignKey(Customer, ...)
    pickup_point = models.ForeignKey(PickupPoint, ...)

    class Meta: ...

    def __str__(self) -> str: ...
    def save(self, *args, **kwargs) -> None: ...
```

Ruff's `DJ012` enforces the macro order (fields → manager → `Meta` → `__str__` → `save` → `get_absolute_url` → methods). The plain-fields/FK/M2M sub-order is convention only.

A schema change ends with `uv run manage.py makemigrations <app>`; `make check` fails on a missing migration.

## Constants

Constants live in `tg_sales_bot/<app>/constants.py` — one module per app. If it does not exist yet, create it; if it exists, add the constant there and import it. A module-level constant in a service, handler, or model file is a violation.

`constants.py` holds plain values only: numbers, strings, regexes, tuples of them. A class is a structure, not a constant: an enum (`StrEnum`, `TextChoices`, `IntegerChoices`) goes to `tg_sales_bot/<app>/enums.py`, a model's choices too; a DTO goes to `dto.py`.

## Celery tasks

Schedule lives in code, in `config/celery.py` (`beat_schedule`). There is no `django-celery-beat`; there is nothing to configure in Django Admin.

```python
# tg_sales_bot/<app>/tasks.py
from config.celery import app as celery_app


@celery_app.task
def my_task() -> None: ...
```

A task is a thin wrapper: it resolves arguments and calls a service. Business logic stays in the service so it is testable without Celery.

## Code quality

### A call to our own function goes into its own variable first

The result of calling one of our functions lands in a descriptive variable on its own line. Only then may it be used — chained, filtered, passed as an argument, returned. A call buried inside a bigger expression leaves nowhere to put a breakpoint to see what it returned.

Applies to assignments, ORM chains, arguments, comprehensions, and ternaries.

```python
# correct
available_products_qs = get_available_products(order.customer)
product_ids = available_products_qs.values_list('id', flat=True)
return list(product_ids)

# wrong
return list(get_available_products(order.customer).values_list('id', flat=True))
```

This is about our own functions, not ORM or stdlib chains built from scratch: `return Product.objects.filter(...).values_list(...)` is fine, `timezone.now()` inside a filter is fine.

**Exception: builtin type constructors.** `list`, `set`, `dict`, `tuple`, `str`, `int` may wrap an already-extracted variable directly.

**Exception: our Enum classmethods** may be inlined into an `if` or comprehension — see below.

**Exception: methods of our custom QuerySet or Manager** (`PickupPoint.objects.selectable().filter(...)`) chain like built-in ORM methods.

### Function vs class

Write a plain function by default. Reach for a class when the code needs one of:

- state carried across calls — config loaded once, a cache, a connection;
- two or more real, interchangeable implementations behind one interface (not a hypothetical future one);
- a Django/aiogram requirement — models, admin classes, Celery task classes, filters.

Test: remove `self` from every method and pass the same argument explicitly instead — if the code still works, write it as functions.

```python
# correct — no state, one implementation
async def list_available_products() -> list[CatalogProduct]: ...
async def get_available_product(product_id: int) -> CatalogProduct | None: ...


# a class earns its place once a second implementation exists
class PaymentProvider(Protocol):
    async def charge(self, amount: Decimal) -> Receipt: ...
```

### Enum usage — no duplicate value sets

Never duplicate enum values into a separate set or constant, and never write `{s.value for s in MyEnum}` inline in a condition. Add a descriptive classmethod to the enum and call it at the site.

```python
class OrderStatus(models.TextChoices):
    NEW = 'new'
    PAID = 'paid'
    SHIPPED = 'shipped'

    @classmethod
    def cancellable_statuses(cls) -> set[str]:
        return {cls.NEW.value, cls.PAID.value}


# usage — inlined, no separate variable needed
if order.status in OrderStatus.cancellable_statuses():
    ...
```

Name the method for what it returns — `cancellable_statuses()`, `all_statuses()` — not a generic `values()`.

### Type annotations

Every function gets parameter and return annotations. mypy runs with `django-stubs` over `tg_sales_bot`; an untyped function silently skips checking.

## After writing code

1. `make check` — green.
2. Run `/ag-hygiene-review` on the changed files. Clear violations of a rule in this file → fix and include in the final report. Ambiguous findings → ask the user before touching.
3. After fixes, `make check` again.

_Last modified: 2026-10-20_
