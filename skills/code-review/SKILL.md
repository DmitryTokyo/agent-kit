---
name: {{p}}-code-review
description: "Review a batch of the ticket map (<KEY>-N <part>) or a diff since a fixed point (commit, branch, HEAD~N) on two axes, Standards (this repo's rules) and Spec (the task's plan), then set the affected scope, checks and review level. Use when the user asks to review a branch, commits, or work in progress."
---

# Code review

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

Two-axis review, each axis in its own reviewer. Reports stay separate: no merging, no reranking across axes. The
review is a file a fixer in another session works from; this skill fixes no code.

## 1. Pin the fixed point

`<KEY>-N <part>` → a **batch**: the section of `{{work}}/tasks/<key>-N-*/tickets/00-map.md` for that part (the first section
with an unticked `Agent review` when no part is given; older maps: `Ревью агентом`). Base: the parent of the first
commit hash in its ticket lines; diff: `git diff <base> <last hash>`. A ticket line without a hash → stop: the batch is
unfinished.

Otherwise take the fixed point from the user; if none given, ask.

- Base: `git merge-base <fixed-point> HEAD`.
- Diff: `git diff <base>` (includes uncommitted changes).
- Commits: `git log <base>..HEAD --oneline`.
- Untracked: `git ls-files --others --exclude-standard` — `git diff` omits them; include the relevant new source files.

**Done when:** the ref resolves and the diff or the untracked list is non-empty. Stop here otherwise.

## 2. Find the spec

1. Task key `<KEY>-N` from commit prefixes, or from the user. No key → ask the user and wait; never skip the spec.
2. Task folder `{{work}}/tasks/<key>-N-*/` (case-insensitive): `plan.md`, `agent.md`, `research.md`, `tickets/*.md`, and
   the latest review file of this scope (step 7) — the previous round, if any.
3. The tracker issue `<KEY>-N` via the tracker tools of `docs/agents/issue-tracker.md`: Problem and Goal. Older tasks
   carry `## Decisions` and acceptance criteria there: they are part of the spec.
4. The behaviour spec — the sections for the screens the diff touches.

No `plan.md` → the spec is the tracker issue alone; say so in the review. Where an older issue's `## Decisions` and
`plan.md` disagree, the issue wins: report the gap, never bend the code toward the plan.

## 3. Collect standards sources

- `AGENTS.md` (Guardrails)
- `docs/adr/` — the ADRs touching the changed areas
- `docs/agents/code-rules.md`
- `docs/agents/hygiene.md`
- `.agents/skills/{{p}}-test-writer/rules.md` and `docs/agents/testing.md` — for changed test files

Plus the smell baseline below. Repo rules override it; each smell is a judgement call, labelled "possible <smell>".

- **Mysterious Name**: name doesn't reveal what it does or holds → rename.
- **Duplicated Code**: same logic shape in several hunks/files → extract, call from both.
- **Feature Envy**: method uses another object's data more than its own → move it there.
- **Data Clumps**: same fields/params travel together → bundle into a dataclass or model.
- **Primitive Obsession**: primitive stands in for a domain concept → give it a type or enum.
- **Repeated Switches**: same `if`-cascade on the same type recurs → one shared map or polymorphism.
- **Shotgun Surgery**: one logical change scatters edits across many files → gather into one module.
- **Divergent Change**: one module edited for unrelated reasons → split by reason.
- **Speculative Generality**: params, hooks, abstractions the spec doesn't need → inline back.
- **Message Chains**: long `a.b().c().d()` navigation → hide behind one method.
- **Middle Man**: class/function that only delegates → call the target directly.
- **Refused Bequest**: subclass ignores most of what it inherits → composition.

## 4. Previous round

With a previous round, check it first: every `[x]` item verified in the code — holds → closed; does not → reopened
under its ID. Every unticked item carries over under its ID, its `decision` kept.

## 5. Spawn both reviewers

A reviewer (`docs/agents/harness.md` «Roles») per axis, in one message. Both prompts also carry:

> You are read-only: change no file and spawn nothing. End with «Declined to judge»: what you considered and set aside
> as outside this axis, one line each with the reason.

**Spec prompt** carries: diff command, commit list, untracked files, spec file paths, the tracker issue text, and:

