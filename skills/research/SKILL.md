---
name: {{p}}-research
description: Write research.md for a tracker <KEY>-N task or an epic — requirements, the existing system, constraints, risks and open questions, enough for a justified plan or design. Use when the user asks to research a task, or when /{{p}}-create-plan routes a task to workflow 2 or 3.
---

# Research

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Research gathers **enough confirmed information** for the next stage: the plan in workflow 2, the design in workflow 3
(`CONTRIBUTING.md` «Classify a task before code»). It establishes what is; deciding how the system should change is
the next stage's work.

## Where it lives

- A task: `{{work}}/tasks/<key>-<N>-<short-kebab-description>/research.md` — the folder of
  `/{{p}}-create-plan` «Where it lives»; reuse it if it exists.
- An epic: `{{work}}/epics/<epic-slug>/research.md`, the folder of `docs/agents/issue-tracker.md` «Working files».

An epic is research for a whole initiative (a new project, a marketplace integration, a move to another framework):
the user names it an epic, or the request clearly spans several tracker tasks. Unsure → ask the user: task or epic.

## Route

The route comes from `CONTRIBUTING.md` «Classify a task before code»: from `/{{p}}-create-plan` when it sent the task
here, else classify now. Workflow 1 needs no research: say so and hand over to `/{{p}}-create-plan`.

## Sources

- The tracker issue `<KEY>-N` (or the epic) via the tracker tools of `docs/agents/issue-tracker.md`: Problem and Goal.
- Sibling issues in the same epic: titles, full text only for the ones that look adjacent.
- The behaviour spec of `docs/agents/product.md` «Behaviour spec», `CONTEXT.md` for domain terms, `docs/adr/` for
  decisions constraining the area.
- The code: `/{{p}}-recon` with the task and the requirements gathered so far.
- The developer, through the interview below.

## Steps

1. **Requirements.** Workflow 3, an epic, or a workflow 2 task whose Goal leaves the wanted behaviour open → invoke
   `/{{p}}-brainstorm` (`docs/agents/harness.md` «Actions») with the task, its tracker text and what you read so far.
   Its agreed text is the requirements. A workflow 2 task with clear behaviour skips the interview. Done when the
   requirements cover goals, non-goals and the cases the developer named.
2. **Existing system.** Run `/{{p}}-recon` for every area the requirements reach. A new project with no code → the
   existing system is the product requirements and the systems it connects to. Done when every area the
   requirements name has its current behaviour, its constraints and its usages listed, or is marked as absent.
3. **As-is diagrams.** A structure that is easier to see than to read (models and their links, a chain of calls, a
   status flow) → draw it as it is now, per `.agents/skills/{{p}}-create-design/diagrams.md`. Optional.
4. **Write `research.md`** in the format below.
5. **Check the route.** A finding shows that behaviour, a mechanism, a contract or an interaction has to be defined →
   workflow 3: name the finding and ask the user (`docs/agents/harness.md` «Actions») to confirm the switch.
6. **Done check.** Read the document as the next stage will: every question the plan or design needs answered is a
   confirmed finding or an open question with who answers it. A gap the code or the sources settle → go back to
   step 2 for it. Questions meant for the design may stay open.
7. Copy the document to the tracker (`docs/agents/issue-tracker.md` «Document copies»).
8. Hand over the path and the next skill: workflow 2 → `/{{p}}-create-plan`, workflow 3 → `/{{p}}-create-design`.

## research.md

One document for the developer and the agent. It reads top-down: the summary alone carries the state.

```markdown
# <KEY>-N: Research

Task: <tracker link>
Version: <N>

Question: <what the research answers, one sentence>

## Summary

- <what is established>
- Decisions left: <what the plan or design has to decide>
- Route: <workflow 2 holds | workflow 3 — the behaviour, mechanism, contract or interaction to define>
- Critical risks: <risk → consequence>

## Requirements

- <goal, non-goal or case> — <the developer | the tracker | the spec>

## Key findings

Confirmed:

- <fact> — `file:line` | <number, query, log line>

Hypotheses:

- <claim> — <what confirms or refutes it>

## Open questions

- <question> — <who answers: the design, the developer, the business, a check>

## Evidence

- <sources read: files, queries, logs, measurements>
- <as-is diagrams, when drawn>
```

- An epic: the title is `# <epic name>: Research`, `Task:` links the epic in the tracker.
- **Requirements** — only with step 1 run; the developer's wording kept.
- **Confirmed** holds facts read this session in code, data or logs, or stated by the developer; everything else is a
  hypothesis.
- A rejected option is a confirmed finding: the option and the fact that rules it out. What the eventual change won't
  cover goes there too.
- The document records results, in the order a reader needs them; the order of the search stays in the chat.
- **Version** starts at 1 and rises with each rewrite after a copy went to the tracker.

Bullets + `file:line`, not an essay. English; UI texts verbatim; wrap at 120 characters, code blocks, tables and URLs
unbroken. The chat with the user stays in the user's language.

_Last modified: 2026-11-08_
