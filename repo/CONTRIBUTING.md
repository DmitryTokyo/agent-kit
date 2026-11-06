## Commit messages

Every commit message uses this format:

```text
{{KEY}}-<number>: <type>: <description>
```

Write the description in English, imperative mood, and keep the whole message
to 72 characters or fewer.

| Type | Use for |
| --- | --- |
| `feat` | New functionality |
| `fix` | Bug fixes |
| `refactor` | Code changes without behaviour changes |
| `test` | Adding or changing tests |
| `docs` | Documentation |
| `chore` | Other technical maintenance, configuration, or tools |
| `build` | Build system or dependency changes |
| `ci` | CI/CD changes |
| `perf` | Performance improvements |
| `style` | Formatting, linting, or whitespace without logic changes |

Examples:

```text
{{KEY}}-1: feat: Add product catalog
{{KEY}}-1: fix: Handle expired payment link
{{KEY}}-1: docs: Document local setup
{{KEY}}-1: chore: Configure pre-commit
```

## Classify a task before code

Before any plan, the task gets a classification and a route. The agent proposes them from the task and a first look
at the code; the developer confirms. Deciding the route needs only enough code reading to answer the questions below,
not a solution.

### Three axes

Each axis is independent: Work Type implies neither value nor risk.

- **Product Value** — `Core` (the product's unique value), `Supporting` (backs Core up), `Generic` (every product has
  it; no direct value, not the same as simple).
- **Work Type** — `Feature`, `Bug`, `Refactoring` (structure changes, behaviour does not), `Engineering` (reliability,
  quality, technical properties), `Infrastructure` (deploy, operations), `Maintenance` (planned upkeep).
- **Engineering Risk** — `Low`, `Medium`, `High`: how bad a mistake would be. Weigh four factors, in this order:
  impact, blast radius (components and users reached), complexity, change size. A one-line auth condition is `High`.
  Risk is preliminary and rises when new dependencies or consequences surface.

| Example | Product Value | Work Type | Risk |
| --- | --- | --- | --- |
| Add a payment provider | Core | Feature | High |
| Fix a wrong total in the cart | Core | Bug | Medium |
| Add an export to the admin | Supporting | Feature | Medium |
| Replace a loading spinner | Generic | Feature | Low |
| Rework the deploy pipeline | Generic | Infrastructure | High |

### First look at the code

1. Is there a confirmed pattern for this change (an analogous change, or a confirmed bug cause)?
2. Does it apply without changing contracts, behaviour rules or interactions?
3. Which scenarios, components and states does the change reach?
4. Which consequences are unknown, and what checks the result?

"Only one line changes" is a claim to confirm in the code. Unknown boundaries → research.

### Route

| Workflow | When | Work |
| --- | --- | --- |
| 1. Known local solution | Pattern or cause confirmed, boundaries clear, no new rules or interactions | plan → change → checks → review |
| 2. Research and plan | Behaviour is clear; affected places or consequences are not | research → plan → change → checks → review |
| 3. Research, design and plan | Behaviour, a mechanism, a contract or an interaction has to be defined | research → design → plan → change → checks → review |

Check depth follows risk, not the size of the change. A new dependency, a pattern that does not fit, or rising risk
sends the task back to route selection. Workflow 3 has no skill support yet.

Delivery: workflow 1 lands as commits without ticket files; workflow 2 may split into tickets.

### Plan

The developer reads one short `plan.md` and approves it before code: classification, route, result, criteria,
boundaries, checks, stop conditions and whether the developer reviews the change. Checks are approved there, once;
development returns to the developer only on a deviation from the plan. The tracker task holds only Problem, Goal and
Links, plus its status and labels.

## Feature workflow

A feature is a task in the tracker (`docs/agents/issue-tracker.md`). Its working files live in `{{work}}/tasks/{{key}}-N-<slug>/`.

