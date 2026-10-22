# Git

How commits, branches and pull requests are made. `<KEY>` is the task key from `issue-tracker.md`.

## Commits

```text
<KEY>-<number>: <type>: <description>
```

- English, imperative mood, the whole message ≤ 72 characters.
- Types: the table in `CONTRIBUTING.md` «Commit messages».
- <!-- fill: the hook that enforces the format, or «no hook». -->

## Branches

- Main branch: <!-- fill: master | main -->. The agent never pushes it: it stops and tells the user to do it.
- A batch of the ticket map gets the branch `<key>-<N>-<part>` (lowercase key). The agent pushes only that branch.

## Agent identity

The agent commits as Claude, so the developer's commits and the agent's stay apart:

```bash
git -c user.name=Claude -c user.email=noreply@anthropic.com commit -m "<message>" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Pull requests

<!-- fill: the host and how a pull request into the main branch is opened — CLI (`gh pr create`) or API call with
its URL, repository, headers and the env var holding the token (never printed). Title `<KEY>-N: <part>`, body: the
batch's tickets, one line each, ending with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`. -->

The call fails → report the pushed branch and ask the user to open the pull request.

## Review tags

The developer's review tags (`FIX:`, `NOTE:`, `TODO:`) are found with:

```bash
git grep -nwE "(FIX|NOTE|TODO):" -- . ':!.claude' ':!docs' ':!.ai' ':!CONTRIBUTING.md'
```

<!-- fill: the hook that rejects tags in commits and how the developer skips it, e.g.
`SKIP=no-review-comments git commit`. -->
