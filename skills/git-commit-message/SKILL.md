---
name: ag-git-commit-message
description: Review this repository's git changes, split them into logical chunks, propose AG-N commit messages, and stage and commit only after explicit approval. Use for commit-message or local-commit requests in tg-sales-bot.
---

# Git commit messages

Propose one commit per logical chunk of the current diff, then stage and create local commits after the user approves. Never push.

## 1. Get the task number

An `AG-<number>` already in the conversation (any case: `AG-5`, `ag-5`) → use it, skip this step.

Otherwise collect candidates from `git log -20 --oneline`, `git branch --show-current`, and `.ai/tasks/ag-*` folder names. Ask with `AskUserQuestion` (header `Задача`, single-select):

- question: `Какой номер задачи?`
- one option per candidate
- fewer than 2 candidates → add an explicit `Другой номер` option

Inspect no changes before the answer.

## 2. Inspect the changes

`git diff --stat HEAD`; if empty, `git diff --cached --stat`. Read the full diff when the stat does not reveal intent. The user asked for staged changes only → use the `--cached` variants.

## 3. Group

- Self-contained chunks derived from the diff; invent no behaviour.
- Prefer chunks under about 300 changed lines, without fragmenting one atomic change.
- A chunk that finishes a ticket in `.ai/tasks/ag-N-*/tickets/` is one commit.

## 4. Draft messages

```text
AG-123: type: Short concrete description
```

- Type from the table in `CONTRIBUTING.md`, chosen by you from the diff.
- English, imperative mood, whole message ≤ 72 characters.
- Domain concepts in `CONTEXT.md` vocabulary. A new domain concept not in the glossary → mention it after the messages.
- Mixed changes → say so, then list each chunk with its file scope and message.
- No explanation unless asked.

The `commit-msg` hook enforces this format; validate every message against it before asking.

## 5. Confirm

Print the commits as a plain message, ask `Названия коммитов подходят?` in its last line, and end the turn;
`AskUserQuestion` hides both the text before it and its option `preview` in the desktop app. The user's reply approves
them or corrects them. The message lists every proposed commit, numbered, each as its full message on one line and its
file scope on the next:

  ```text
  1. AG-123: feat: Add consent screen
     tg_sales_bot/bot/handlers/consent.py, tg_sales_bot/bot/keyboards.py
  2. AG-123: test: Cover consent service
     tg_sales_bot/customers/tests/unit/test_consent.py
  ```

A list missing any message is broken — rebuild it before printing.

A correction → revise and print the list again. A reply that neither approves nor corrects → leave the worktree unchanged.

## 6. Commit

After confirmation, per chunk in order:

```bash
git add <files for this chunk>
git commit -m "AG-123: type: message"
```

One `git add` + `git commit` pair per chunk; nothing staged before step 5. Never `git push`. Report the commits and their file scope.

_Last modified: 2026-10-18_
