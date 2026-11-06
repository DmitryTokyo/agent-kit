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
- The **task branch** is named after the task folder: `{{work}}/tasks/<key>-<N>-<slug>/` → `<key>-<N>-<slug>` (lowercase
  key). A task whose ticket map has several parts gets one branch per part instead, `<key>-<N>-<part>`. One branch is
  one pull request. The agent pushes only these branches.
- Getting onto the branch before the first edit: already on it → continue; on the main branch →
  `git pull --ff-only && git switch -c <branch>`; the branch exists → `git switch <branch>`; on another task's branch →
  stop and ask the user.

## Agent identity

The agent commits under its harness's identity, `docs/agents/harness.md` «Agent identity», so the developer's commits
and the agent's stay apart.

## Pull requests

Host: <!-- fill: GitHub | GitLab | …, the repository -->. Every call goes through <!-- fill: `gh` | a wrapper script
that adds the token inside its own process (the token is never printed) -->. `/{{p}}-merge-request` and
`/{{p}}-close-merge-request` run these operations by name:

| Operation | Command |
| --- | --- |
| find the open pull request of a branch | <!-- fill, e.g. `gh pr list --head <branch> --json number,url` --> |
| open a pull request | <!-- fill, e.g. `gh pr create --base <main> --head <branch> --title <title> --body-file <file>`; on GitLab with `remove_source_branch` --> |
| update its description | <!-- fill, e.g. `gh pr edit <number> --body-file <file>` --> |
| list unresolved review threads | <!-- fill: each with its id, file, line and first comment --> |
| reply in a thread | <!-- fill --> |
| read its state (open, merged) | <!-- fill, e.g. `gh pr view <number> --json state` --> |
| find the merged pull request of a branch | <!-- fill, e.g. `gh pr list --head <branch> --state merged --json number,url` --> |

Title `<KEY>-N: <title from plan.md>`; a part's pull request adds ` — <part>`. The body ends with the footer of
`harness.md` «Agent identity» when the harness has one. A call fails → report the pushed branch and ask the user to
open the pull request.
