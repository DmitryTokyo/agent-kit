<!-- pack:django -->
## Blocking ORM in async code
- A synchronous ORM call (`.get(`, `.filter(...)` evaluated, `.save(`, `.create(`) inside an `async def`,
  not wrapped in `sync_to_async` and not an `a*` async ORM method → report:
  "SYNC ORM IN ASYNC: <file>:<line> — use the async ORM method or sync_to_async at the service boundary"

## Constants outside constants.py
- A module-level `UPPER_CASE = ...` constant in a file that is neither `constants.py` nor a test `conftest.py`
  (test settings live there; in `test_*.py` it is still a finding — move it to the nearest `conftest.py`) → report:
  "CONSTANT OUTSIDE constants.py: <file>:<line> — move `<NAME>` to <app>/constants.py"
- A class in `constants.py`, or an enum (`StrEnum`, `TextChoices`, `IntegerChoices`) outside `enums.py` → report:
  "CLASS OUTSIDE ITS MODULE: <file>:<line> — move `<Name>` to <app>/enums.py (enum) or dto.py (DTO)"

## Model member ordering
Ruff's DJ012 fixes the start of a model (fields → manager → Meta → __str__ → save → get_absolute_url);
the class member ordering applies to the methods after that block.

## Buried call exceptions
Methods of our custom QuerySet or Manager chained like ORM methods are not a BURIED CALL.
<!-- /pack:django -->
