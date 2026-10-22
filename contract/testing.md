# Testing

The project's testing stack and conventions. `/{{p}}-test-writer`'s `rules.md` applies the general rules; this file
adds what is specific to the stack and the project, and wins where they disagree. Pack sections sit between
`<!-- pack:NAME -->` markers.

## Stack

<!-- fill: test runner, plugins, where settings come from. -->

## STOP conditions

<!-- fill: project stops on top of the general ones, e.g. «the E2E harness lacks an action», «the database from
`.env` is unreachable — mocking the ORM is not a workaround». -->

## Running

<!-- fill: how to run one level or one app, and what must not run in parallel. -->

## Database

<!-- fill: markers, how objects are created, what is read through the ORM. «none» without a database. -->

## Mocks

<!-- fill: the process boundary — which external services are mocked, and nothing else. -->

## File placement

<!-- fill: where unit tests, E2E scenarios, fixtures, factories and test constants live; the file naming rule. -->

## E2E scenarios

<!-- fill: the harness, how an actor acts, what is asserted, what a scenario cannot see. «none» without E2E. -->

## Reference tests

<!-- fill: the existing tests to match the style of, one line each. -->
