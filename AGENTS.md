# agent-kit

This repository is the kit, not a project that uses it. It holds generic agent skills and contract templates that
take a task from the tracker to a pull request. They grew out of real work and are meant to be reused across many
repositories. A project takes the skills it needs by `INDEX.md`, fills the contract `docs/agents/*.md` they read
and tailors its copy; edits good for every project come back here.

Everything here stays project-agnostic: a path, command, tracker name or stack rule of a specific project belongs in
that project's `docs/agents/`, a shared stack rule in `packs/`. Folder layout, placeholders (`{{p}}`, `{{KEY}}`) and
markers: `README.md` «How it works».

`INDEX.md` is the guide: which skills to take for which project, which work alone, which go as a set. A commit that
adds, removes or changes a skill updates it in the same commit.
