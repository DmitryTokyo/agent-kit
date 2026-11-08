---
name: {{p}}-brainstorm
description: Open interview that finds out what the developer wants and why — goals, non-goals, cases, likes and dislikes, questions they have not thought of — before anything is designed. Use when the user wants to brainstorm a task or an idea, or when /{{p}}-research needs the requirements.
---

# Brainstorm

An **interview** that widens the picture: what the developer wants, why, and what they have not thought of yet. It
ends with an agreed text of the requirements; the caller writes it into its document. Narrowing the picture into
decisions is `/{{p}}-grill-one`'s work, later, on the design.

## Look before you ask

Before the first question read the subject and what it rests on: the tracker task, the files and the code the
caller passed, the behaviour spec of `docs/agents/product.md`, `CONTEXT.md`. A fact these settle is never asked; a
looked-up fact that changes the picture goes into the next message as «Нашёл: …».

## Every message

One open question in the developer's own terms, then end the turn. Say what the answer changes about the result,
when that is not plain.

- **Until the why is known, questions are open**: no options, no example answers. The developer's own words carry
  intent that options steer away.
- Once the why is known, a choice with nameable answers gets 2–4 options sketched concretely, each with its
  trade-off, and your pick with the reason.
- Build each question on the last answer or on something you found: a consequence, an edge case, a user the request
  leaves out («в старом дашборде фильтр по дате сохраняется между визитами — в новом тоже?»).
- «Не знаю», «на твоё усмотрение» → propose a concrete answer with the reason; it stands as your proposal until the
  developer accepts it.

The chat is in the user's language.

## Ground to cover

Territory, not a script: never read it out as a list of questions.

- what this is and who it serves; why now, what success looks like;
- goals, non-goals, and anti-goals: what would make it a failure even if it technically works;
- the current state: what exists, what was tried, what the developer likes and dislikes in it;
- prior art: what they have seen elsewhere, loved or hated;
- the cases and details they care about; the cases they have not mentioned and the change reaches.

## Play it back

As soon as one part is clear (who it serves, how one piece behaves), describe it back in 100–200 words, then return to
questions about the next part. Only what the developer said goes in as theirs; what you filled in is marked as your
proposal with its reason. Each playback ends with «что не так или чего не хватает?».

## End

Done when the ground is covered, every playback is confirmed, and a builder could state the goals, non-goals and the
cases without asking the developer again. Then the final text in full:

```markdown
Goal: <why, in the developer's words>

- Goal: <...>
- Non-goal: <...>
- Anti-goal: <...>
- Case: <situation → what should happen>
- Proposal: <what you filled in, with the reason> — accepted
```

Files stay untouched: the caller writes the text. A correction reopens the interview at that point.

_Last modified: 2026-11-08_
