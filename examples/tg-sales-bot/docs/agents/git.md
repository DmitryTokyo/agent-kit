# Git

How commits, branches and pull requests are made. `<KEY>` is the task key from `issue-tracker.md`.

## Commits

```text
<KEY>-<number>: <type>: <description>
```

- English, imperative mood, the whole message ≤ 72 characters.
- Types: the table in `CONTRIBUTING.md` «Commit messages».
- The `commit-message-ticket` pre-commit hook (`commit-msg` stage) enforces the format.

## Branches

- Main branch: `master`. The agent never pushes it: it stops and tells the user to do it.
- A batch of the ticket map gets the branch `<key>-<N>-<part>` (lowercase key). The agent pushes only that branch.

## Agent identity

The agent commits as Claude, so the developer's commits and the agent's stay apart:

```bash
git -c user.name=Claude -c user.email=noreply@anthropic.com commit -m "<message>" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Pull requests

GitVerse API: `https://api.gitverse.ru`, repository `AURA_PACIFIC/sales_tg_bot`, header
`Accept: application/vnd.gitverse.object+json;version=1`, token from `$GITVERSE_TOKEN` — never print it.
`POST /repos/AURA_PACIFIC/sales_tg_bot/pulls` with `head`, `base: master`, the title `<KEY>-N: <part>` and a body of
the batch's tickets, one line each, ending with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
The pull request is opened under the developer's account; the agent's commits are told apart by their author.

The call fails → report the pushed branch and ask the user to open the pull request.

## Review tags

The developer's review tags (`FIX:`, `NOTE:`, `TODO:`) are found with:

```bash
git grep -nwE "(FIX|NOTE|TODO):" -- . ':!.claude' ':!docs' ':!.ai' ':!CONTRIBUTING.md'
```

The `no-review-comments` pre-commit hook rejects them in every commit; the developer commits their tags with
`SKIP=no-review-comments git commit`.