1. `/{{p}}-create-task` — the task in the tracker: Problem, Goal, Links.
2. `/{{p}}-create-plan` — classification and route («Classify a task before code»), `research.md` for workflow 2,
   then the developer plan `plan.md` and the agent instruction `agent.md`. `Delivery: commits` → `/{{p}}-develop`;
   `Delivery: tickets` → step 3.
3. `/{{p}}-to-tickets` — tickets and their map `tickets/00-map.md`: one ticket is one commit of at most 100 lines of
   production code. Each line of the plan's `Checks` lands in one ticket and sets its mode. A section of the map is a
   batch: a part's development tickets, its E2E ticket and its gates — agent review always, developer review when the
   plan says so, manual check when the plan has `manual` checks. A part has at most 6 development tickets and is one
   pull request; a bigger part is split in two, each named after what it delivers (`checkout-map`, `pickup-step`), not
   numbered.
4. `/{{p}}-orchestrate {{KEY}}-N` — the first batch of the map with an unticked ticket, once the batches it follows have every
   gate ticked; each ticket goes through the skill of its `Mode`. The developer is asked only about deviations from the
   approved checks; subagents write the tests, the code and review them; each ticket is committed on its own and ticked
   in the map. The batch lives on its branch (see «Branches and pull requests»); nothing is pushed. One ticket alone:
   `/{{p}}-tdd-develop {{KEY}}-N <ID>` or `/{{p}}-develop` with the ticket path — left uncommitted for the developer's
   `git diff`.
5. `/{{p}}-code-review {{KEY}}-N <part>` (or with a fixed point when there is no map) in a new session, another model
   welcome — the review file in `{{work}}/tasks/{{key}}-N-<slug>/reviews/`, see «Code review». The developer sets the
   decisions, `/{{p}}-develop` with the review file fixes them and ticks `Agent review`.
6. `/{{p}}-merge-request` — pushes the branch and opens the pull request: risk, review level, deviations,
   consequences → checks → results, criteria, the plan.
7. The developer's review on the pull request, when the plan's `Developer review` is `yes` — comments on lines of the
   diff; `/{{p}}-merge-request` works the chosen threads, commits the round as one commit, pushes and replies in each
   thread. The developer resolves threads and ticks the gate.
8. The check ticket, when the part has one — every case clicked in the product. A failed case becomes a new ticket of
   the batch. The developer ticks the gate and merges; the next batch is free to start.
9. After the merge, `/{{p}}-close-merge-request` links the pull request in the tracker task, moves it to Done and its
   folder to `{{work}}/done/` once every part is merged, updates `{{main}}` and deletes the local branch.

## Branches and pull requests

- A task works on one branch named after its folder, `{{key}}-N-<slug>`, and one pull request into `{{main}}`. A ticket
  map with several parts gets one branch `{{key}}-N-<part>` and one pull request per part instead. The developer merges.
- The agent never pushes `{{main}}`: it stops and asks the developer to do it. Each harness's permission file
  (`docs/agents/harness.md`) denies those commands. Only the task or part branch is pushed.
- Whose change is whose is read from the history: the agent commits under its harness's identity
  (`docs/agents/harness.md` «Agent identity»), the developer as themself. Pull requests are opened under the
  developer's account.

## Code review

The agent review (`/{{p}}-code-review`) writes one English file per round,
`{{work}}/tasks/{{key}}-N-<slug>/reviews/<BB>-<part>-review-NN.md` for a batch or `reviews/review-NN.md` otherwise. Each
finding has a stable ID (`SPEC-n` for the plan and the task, `STD-n` for the code rules) and is either:

- `hard` — a defect, a broken requirement, boundary or documented rule; always fixed;
- `judgement` — a smell or a departure someone must decide on; the developer sets `decision: fix` or `decision: skip`
  in the file. Work for later is `skip` plus a tracker task.

The file also sets the review level — Agent (no developer review), Focused (the named `file:line` ranges) or Full —
the affected scope, every consequence with the check that catches it, and the deviations from the plan.

The developer reviews on the pull request, as comments on lines of the diff. Any change beyond a review round (about
30 lines, another screen or another task) becomes a ticket or a tracker task.
