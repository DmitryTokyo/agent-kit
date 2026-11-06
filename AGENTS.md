# agent-kit

This repository is the kit, not a project that uses it. It holds generic agent skills and contract templates that
take a task from the tracker to a pull request. They grew out of real work and are meant to be reused across many
repositories. `skills/bootstrap` installs the kit into a project: it renders the skills with the project's prefix and
fills the contract `docs/agents/*.md` with the project's facts. The project then tailors its copy, and `skills/sync`
sends the generic edits back here and brings the kit's updates into the project.

Everything here stays project-agnostic: a path, command, tracker name or stack rule of a specific project belongs in
that project's `docs/agents/`, a shared stack rule in `packs/`. Folder layout, placeholders (`{{p}}`, `{{KEY}}`) and
markers: `README.md` «How it works».
