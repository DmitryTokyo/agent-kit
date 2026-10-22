# Testing

The project's testing stack and conventions. `/ag-test-writer`'s `rules.md` applies the general rules; this file adds
what is specific to the stack and the project, and wins where they disagree. Pack sections sit between
`<!-- pack:NAME -->` markers.

## Stack

pytest, pytest-django, pytest-asyncio (`asyncio_mode = auto`), pytest-mock, factory_boy, freezegun, PostgreSQL.
Settings come from `pyproject.toml` (`config.settings.test`).

## STOP conditions

- **The E2E harness lacks something** — `RecordingSession` does not know a Telegram method, `Buyer` has no such action.
  The harness (`bot/tests/e2e/conftest.py`, `buyer.py`, `telegram.py`) stays as it is; report what is missing.
- **PostgreSQL or Redis from `.env` unreachable** — report it; mocking the ORM is not a workaround.

## Running

```bash
uv run pytest -m unit tg_sales_bot/{app} -n 4 --dist=loadfile   # unit tests of one app
```

No `-n` for a single test and never for E2E: scenarios share one Redis database.

## Database

The `django` pack below. Global `afactory` fixture: `tg_sales_bot/conftest.py`.

## Mocks

Only at the process boundary: Telegram API, YooKassa, Ozon API, Celery `.delay()`.

- An aiogram handler test asserts two things only: the service was called with the parsed arguments, and the reply was
  sent. Business assertions belong in the service's own test.

## File placement

- The `django` pack below for unit tests and factories.
- E2E scenarios: `bot/tests/e2e/test_{flow}.py`, one file per Buyer flow (`test_start.py`, `test_showcase.py`).
- The directory sets the level: `tests/unit/` → marker `unit`, `tests/e2e/` → marker `e2e`. A test file anywhere else
  under `tg_sales_bot/` stops collection with an error.

## E2E scenarios

A scenario feeds the Buyer's updates into the real dispatcher: routers, filters, middleware, FSM, services, PostgreSQL
and the test Redis all run for real.

- **Every action goes through `buyer`:** `await buyer.send_command('/start')`, `await buyer.press('→')`. `press` acts
  on `buyer.last_message`; pass an earlier message as the second argument to press a button on it. Two simultaneous
  presses: `await asyncio.gather(buyer.press('→', gallery), buyer.press('→', gallery))`.
- **Assert what the bot sent and what is in the DB.** Sent: `buyer.requests` (every request in order),
  `buyer.requests_of(EditMessageMedia)`, `buyer.last_message`. DB: ORM reads
  (`[item async for item in CartItem.objects.values_list(...)]`, `await Cart.objects.acount()`).
- **`buyer.last_message` moves with every step** — assign it to a named variable right after the step whose screen is
  asserted: `gallery = buyer.last_message`. Message ids count from 1 inside each test: the menu after `/start` is `1`,
  the next new message `2`.
- **Buttons of a message:** `[button.text for row in message.reply_markup.inline_keyboard for button in row]`.
- **Only Telegram is replaced** — by the `telegram` fixture (`RecordingSession`), already wired into `buyer`. A
  scenario uses no `mocker`. Telegram refusing a request: `telegram.reject_next(DeleteMessage, "message can't be
  deleted for everyone")` before the step.
- **Bot texts are set in the test** through `BotSettingsFactory` (`welcome_text='Тестовое приветствие'`,
  `catalog_list_caption_template='Слайд {name}'`), so asserts compare against literals visible in the same test.
- **A change made by the admin mid-scenario** (Товар deactivated) is the one DB write past factories:
  `await Product.objects.filter(name__in=['А']).aupdate(is_active=False)`.
- Module level: `pytestmark = pytest.mark.django_db(transaction=True)`.
- **What a scenario cannot see** is the chat itself: whether the photo really changed, whether `<s>` renders struck
  through, the real age of a message. Assert the bot's request; name the case in the final report as manual-only.

## Reference tests

- `tg_sales_bot/bot/tests/unit/test_webhook.py` — async test, `settings` fixture, `mocker.AsyncMock`
- `tg_sales_bot/bot/tests/e2e/test_showcase.py` — E2E scenarios of the pilot: screen-by-screen flow, parametrize, DB
  asserts, `telegram.reject_next`
- `config/tests/test_health.py` — `mocker.patch` for an external call, module-level `django_db`

<!-- pack:python -->
<!-- /pack:python -->

<!-- pack:django -->
<!-- /pack:django -->
