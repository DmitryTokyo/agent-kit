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
- The **task branch** is named after the task folder: `.ai/tasks/<key>-<N>-<slug>/` → `<key>-<N>-<slug>` (lowercase
  key). A task whose ticket map has several parts gets one branch per part instead, `<key>-<N>-<part>`. One branch is
  one pull request. The agent pushes only these branches.
- Getting onto the branch before the first edit: already on it → continue; on the main branch →
  `git pull --ff-only && git switch -c <branch>`; the branch exists → `git switch <branch>`; on another task's branch →
  stop and ask the user.

## Agent identity

The agent commits under its harness's identity, `docs/agents/harness.md` «Agent identity», so the developer's commits
and the agent's stay apart.

## Pull requests

<!-- fill: the host and how a pull request into the main branch is opened — CLI (`gh pr create`) or API call with
its URL, repository, headers and the env var holding the token (never printed). Title `<KEY>-N: <part>`, body: the
batch's tickets, one line each, ending with the footer of `harness.md` «Agent identity» when the harness has one. -->

The call fails → report the pushed branch and ask the user to open the pull request.

## Review tags

The developer's review tags (`FIX:`, `NOTE:`, `TODO:`) are found with:

```bash
git grep -nwE "(FIX|NOTE|TODO):" -- . ':!.agents' ':!.claude' ':!docs' ':!.ai' ':!CONTRIBUTING.md'
```

<!-- fill: the hook that rejects tags in commits and how the developer skips it, e.g.
`SKIP=no-review-comments git commit`. -->
