<!-- pack:django -->
## Django tests

- pytest-django, factory_boy, PostgreSQL. Settings come from `pyproject.toml` (`DJANGO_SETTINGS_MODULE` of the test
  settings) — never set it on the command line.
- The database from `.env` unreachable → STOP and report it; mocking the ORM is not a workaround.
- A test touching the DB → `pytestmark = pytest.mark.django_db` at module level. An async test touching the ORM needs
  `pytest.mark.django_db(transaction=True)`; prefer testing the sync service directly.
- Create and change DB objects only through factories; in async tests through the global `afactory` fixture
  (`afactory_batch(factory, size, **kwargs)` for N objects). Use the ORM for reads and assertions.
- Build model instances with factories — never mock a model, its fields or relations, even when the function looks
  DB-free. Simple ORM queries, data construction and pure transformations run for real.
- ORM behaviour is the framework's: a test never checks that a filter filters, a create creates, or `afirst()` gives
  `None` on an empty table. A function that only wraps an ORM call gets no test: it is a finding of `hygiene.md`
  «ORM wrapper», reported instead. A custom QuerySet or Manager method gets one test of its domain condition — the
  rows that qualify and the ones that don't, as one `parametrize`.
- Django settings → the `settings` fixture from pytest-django, never `override_settings` or `mocker.patch`.
- Factories: `ProductFactory.create(...)` — always call the method; a bare `ProductFactory(...)` is forbidden.
  `.create()` persists and is the default; `.build()` for tests that do not touch the DB; `.create_batch(N)` /
  `.build_batch(N)` for N objects. Nested attributes via `__`: `OrderFactory.create(customer__full_name='...')`.
- Factories live only in `<app>/tests/factories.py`.
- Unit tests: `<app>/tests/unit/test_<module>.py`; `<app>/<any_structure>/<module>.py` → `<app>/tests/unit/test_<module>.py`.
  Two modules of one app share a name → the file takes the package as a suffix: `test_cart_service.py`,
  `test_cart_handlers.py`.
- An app's first test creates `<app>/tests/__init__.py` and `<app>/tests/unit/__init__.py`; a leftover Django stub
  `<app>/tests.py` is deleted — it cannot coexist with the package.
<!-- /pack:django -->
