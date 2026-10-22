<!-- pack:python -->
## Logging
- A log message built from runtime values (f-string, `.format`, `%`, concatenation) → report:
  "DYNAMIC LOG MESSAGE: <file>:<line> — keep the message static, pass values as structured context"
- A structured-context value that branches (ternary, `and`/`or` picking a value) → report:
  "LOGGER BUSINESS LOGIC: <file>:<line> — compute `<key>` in a variable before passing it".
  Plain attribute access (`order.pk`, `customer.id`) is fine and is not a finding.

## Own function call buried in an expression
- A call to one of our functions (defined in the project's source root) used directly inside a bigger
  expression — chained, passed as an argument, returned inline — instead of first landing in its own
  variable → report: "BURIED CALL: <file>:<line> — assign `<call>` to a descriptive variable first".
  Exceptions, not findings: builtin constructors (`list(...)`, `set(...)`) around a variable,
  classmethods of our Enum classes, library or stdlib chains built from scratch, and the exceptions
  `code-rules.md` adds.

## Class member ordering
Members after fields, in this order:
1. properties (`@property`, `@cached_property`)
2. static methods
3. class methods
4. public instance methods
5. private methods (leading `_`)
6. framework hooks — dunder methods and overridden lifecycle methods
A new/changed member goes at the bottom of its own category block.
- A member added or moved in the diff out of place → report:
  "MEMBER ORDER: <file>:<line> — `<name>` is a <category>; move it to the end of the <category> block"

## Module-level function ordering
Public functions first, private (leading `_`) helpers below them.
- A private function above a public one → report:
  "MODULE FUNCTION ORDER: <file>:<line> — `<name>` is private; move it below the public functions"
<!-- /pack:python -->
