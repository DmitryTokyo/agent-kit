# Harness

Skills name roles, tiers and actions, never a harness's tools or models. This file maps them for every harness the
project runs in. Read the section for the harness you run in; a harness without a section is not mapped yet — stop
and tell the user.

## Roles

- **worker** — subagent that writes code or tests. Starts with fresh context, never a fork of the caller.
- **explorer** — read-only subagent that searches or checks code and reports.
- **reviewer** — subagent that runs one independent review. Several reviewers start in one message.
- **continue a worker** — send a follow-up to a running subagent without losing its context.

A subagent prompt that points at a skill file reads: *"Read `<path>` and follow it for `<input>`. You are the
subagent — do not spawn anything, you cannot talk to the user."*

## Agent definitions

`.agents/agents/` holds named subagent definitions: a role with its fixed prompt, its allowed tools and its tier in one
file, so a prompt several skills dispatch lives once and a harness can limit its tools and pin its model. The kit's
skills carry their prompts inline and need none, so the folder may stay empty. A project that moves a skill's prompt
into a definition dispatches it by name; each harness below says where it reads them.

## Tiers

- **strong** — the strongest model: dispatchers and reviews that decide.
- **standard** — workers that write code or tests.
- **cheap** — mechanical steps: commits, scans, summaries.

A skill that needs the main agent on a tier says so; on another tier the agent stops and tells the user to switch.

## Actions

- **ask the user** — print the question with everything it needs (lists, tables, the preview) as a plain message and
  end the turn. The user's reply answers it. A short choice with no content to show may use the harness's question
  tool.
- **invoke a skill** — a skill names another as `/<name>`; the mapping below says how to load it. A skill that is not
  found stops the work: say which one is missing and where it was expected; never skip the step or retell the skill
  from memory.

## Agent identity

The agent commits under its harness's name, so the developer's commits and each agent's stay apart. The mapping below
gives the author and trailer per harness. Never strip them.

<!-- harness:claude-code -->
## Claude Code

- worker: `Agent(subagent_type="general-purpose")` with the tier's model. Never `fork`.
- explorer: `Agent(subagent_type="Explore")`.
- reviewer: `Agent(subagent_type="general-purpose")`.
- continue a worker: `SendMessage` to it.
- tiers: strong — `opus`, standard — `sonnet`, cheap — `haiku`; the main agent switches with `/model`.
- ask the user: the plain message. `AskUserQuestion` hides the text printed before it in the desktop app, so it never
  carries content.
- invoke a skill: `/<name>`, or the `Skill` tool. Shared skills are linked into `~/.claude/skills/` and
  `~/.agents/skills/`; a project's own skills live in `.agents/skills/`, read through the `.claude/skills` symlink.
- agent definitions: `.claude/agents` → symlink to `../.agents/agents`; dispatch one with
  `Agent(subagent_type="<name>")`.
- identity: `git -c user.name=Claude -c user.email=noreply@anthropic.com commit -m "<message>" -m "Co-Authored-By:
  Claude <noreply@anthropic.com>"`. A pull request body ends with
  `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- permissions: `.claude/settings.json`.
<!-- /harness:claude-code -->

<!-- harness:opencode -->
## OpenCode

- worker: `subagent({agent: "general", prompt: "..."})`.
- explorer: `subagent({agent: "explore", prompt: "..."})`.
- reviewer: `subagent({agent: "general", prompt: "..."})`, one independent call each, in one message.
- continue a worker: the same `subagent` call with the `sessionID` it returned.
- tiers: <!-- fill: the model of each tier, or «the session's model» when the project does not split them -->.
- ask the user: the plain message; the `question` tool for a short choice.
- invoke a skill: the `skill` tool by ID; `/<name>` in a skill is the ID `<name>`. There are no slash commands for
  skills: the user loads one by `@<name>` in the prompt. OpenCode reads shared skills from `~/.agents/skills/` and the
  project's from `.agents/skills/`; two skills of one ID: the one from `.agents/skills/` wins over `.claude/skills/`.
  The skill's file list may come back empty through a symlink: read a neighbouring file by its path.
- identity: <!-- fill: author and trailer, e.g. `git -c user.name=OpenCode -c user.email=<email> commit ...` -->.
- agent definitions: `.opencode/agents/<id>.md` or `~/.config/opencode/agents/<id>.md` with `mode: subagent`; its
  `model: provider/model` pins the tier, without it the subagent inherits the caller's model. Dispatch by
  `subagent({agent: "<id>", ...})`. <!-- fill: the project's definitions, or «none» -->.
- permissions: `.opencode/opencode.json`. A skill reads a neighbouring skill's file by path outside the repository:
  keep `external_directory` open for `~/.agents/skills/**`. OpenCode V2 reads `AGENTS.md` only, never `CLAUDE.md`.
<!-- /harness:opencode -->

<!-- harness:codex -->
## Codex

Codex reads `AGENTS.md` natively and the skills in `~/.agents/skills/` (shared) and `.agents/skills/` (the project's).

- worker: `spawn_agent` with the task prompt and the tier's model.
- explorer: `spawn_agent` with a read-only task.
- reviewer: `spawn_agent`, one per review, all spawned before the first `wait_agent`.
- continue a worker: `send_input` to it; `wait_agent` collects the result.
- tiers: <!-- fill: the model of each tier; `agents.default_subagent_model` in `.codex/config.toml` sets the default -->.
- ask the user: the plain message.
- invoke a skill: `$<name>`; `/<name>` in a skill is `$<name>`.
- identity: <!-- fill: author and trailer, e.g. `git -c user.name=Codex -c user.email=<email> commit ...` -->.
- agent definitions: <!-- fill: where Codex reads them, or «none» -->.
- permissions: `.codex/rules/default.rules`, denies as `prefix_rule(pattern = [...], decision = "forbidden")`; it
  loads only when the project's `.codex/` is trusted.
<!-- /harness:codex -->
