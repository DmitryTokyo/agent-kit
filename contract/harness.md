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

## Tiers

- **strong** — the strongest model: dispatchers and reviews that decide.
- **standard** — workers that write code or tests.
- **cheap** — mechanical steps: commits, scans, summaries.

A skill that needs the main agent on a tier says so; on another tier the agent stops and tells the user to switch.

## Actions

- **ask the user** — print the question with everything it needs (lists, tables, the preview) as a plain message and
  end the turn. The user's reply answers it. A short choice with no content to show may use the harness's question
  tool.
- **invoke a skill** — a skill names another as `/<name>`; the mapping below says how to load it.

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
- invoke a skill: `/<name>`, or the `Skill` tool. Skills live in `.agents/skills/`, read through the
  `.claude/skills` symlink.
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
  skills.
- identity: <!-- fill: author and trailer, e.g. `git -c user.name=OpenCode -c user.email=<email> commit ...` -->.
- permissions: `.opencode/opencode.json`.
<!-- /harness:opencode -->

<!-- harness:pi -->
## pi

pi loads agent definitions from `~/.pi/agent/agents/`, `.pi/agents/` and `.agents/agents/`.

- worker: `Agent(subagent_type="worker")`. Never hand two workers the same file.
- explorer: `Agent(subagent_type="scout")`.
- reviewer: `Agent(subagent_type="reviewer")`.
- continue a worker: not available — a subagent returns one final report. Re-dispatch with that report pasted into
  the new task.
- tiers: the main agent runs on the session's model; <!-- fill: per-agent models, or «one model» -->.
- ask the user: the plain message.
- invoke a skill: <!-- fill -->.
- identity: <!-- fill: author and trailer -->.
<!-- /harness:pi -->
