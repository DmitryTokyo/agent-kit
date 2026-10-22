---
name: {{p}}-code-review
description: "Review a batch of the ticket map (<KEY>-N <part>) or a diff since a fixed point (commit, branch, HEAD~N) on two axes: Standards (this repo's rules) and Spec (the tracker task it implements). Use when the user asks to review a branch, commits, or work in progress in tg-sales-bot, or says their own review is done and the tags in the code need handling."
---

# Code review

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

The behaviour spec is the document `docs/agents/product.md` «Behaviour spec» names. Actors: `docs/agents/product.md` «Actors».

Two-axis review, each axis in its own parallel sub-agent. Every finding carries a review tag — `FIX`, `NOTE` or `TODO`
— with the meaning of the table in `CONTRIBUTING.md` «Code review», the same tags the developer writes.

## 0. Developer review tags

Run the review-tags command of `docs/agents/git.md` «Review tags».

- Any hit is the developer's own review (`CONTRIBUTING.md` «Code review»): read
  `.claude/skills/{{p}}-review-comments/SKILL.md` and follow it in place of steps 1–5. Its output ends this skill.
- No hits → step 1.

## 1. Pin the fixed point

`<KEY>-N <part>` → a **batch**: the section of `.ai/tasks/<key>-N-*/tickets/00-map.md` for that part (the first section
with an unticked `Ревью агентом` when no part is given). Base: the parent of the first commit hash in its ticket
lines; diff: `git diff <base> <last hash>`. A ticket line without a hash → stop: the batch is unfinished.

Otherwise take the fixed point from the user; if none given, ask.

- Base: `git merge-base <fixed-point> HEAD`.
- Diff: `git diff <base>` (includes uncommitted changes).
- Commits: `git log <base>..HEAD --oneline`.

**Done when:** the ref resolves and the diff is non-empty. Stop here otherwise.

## 2. Find the spec

1. task key `<KEY>-N` from commit prefixes, or from the user.
2. tracker issue `<KEY>-N` via the tracker tools of `docs/agents/issue-tracker.md`.
3. Task folder `.ai/tasks/<key>-N-*/` (case-insensitive): `research.md`, `plan.md`, `tickets/*.md`.
4. the behaviour spec — the sections for the screens the diff touches.

The tracker issue is required: no key → ask the user for it, and wait. The issue has no `## Decisions` → the Spec
sub-agent checks against the plan alone; say so in the report.

## 3. Collect standards sources

- `CLAUDE.md`, `AGENTS.md` (Guardrails)
- `docs/adr/` — the ADRs touching the changed apps
- `docs/agents/code-rules.md`
- `docs/agents/hygiene.md`
- `.claude/skills/{{p}}-test-writer/rules.md` and `docs/agents/testing.md` — for changed test files

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

## 4. Spawn both sub-agents in parallel

`Agent(subagent_type="general-purpose")` for each, in one message.

**Standards prompt** carries: diff command, commit list, the standards file paths, the smell baseline pasted in full, and:

> Report per file:line (a) every breach of a documented rule, citing file + rule — `FIX`; (b) every baseline smell,
> named, with the hunk quoted — `TODO`. Skip what the linter autofixes. Under 400 words.

**Spec prompt** carries: diff command, commit list, spec file paths, the tracker issue text, and:

> Report (a) requirements missing or partial; (b) behaviour in the diff nobody asked for (scope creep);
> (c) requirements implemented but looking wrong, including screens or texts that differ from the behaviour spec;
> (d) behaviour that departs from the issue's `## Decisions`; (e) defects: an input or state that crashes or gives a
> wrong result, with that input or state. Tag each: a defect or a requirement broken for an actor —
> `FIX`; a departure from the spec someone must decide on, or intent you cannot tell — `NOTE`, phrased as a question
> with the options. Where the issue and plan.md disagree, the issue wins: report the gap, never bend the code toward
> plan.md. Quote the spec line for each. Under 400 words.

## 5. Aggregate

The review is in English: it is for the agent that works it. Open with the tracker issue link, and «no `## Decisions`,
checked against the plan only» when the issue has none. Then the findings grouped by tag, both axes together, numbered
straight through all three groups (1, 2, 3 …), each with its axis:

```markdown
## FIX
- [ ] 1. `<file:line>` — <what is wrong, citing the rule or spec line> → <what to do> (Standards | Spec)

## NOTE
- [ ] 2. `<file:line>` — <question>; options: <…> (Spec)

## TODO
- [ ] 3. `<file:line>` — possible <smell> → <what to do> (Standards)
```

An empty tag keeps its heading with «none». End with one line: the count per tag and the worst `FIX`.

Report only. Fix nothing without the user's go-ahead.

A batch → the report goes to `.ai/tasks/<key>-N-*/reviews/<BB>-<part>.md`, so `/{{p}}-develop` can work it without this
session. No findings → tick `Ревью агентом` in the map; the digest is skipped.

## 6. Digest

The **digest** is the developer's copy: Russian, plain words, answered in place. Spawn
`Agent(subagent_type="general-purpose", model="haiku")` with the review path and:

> Write `<review path without .md>.ru.md`: one numbered item per finding, the same numbers, no checkboxes, no file
> paths and no rule citations. Each item: a bold one-line gist; «Что видно:» — what an actor or the
> code does now, in plain words; «Варианты:» — each option with what it leads to, then «Рекомендую: <N>»; a FIX gets
> one option, the fix; «Ответ:» left empty. Open with the batch name and «Ответь под каждым пунктом. На TODO:
> делать / отложить / пропустить; можно одной строкой на все TODO.»

**Done when:** the digest has every number of the review. In chat: the digest path, the count per tag and every `FIX`
gist in one line each. The next step is `/{{p}}-develop` with the review file once the digest is answered.

_Last modified: 2026-10-20_
