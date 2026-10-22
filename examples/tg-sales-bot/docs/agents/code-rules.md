# Code rules

How code is written in this project. `/ag-develop`, the TDD subagents and `/ag-code-review` read this file in full.
Pack sections sit between `<!-- pack:NAME -->` markers and come from `agent-kit/packs/`; edit them there and pull
through `sync`. Everything else is the project's own.

## Layers

Domain apps (`catalog`, `customers`, `orders`, `payments`, `delivery`, `core`) know nothing about the Channel
(ADR-0007). `bot` is the Telegram Channel adapter; `mini_app` holds the Telegram Mini App pages. The Django layers —
model, domain service, admin — are in the `django` pack below; this project adds:

- **Domain service** (`<app>/services/`) calls YooKassa and Ozon; it returns domain data («нужно Согласие», «Товар
  недоступен», «сводка с суммами»), never imports aiogram, never returns button texts or keyboards.
- **Channel adapter service** (`bot/services/`) — turns a domain service result into a screen: text, keyboard, dialog
  state. The dialog state holds only the current step; checkout data lives in the Cart (ADR-0006).
- **Bot handler** (`bot/handlers/`) — parse the aiogram update, call one service, send the reply. A handler holds no
  business rules, no multi-model orchestration, no external API calls.

> **Forbidden:** business logic in `handlers/*.py` or `bot/services/`. Logic inspects model state → method on the
> model; anything else → a domain service.

A plan's «where new code lives» names the domain service or the `bot/` adapter, per ADR-0007.

## Where code goes

The app layout of the `django` pack under `tg_sales_bot/<app>/`, plus `bot/tests/e2e/test_<flow>.py` — Buyer
scenarios through the dispatcher, only in `bot`.

## Ticket slicing

- A domain service and the `bot/` screen that uses it are separate tickets.
- An FSM scenario splits by step or by behaviour (input + validation, `Назад`, skip for saved data).
- Layer slices are fine while the new code is unreachable — the ticket that wires it into a handler comes last in its
  part.

## Code quality

- Celery: the schedule lives in `config/celery.py` (`beat_schedule`); a task imports `from config.celery import app as
  celery_app` and is decorated with `@celery_app.task`.
- mypy runs with `django-stubs` over `tg_sales_bot`.
- Logging is loguru: `logger.bind(**kwargs).debug('message')`.

<!-- pack:python -->
<!-- /pack:python -->

<!-- pack:django -->
<!-- /pack:django -->
