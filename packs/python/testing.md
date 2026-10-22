<!-- pack:python -->
## Python tests

- pytest. `asyncio_mode = auto` with pytest-asyncio: a bare `async def test_...`, no `@pytest.mark.asyncio`.
- Tests are functions. No type hints in test functions; allowed in fixtures.
- Mocks: the `mocker` fixture from pytest-mock, never `from unittest import mock`. Async objects:
  `mocker.AsyncMock()`, asserted with `assert_awaited_once()` / `assert_awaited_once_with(...)`.
- Logger calls are not tested; the logger is not mocked.
- Dates: construct directly, `datetime.datetime(2026, 2, 23)`, without a time unless the test needs one. A pinned
  "now" → `@freeze_time('2026-02-23 12:00:00')` from `freezegun` on the test function; an async test adds
  `real_asyncio=True`. Patching the clock function is forbidden.
- Parametrize ids: no `pytest.param` or custom ids unless they add information pytest cannot provide naturally.
- A test file holds test functions only. Builders of messages, mocks or errors are fixtures in the nearest
  `conftest.py`; a private helper of fixtures lives there, below the fixtures that call it. A row of `parametrize`
  that needs such an object carries the fixture name as a string, resolved with `request.getfixturevalue(...)`.
- A constant a test file needs (a module path for `mocker.patch`) lives at the top of the nearest `conftest.py`.
<!-- /pack:python -->
