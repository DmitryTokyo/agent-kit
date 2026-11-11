---
name: {{p}}-close-merge-request
description: "Close a task after the user merged its pull request: link it in the tracker task, move the task to Done and its folder to {{work}}/done/, update the main branch, delete the local branch. Use when the user says the PR or MR is merged, or asks to close it or the task."
---

# Close merge request

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form. Every call to the
host is an operation of `docs/agents/git.md` «Pull requests», run as that table says. A token never reaches the
command line or the chat.

1. `git status --porcelain` is not empty → stop and name the changes.
2. Pick the branches:
   - the current branch is a task or part branch of `docs/agents/git.md` «Branches» → this branch, its task folder
     `{{work}}/tasks/<key>-N-*/`;
   - on the main branch → every branch listed in a `pr.md` of `{{work}}/tasks/*/`;
   - nothing found → ask the user (`docs/agents/harness.md` «Actions») for the task or the pull request link.
3. Per branch, its pull request is the line of `pr.md`. No line → «find the merged pull request of a branch»; nothing
   found → ask the user for the link.
4. Read its state. Anything but `merged` → skip the branch, report its state.
5. The branch is a part of the ticket map and its section has gates the user has not ticked → skip the branch, name
   the gates.
6. Update the tracker task `<KEY>-N` through the tools of `docs/agents/issue-tracker.md`: append `- PR: <link>` to its
   `Links` section (no section → add one at the end), the rest unchanged. The task is **finished** when it has no
   ticket map, or every section of the map has its branch merged → move it to the Done status of
   `issue-tracker.md` «Conventions».
7. `git switch <main> && git pull --ff-only`, then `git branch -D <branch>` for each merged branch that exists locally:
   after a squash or rebase merge git does not see it as merged, the host's state above is the check. A remote branch
   still on the host stays; name it in the report.
8. A finished task → `mkdir -p {{work}}/done && mv {{work}}/tasks/<folder> {{work}}/done/`. Its `plan.md` names an
   `Epic: <epic-slug>` → move the epic's link to the folder along with it:

   ```bash
   ln -sfn ../../../done/<folder> {{work}}/epics/<epic-slug>/tasks/<folder>
   ```

   Every task of the epic's `roadmap.md` has a link in `{{work}}/epics/<epic-slug>/tasks/` and every link points into
   `done/` → the epic is finished: move it to
   `{{work}}/done/epics/<epic-slug>/`, point each of its links at `../../../<folder>` (`done/` from there), and move the
   epic in the tracker to its finished state.
9. Report per task: the key, the pull request links, what was done, the epic when one moved or finished. List
   skipped branches with the reason.

_Last modified: 2026-11-11_
