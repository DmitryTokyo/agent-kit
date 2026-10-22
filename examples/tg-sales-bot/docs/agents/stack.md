# Stack

What the code is built with and the commands every skill runs. The skills name a command by its key from «Commands»
(`check`, `unit`, …) and never spell it out.

## Stack

Python 3.13, Django 5.2, PostgreSQL, Redis, aiogram 3, Celery + Beat. The Telegram bot runs inside the Django project
as `manage.py runbot`.

## Layout

- `tg_sales_bot/` — Django apps: domain apps `catalog`, `customers`, `orders`, `payments`, `delivery`, `core`; `bot`
  is the Telegram Channel adapter; `mini_app` holds the Telegram Mini App pages.
- `config/` — settings, ASGI/WSGI, Celery, URL routes, health-check.
- Domain terms: `CONTEXT.md`; bot screens and texts: `docs/bot-design.md`.

## Commands

| Key | Command | Runs |
| --- | --- | --- |
| `check` | `make check` | ruff --fix, then ruff + mypy + makemigrations --check |
| `unit` | `make test` | unit tests: `tg_sales_bot/<app>/tests/unit/`; `make parallel_test` — 4 workers |
| `e2e` | `make e2e` | E2E scenarios: `tg_sales_bot/bot/tests/e2e/`, one process |
| `one-test` | `uv run pytest {file} -k "{test}" --tb=short -q` | one test or one file |
| `migrate` | `uv run manage.py makemigrations <app>` | the schema migration after a model change |

- `unit` and `e2e` cover `tg_sales_bot` only — tests under `config/` need `uv run pytest config`.
- Both need PostgreSQL and Redis from `.env`, and `TEST_REDIS_URL` different from `REDIS_URL`.

## Line count

Production lines of a ticket are counted without these paths:

```text
':!**/tests/**' ':!**/migrations/**'
```

Test lines are counted over these paths:

```text
'**/tests/**'
```
