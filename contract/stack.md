# Stack

What the code is built with and the commands every skill runs. The skills name a command by its key from «Commands»
(`check`, `unit`, …) and never spell it out.

## Stack

<!-- fill: one line — language, framework, database, queue, the Channel or UI. -->

## Layout

<!-- fill: where the code lives — the source root, its packages or apps and what each holds, settings, the test
directories. A few lines; the code rules hold the details. -->

## Commands

| Key | Command | Runs |
| --- | --- | --- |
| `check` | <!-- fill --> | linters, type checker, schema check; must pass before a change is reported done |
| `unit` | <!-- fill --> | every unit test |
| `e2e` | <!-- fill, or «none» --> | every E2E scenario |
| `one-test` | <!-- fill: with `{file}` and `{test}` placeholders --> | one test or one file |
| `migrate` | <!-- fill, or «none» --> | creates the schema migration after a model change |

<!-- fill: anything a command needs before it runs (services, env vars), one line each. -->

## Line count

Production lines of a ticket are counted without these paths:

```text
<!-- fill: git pathspecs, e.g. ':!**/tests/**' ':!**/migrations/**' -->
```

Test lines are counted over these paths:

```text
<!-- fill: e.g. '**/tests/**' -->
```
