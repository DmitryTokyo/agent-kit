<!-- pack:python -->
## Python

### A call to our own function goes into its own variable first

The result of calling one of our functions lands in a descriptive variable on its own line. Only then may it be used —
chained, filtered, passed as an argument, returned. A call buried inside a bigger expression leaves nowhere to put a
breakpoint to see what it returned.

Applies to assignments, query chains, arguments, comprehensions, and ternaries.

```python
# correct
available_products = get_available_products(order.customer)
product_ids = [product.id for product in available_products]
return product_ids

# wrong
return [product.id for product in get_available_products(order.customer)]
```

This is about our own functions, not library or stdlib chains built from scratch.

**Exception: builtin type constructors.** `list`, `set`, `dict`, `tuple`, `str`, `int` may wrap an already-extracted
variable directly.

**Exception: our Enum classmethods** may be inlined into an `if` or comprehension — see below.

### Function vs class

Write a plain function by default. Reach for a class when the code needs one of:

- state carried across calls — config loaded once, a cache, a connection;
- two or more real, interchangeable implementations behind one interface (not a hypothetical future one);
- a framework requirement.

Test: remove `self` from every method and pass the same argument explicitly instead — if the code still works, write it
as functions.

```python
# correct — no state, one implementation
async def list_available_products() -> list[CatalogProduct]: ...
async def get_available_product(product_id: int) -> CatalogProduct | None: ...


# a class earns its place once a second implementation exists
class PaymentProvider(Protocol):
    async def charge(self, amount: Decimal) -> Receipt: ...
```

### Enum usage — no duplicate value sets

Never duplicate enum values into a separate set or constant, and never write `{s.value for s in MyEnum}` inline in a
condition. Add a descriptive classmethod to the enum and call it at the site.

```python
class OrderStatus(StrEnum):
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

Every function gets parameter and return annotations: an untyped function silently skips the type checker.

### Logging

A log message is static. Runtime values go as structured context (`logger.bind(**kwargs)` for loguru, `extra=` for
`logging`), never interpolated into the message.
<!-- /pack:python -->
