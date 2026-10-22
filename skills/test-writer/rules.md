# Test writer — rules

Stack: pytest, pytest-django, pytest-asyncio (`asyncio_mode = auto`), pytest-mock, factory_boy, PostgreSQL. Settings come from `pyproject.toml` (`config.settings.test`) — never set `DJANGO_SETTINGS_MODULE` on the command line.

## STOP conditions

Stop and report instead of continuing:

- **Logic bug** — a test fails because the production code is wrong. Keep the expected value; say: "The test is correct, the logic is broken: {description}".
- **Missing target** — the test needs a function, class or import that does not exist. Leave it missing and report.
- **A fix would touch production code** — anything outside `test_*.py`, `conftest.py`, `factories.py`, `tests/__init__.py`. Not even a one-line import or lint fix.
- **The E2E harness lacks something** — `RecordingSession` does not know a Telegram method, `Buyer` has no such action. The harness (`bot/tests/e2e/conftest.py`, `buyer.py`, `telegram.py`) stays as it is; report what is missing.
- **PostgreSQL or Redis from `.env` unreachable** — report it; mocking the ORM is not a workaround.

## Workflow

### Step 0 — Gather context

- Read the source of the function, class, or module under test.
- Pick the level: a function, class or module under test → unit test; a Buyer scenario (command, button presses, screens) → E2E, and **E2E scenarios** below overrides the unit rules it names.
- Read existing tests at `{app}/tests/unit/test_{module}.py`, if any; for E2E — the files in `bot/tests/e2e/`.
- Read the nearest `conftest.py` and `factories.py`, plus `tg_sales_bot/conftest.py` (the global `afactory` fixture) — reuse what exists before writing your own.

### Step 1 — Plan (MANDATORY, before writing any code)

1. List every scenario in scope, one line each. Scope is what the caller asked for — nothing beyond it.
2. Per function under test, group the scenarios and apply **Parametrize** below.
3. State which tests stay separate, which merge, and why: "Merged tests A, B, C into parametrize `test_X` over parameters [...]".

### Step 2 — Write code

Put each piece where **File placement** says. Merge parametrize candidates as you write — never write separate tests intending to merge later.

Re-read the written file against the plan: every parametrize candidate named in Step 1 is merged in the code.

### Step 3 — Run

Specific named tests:

```bash
uv run pytest {test_file} -k "{test_name_1} or {test_name_2}" --tb=short -q
```

New tests, or unclear scope — the whole file:

```bash
uv run pytest {test_file} --tb=short -q
```

A whole level:

```bash
make test           # every unit test (tests/unit/)
make parallel_test  # same, 4 workers
make e2e            # every E2E scenario (tests/e2e/), one process
uv run pytest -m unit tg_sales_bot/{app} -n 4 --dist=loadfile   # unit tests of one app
```

No `-n` for a single test and never for E2E: scenarios share one Redis database. Tests under `config/` need `uv run pytest config`.

### Step 4 — React to failures

- Test bug (syntax, wrong mock, wrong test data, wrong import in the test) — fix the test and re-run.
- Anything else — see **STOP conditions**.

### Step 5 — make check

`make check` runs ruff, mypy and the migrations check. Fix what it reports in the test files.

### Step 6 — Final report (MANDATORY)

- Path to the test file
- Each test tagged `[single]` or `[parametrize: N cases]`
- "Parametrize candidates I did NOT merge: none | <which and why>"
- Result of `make check`

---

## Testing rules

### General

