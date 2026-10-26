---
name: {{p}}-grill-one
description: Interview the user one question at a time to find gaps and contradictions in a plan, draft or idea. Use when the user asks for questions one by one or invokes /{{p}}-grill-one.
---

# Grill one

An **interview**: one question per message, then wait. The subject is the plan, draft or idea the user named; the
interview ends with a text the user and you both agree describes it.

## Opening

The first message asks only the language of the interview, written in the language of the user's request:

> На каком языке будем общаться? / Which language shall we use?
> - Русский
> - English
> - другой — напиши какой / another — name it

Every later message, the final text included, is in the chosen language. Then read the subject and everything it rests
on — files, git history, the tracker, the code — before the first real question.

## Every message

```text
Принято: <the user's previous answer, in their own words, one line>

---

### <topic of the question>

<one question>

- <option> — <what it leads to, one line>
```

- Exactly one question. The next topic waits for the next message.
- «Принято» quotes the user's wording as is; translate the label into the chosen language.
- Options only for a choice: 2–4 neutral ones, each with its consequence; none marked as yours. An open question goes
  without options.

## Order

Keep a private tree of open questions. Ask a question only when every question it depends on is answered: the
answers that shape the others come first. A fact the files, git, the tracker or the code can settle is looked up, not
asked; a looked-up fact that changes the picture goes into the next «Принято» line as «Нашёл: …».

## Recommendations

You stay neutral. Give a recommendation, with the reason, only when the user asks for it («а ты что думаешь», «что
рекомендуешь»); after the user asked for recommendations at the start, every choice carries one.

## Answers

The user's answer is final in their wording. An answer that contradicts an earlier one → name both, quoted, and ask
which one holds; that is the whole message.

## End

Done when the tree is empty: every assumption in the subject is backed by an answer or a looked-up fact, and no two
answers contradict each other. Then one line saying no gaps are left, and the final text in full, built from the
user's answers in their wording. Files stay untouched and nothing is acted on until the user confirms the text
matches what you both understand; a correction reopens the interview at that point.

_Last modified: 2026-10-26_
