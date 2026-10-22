# Test writer — rules

Read `docs/agents/testing.md` in full first: the stack, the project's STOP conditions, database, mocks, file placement,
E2E scenarios and reference tests. It wins where it disagrees with this file. Commands (`check`, `unit`, `e2e`,
`one-test`) are keys of `docs/agents/stack.md` «Commands».

## STOP conditions

Stop and report instead of continuing:

- **Logic bug** — a test fails because the production code is wrong. Keep the expected value; say: "The test is correct, the logic is broken: {description}".
- **Missing target** — the test needs a function, class or import that does not exist. Leave it missing and report.
- **A fix would touch production code** — anything outside the test files, fixtures and factories `testing.md` names. Not even a one-line import or lint fix.
- The STOP conditions of `testing.md`.

## Workflow

### Step 0 — Gather context

- Read the source of the function, class, or module under test.
- Pick the level: a function, class or module under test → unit test; an actor scenario (commands, button presses, screens, requests) → E2E, and `testing.md` «E2E scenarios» overrides the unit rules it names.
- Read existing tests at the place `testing.md` «File placement» gives, if any.
- Read the nearest fixtures and factories — reuse what exists before writing your own.

### Step 1 — Plan (MANDATORY, before writing any code)

1. List every scenario in scope, one line each. Scope is what the caller asked for — nothing beyond it.
2. Per function under test, group the scenarios and apply **Parametrize** below.
3. State which tests stay separate, which merge, and why: "Merged tests A, B, C into parametrize `test_X` over parameters [...]".

### Step 2 — Write code

Put each piece where `testing.md` «File placement» says. Merge parametrize candidates as you write — never write separate tests intending to merge later.

Re-read the written file against the plan: every parametrize candidate named in Step 1 is merged in the code.

### Step 3 — Run

Specific named tests, new tests, or the whole file: `one-test`. A whole level: `unit` or `e2e`; one app or a parallel
run: `testing.md` «Running».

### Step 4 — React to failures

- Test bug (syntax, wrong mock, wrong test data, wrong import in the test) — fix the test and re-run.
- Anything else — see **STOP conditions**.

### Step 5 — check

`check` runs the linters, the type checker and the schema check. Fix what it reports in the test files.

### Step 6 — Final report (MANDATORY)

- Path to the test file
- Each test tagged `[single]` or `[parametrize: N cases]`
- "Parametrize candidates I did NOT merge: none | <which and why>"
- Result of `check`

---

## Testing rules

### General

- **One test per behavior.** Variants of the same behavior differing only by input belong in parametrize.
- **Only what the caller asked for.** No "while I'm here" extras. Every assert must fail on its own: drop one that the function's return type or a neighbouring assert already guarantees (`isinstance` on a service result).
- AAA (Arrange – Act – Assert), separated by blank lines. The Act result always goes into a variable, never inlined into `assert`. Name it by what it is when the value is a domain object (`cart = await upsert_cart(...)`, `order`, `product_view`); name it `result` only when the value has no domain name (a number, a bool, a tuple, a status). If the name is already taken by an Arrange object, rename the Arrange one (`existing_cart`), not the Act result.
- **No logic in the test body** — no `if` or `for` driving Arrange or Assert.
- **No comments in tests** (`# Arrange` etc.). A linter suppression is allowed.
- Descriptive names for test arguments and `parametrize` parameters too.
- Test data lives inside the test or the `parametrize` row, never in module-level globals.
- An error branch → the runner's raises check; several inputs raising the same error → one parametrize. Covering every error branch is not required — scope rules.
- Mock only at the process boundary `testing.md` «Mocks» names.
- Test observable behavior, not implementation details. Refactoring without behavior changes should normally not require changing the test. Query counts, prefetch, SQL shape and ORM call patterns are implementation: test them only when the caller asks for exactly that.

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

The harness and its rules are in `testing.md` «E2E scenarios». On top of them:

- **One test — one actor scenario**, from the first action to the last screen it asserts. Scenarios differing only by input → parametrize, as for unit tests.
- **AAA for a scenario:** Arrange — data, then the steps leading to the screen under test; Act — the steps under test and reading their results into variables; Assert.
- **What a scenario cannot see** (`docs/agents/product.md` «Checks»): assert the request the product made; name the case in the final report as manual-only.

## Reference tests

Before writing the first test in a file, open the closest one from `testing.md` «Reference tests» and match its style.

_Last modified: 2026-10-22_