- **Tests are functions.** No classes grouping tests.
- **One test per behavior.** Variants of the same behavior differing only by input belong in parametrize.
- **Only what the caller asked for.** No "while I'm here" extras. Every assert must fail on its own: drop one that the function's return type or a neighbouring assert already guarantees (`isinstance` on a service result).
- AAA (Arrange – Act – Assert), separated by blank lines. The Act result always goes into a variable, never inlined into `assert`. Name it by what it is when the value is a domain object (`cart = await upsert_cart(...)`, `order`, `product_view`); name it `result` only when the value has no domain name (a number, a bool, a tuple, a status). If the name is already taken by an Arrange object, rename the Arrange one (`existing_cart`), not the Act result.
- **No logic in the test body** — no `if` or `for` driving Arrange or Assert.
- **No comments in tests** (`# Arrange` etc.). A `# noqa: ...` suppression is allowed.
- No type hints in test functions; allowed in fixtures.
- Descriptive names for test arguments and `parametrize` parameters too.
- Don't use pytest.param or custom ids unless they add information pytest cannot provide naturally.
- Test data lives inside the test or the `parametrize` row, never in module-level globals. 
- An error branch → `pytest.raises`; several inputs raising the same error → one parametrize. Covering every error branch is not required — scope rules.
- Logger calls are not tested; loguru is not mocked.
- Test observable behavior, not implementation details. Refactoring without behavior changes should normally not require changing the test. Query counts, prefetch, SQL shape and ORM call patterns are implementation: test them only when the caller asks for exactly that.

### Database

- A test touching the DB → `pytestmark = pytest.mark.django_db` at module level.
- Create and change DB objects only through factories; in async tests through the global `afactory` fixture (`afactory_batch(factory, size, **kwargs)` for N objects). Use the ORM for reads and assertions.

### Async tests (aiogram handlers, async services)

- `asyncio_mode = auto`: write a bare `async def test_...`, no `@pytest.mark.asyncio`.
- In a unit test, mock aiogram objects with `mocker.AsyncMock()`. Assert with `assert_awaited_once()` / `assert_awaited_once_with(...)`.
- A handler test asserts two things only: the service was called with the parsed arguments, and the reply was sent. Business assertions belong in the service's own test.
- An async test touching the ORM needs `pytest.mark.django_db(transaction=True)`; prefer testing the sync service directly.

### Mocks

- The `mocker` fixture from pytest-mock. Never `from unittest import mock`.
- Mock only at the process boundary: Telegram API, YooKassa, Ozon API, Celery `.delay()`.
- Build model instances with factories — never mock a model, its fields or relations, even when the function looks DB-free. Simple ORM queries, data construction and pure transformations run for real.
- Django settings → the `settings` fixture from pytest-django, never `override_settings` or `mocker.patch`.

### Factories

- `ProductFactory.create(...)` — always call the method; a bare `ProductFactory(...)` is forbidden.
- `.create()` persists and is the default; `.build()` for tests that do not touch the DB; `.create_batch(N)` / `.build_batch(N)` for N objects.
- Nested attributes via `__`: `OrderFactory.create(customer__full_name='Иванов Иван Иванович')`.

### Dates

- Construct dates directly: `datetime.datetime(2026, 2, 23)`, without a time unless the test needs one.
- A test that needs a pinned `timezone.now()` → `@freeze_time('2026-02-23 12:00:00')` from `freezegun` on the test function; an async test adds `real_asyncio=True` so the event loop clock keeps running. Patching `timezone.now` is forbidden.

### File placement

- Unit tests: `{app}/tests/unit/test_{module}.py`. `{app}/{any_structure}/{module}.py` → `{app}/tests/unit/test_{module}.py`, so `catalog/services/pricing.py` → `catalog/tests/unit/test_pricing.py`. Two modules of one app share a name (`bot/services/cart.py`, `bot/handlers/cart.py`) → the file takes the package as a suffix: `test_cart_service.py`, `test_cart_handlers.py`.
- E2E scenarios: `bot/tests/e2e/test_{flow}.py`, one file per Buyer flow (`test_start.py`, `test_showcase.py`).
- The directory sets the level: `tests/unit/` → marker `unit`, `tests/e2e/` → marker `e2e`. A test file anywhere else under `tg_sales_bot/` stops collection with an error.
- Fixtures: only in the nearest `conftest.py`.
- A test file holds test functions only. Anything else a test needs — a builder of a message, keyboard, mock or error — is a fixture in the nearest `conftest.py`, never a module-level function in `test_*.py`. A private function that helps fixtures lives in `conftest.py`, below the fixtures that call it.
- A constant a test file needs (a module path for `mocker.patch`) is a test setting: it lives at the top of the nearest `conftest.py` and is imported from there, never declared in `test_*.py`.
- A `parametrize` row that needs such an object carries the fixture name as a string; the test resolves it with `request.getfixturevalue(message_fixture)`.
- Factories: only in `{app}/tests/factories.py`.
- An app's first test creates `{app}/tests/__init__.py` and `{app}/tests/unit/__init__.py`; a leftover Django stub `{app}/tests.py` is deleted — it cannot coexist with the package.