> Report (a) `plan.md` Result and Criteria missing or partial; (b) behaviour in the diff nobody asked for, or outside
> the plan's Boundaries (scope creep); (c) requirements implemented but looking wrong, including screens or texts
> that differ from the behaviour spec; (d) a finding from the plan's Stop conditions; (e) defects: an input or state
> that crashes or gives a wrong result, with that input or state. Mark each `hard` (a defect, a broken requirement or
> boundary) or `judgement` (a departure someone must decide on, or intent you cannot tell — phrase it as a question
> with the options). Quote the spec line for each. Under 400 words.

**Standards prompt** carries: diff command, commit list, untracked files, the standards file paths, the smell baseline
pasted in full, and:

> Report per file:line (a) every breach of a documented rule, citing file + rule — `hard`; (b) every baseline smell,
> named, with the hunk quoted — `judgement`; (c) every check of `docs/agents/hygiene.md` that fails on the changed
> files — `hard`. Skip what the linter autofixes. Under 400 words.

**Done when:** both reviewers have reported.

## 6. Scope, checks, level, criteria

Inline, from the diff and its callers:

1. **Consequences.** Each contract, side effect or property that changes or must stay unchanged, with who depends on
   it and the failure it could cause.
2. **Affected scope.** The changed module, its consumers and related components, plus one sentence on why that
   boundary is enough. Boundary uncertain → the scope is the full suite.
3. **Checks.** Per consequence, the check that can catch its failure: a unit test for isolated logic, `e2e` when
   components must work together, a static or artifact check for docs and config. Run the affected-scope tests
   (`unit` / `one-test` of `docs/agents/stack.md` «Commands»); the full suite runs in CI — read its result on the pull
   request when there is one. A consequence whose failure no check can catch is a `hard` finding: name the missing test.
4. **Review level.** Start from `plan.md` «Developer review»: `no` → Agent; `yes` → Focused. Raise to Full when risk
   is High or the diff reaches past the plan's Boundaries. Focused and Full name the exact `file:line` ranges or
   decisions the developer must read.
5. **Criteria.** Check each `plan.md` «Criteria» item against the diff. Holds → tick it `[x]` in `plan.md`. Fails or
   unverifiable → leave it unticked; it is a deviation.

**Done when:** every consequence has a check with its result, and every criterion is ticked or listed as a deviation.

## 7. Write the review file

The scope's review file is `{{work}}/tasks/<key>-N-*/reviews/<BB>-<part>-review-NN.md` for a batch, `reviews/review-NN.md`
otherwise; `NN` is one past the latest round of that scope (`01` for the first). The file is self-contained: a fixer in
another session reads only it. IDs stay stable across rounds: `SPEC-n`, `STD-n`, numbering continues from the previous
round.

```markdown
# <KEY>-N review NN

Task: <tracker link>
Base: `<base>` · Commits: `<first>..<last>`
<"No plan.md — checked against the tracker issue only." — when there is no plan>

Fixer: fix every open item that is `hard` or `decision: fix`. Tick it `[x]` and add one `fixed:` line saying what
changed. Leave `decision: ?` and `decision: skip` items untouched.

## Previous round
- SPEC-1 closed · STD-2 reopened: <why>

## Spec
- [ ] **SPEC-3** hard · `path/file.py:42` — <problem>. Spec: "<quoted line>" → <fix direction>

## Standards
- [ ] **STD-4** judgement · decision: ? · `path/file.py:58` — possible <smell>: <problem> → <fix direction>

## Declined to judge
- Spec | Standards · <what> — <why it is outside the axis>

## Review level
<Agent | Focused | Full> — <why, against the diff>
- `path/file.py:40-75` — <what the developer must decide or confirm>

## Affected scope
<modules and consumers> — <why this boundary is enough>

## Consequences
- <consequence> → <check> → <passed | failed | CI pending>

## Deviations
- <unticked criterion or departure from the plan> — <why>
```

Omit «Previous round» on round 01, «Declined to judge» and «Deviations» when there are none. An empty axis keeps its heading with «none».

The developer answers a `judgement` item by setting its `decision` to `fix` or `skip` in the file; work that should
happen later is `skip` plus a tracker task. A batch with no open `hard` item and no `decision: ?` left → tick
`Agent review` in the map.

In chat: the file path, findings count per axis, the worst finding within each axis, the review level, and the next
step — the developer sets the decisions, then `/{{p}}-develop` with the review file.

_Last modified: 2026-11-08_
