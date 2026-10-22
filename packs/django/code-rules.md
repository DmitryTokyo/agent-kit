<!-- pack:django -->
## Django

### Layers

**Model** — only logic tied to this model's data: fetching data in the required shape, atomic updates across several
fields, state that belongs to the object itself.

**Domain service** (`<app>/services/`) — all business logic, orchestration across models, calls to external APIs.
Takes and returns domain data.

**Admin** (`admin.py`) — display and validation configuration only.

Where a rule goes: logic inspects model state → method on the model; anything else → a domain service.

Services called from async code do no blocking ORM work: Django's async ORM methods (`aget`, `acreate`,
`aupdate_or_create`, `acount`, …) when available, otherwise `sync_to_async` at the service boundary, never in the
caller.

### Where code goes inside an app

```
<app>/
    models.py
    admin.py
    constants.py       # all module-level constants for the app
    enums.py           # every enum of the app, model choices included
    dto.py             # data classes passed between layers
    services/          # one module per business operation
    tasks.py           # Celery tasks
    tests/
        __init__.py
        factories.py       # factory_boy factories for this app's models
        conftest.py        # fixtures for this app
        unit/
            __init__.py
            test_<module>.py   # mirrors the module under test, whatever its depth
```

Create `services/`, `constants.py`, `enums.py`, or `tests/` on first need — do not pre-create empty packages.

### Models

Inside a model, declare in this order: plain fields, then `ForeignKey`/`OneToOneField`, then `ManyToManyField`, then a
custom manager. `class Meta`, `__str__`, `save`, `get_absolute_url` and other methods follow, in that order.

```python
class Order(models.Model):
    status = models.CharField(...)
    total_amount = models.DecimalField(...)
    customer = models.ForeignKey(Customer, ...)

    class Meta: ...

    def __str__(self) -> str: ...
    def save(self, *args, **kwargs) -> None: ...
```

Ruff's `DJ012` enforces the macro order (fields → manager → `Meta` → `__str__` → `save` → `get_absolute_url` →
methods). The plain-fields/FK/M2M sub-order is convention only.

A schema change ends with the `migrate` command; `check` fails on a missing migration.

### Constants

Constants live in `<app>/constants.py` — one module per app. If it does not exist yet, create it; if it exists, add the
constant there and import it. A module-level constant in a service, handler, or model file is a violation.

`constants.py` holds plain values only: numbers, strings, regexes, tuples of them. A class is a structure, not a
constant: an enum (`StrEnum`, `TextChoices`, `IntegerChoices`) goes to `<app>/enums.py`, a model's choices too; a DTO
goes to `dto.py`.

### Celery tasks

The schedule lives in code (`beat_schedule`); there is no `django-celery-beat`.

A task is a thin wrapper: it resolves arguments and calls a service. Business logic stays in the service so it is
testable without Celery.

### Query chains

Library ORM chains built from scratch are fine inline: `return Product.objects.filter(...).values_list(...)`.
Methods of our custom QuerySet or Manager (`PickupPoint.objects.selectable().filter(...)`) chain like built-in ORM
methods.
<!-- /pack:django -->