### Test naming

`test_<what_we_test>__<condition>__<expected>()`, or `test_<what_we_test>__<condition>()` when the expectation is obvious.

## Parametrize

**Rule:** ≥2 tests of the same function sharing the AAA structure and differing only by input or expected values MUST merge into one `parametrize`. Mandatory, not "if possible".

Trigger: can you write the cases as rows of a table `(input1, input2, ..., expected)`? Then parametrize. Expected values are fixed literals in the row, not booleans computed in the test body.

```python
@pytest.mark.parametrize(
    'quantity, expected_total',
    [
        (1, 1000),
        (3, 3000),
    ],
)
def test_calculate_order_total__multiplies_price_by_quantity(quantity, expected_total):
    product = ProductFactory.create(price=1000)

    result = calculate_order_total(product, quantity)

    assert result == expected_total
```

### When NOT to merge

- Different structure — one checks a return value, another a side effect, a third an exception.
- Different Arrange — one creates a product, another a product plus an order plus a payment.
- Logically distinct scenarios: happy path vs. product-not-found vs. payment-failed are three separate tests.

## E2E scenarios

A scenario feeds the Buyer's updates into the real dispatcher: routers, filters, middleware, FSM, services, PostgreSQL and the test Redis all run for real. **Testing rules** apply except where a line here says otherwise.

- **One test — one Buyer scenario**, from the first command to the last screen it asserts. Scenarios differing only by input → parametrize, as for unit tests.
- **Every action goes through `buyer`:** `await buyer.send_command('/start')`, `await buyer.press('→')`. `press` acts on `buyer.last_message`; pass an earlier message as the second argument to press a button on it. Two simultaneous presses: `await asyncio.gather(buyer.press('→', gallery), buyer.press('→', gallery))`.
- **Assert what the bot sent and what is in the DB.** Sent: `buyer.requests` (every request in order), `buyer.requests_of(EditMessageMedia)`, `buyer.last_message`. DB: ORM reads (`[item async for item in CartItem.objects.values_list(...)]`, `await Cart.objects.acount()`).
- **`buyer.last_message` moves with every step** — assign it to a named variable right after the step whose screen is asserted: `gallery = buyer.last_message`. Message ids count from 1 inside each test: the menu after `/start` is `1`, the next new message `2`.
- **Buttons of a message:** `[button.text for row in message.reply_markup.inline_keyboard for button in row]`.
- **Only Telegram is replaced** — by the `telegram` fixture (`RecordingSession`), already wired into `buyer`. A scenario uses no `mocker`. Telegram refusing a request: `telegram.reject_next(DeleteMessage, "message can't be deleted for everyone")` before the step.
- **AAA for a scenario:** Arrange — factories through `afactory`, then the steps leading to the screen under test; Act — the steps under test and reading their results into variables; Assert.
- **Bot texts are set in the test** through `BotSettingsFactory` (`welcome_text='Тестовое приветствие'`, `catalog_list_caption_template='Слайд {name}'`), so asserts compare against literals visible in the same test.
- **A change made by the admin mid-scenario** (Товар deactivated) is the one DB write past factories: `await Product.objects.filter(name__in=['А']).aupdate(is_active=False)`.
- Module level: `pytestmark = pytest.mark.django_db(transaction=True)`.
- **What a scenario cannot see** is the chat itself: whether the photo really changed, whether `<s>` renders struck through, the real age of a message. Assert the bot's request; name the case in the final report as manual-only.

## Reference tests

Before writing the first test in a file, open the closest one and match its style:

- `tg_sales_bot/bot/tests/unit/test_webhook.py` — async test, `settings` fixture, `mocker.AsyncMock`
- `tg_sales_bot/bot/tests/e2e/test_showcase.py` — E2E scenarios of the pilot: screen-by-screen flow, parametrize, DB asserts, `telegram.reject_next`
- `config/tests/test_health.py` — `mocker.patch` for an external call, module-level `django_db`

_Last modified: 2026-10-05_
