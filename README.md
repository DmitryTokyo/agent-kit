# agent-kit

Skill core for Claude Code projects: task → plan → tickets → orchestrator → TDD → review → commit.

Status: skills are project-neutral; `bootstrap` and `sync` are not written yet.

- `skills/` — the skills; every project fact comes from `docs/agents/*.md`
- `contract/` — templates of `docs/agents/*.md`, `<!-- fill: ... -->` marks what a project fills in
- `packs/` — stack rules (`python`, `django`) merged into `code-rules.md`, `hygiene.md`, `testing.md`
- `repo/` — repository wiring: `CONTRIBUTING.md` sections, `CLAUDE.md` snippet, `.claude/settings.json`, pre-commit hooks
- `examples/tg-sales-bot/` — a filled contract; empty `<!-- pack:NAME -->` pairs stand for the pack's text

## Placeholders and markers

| Mark | Where | Replaced by |
| --- | --- | --- |
| `{{p}}` | skills, contract, repo | the skill prefix, chosen per project |
| `{{KEY}}`, `{{key}}`, `{{main}}` | repo | the task key, its lowercase form, the main branch |
| `<KEY>`, `<key>` | skills | stays: read from `docs/agents/issue-tracker.md` at run time |
| `<!-- pack:NAME -->…<!-- /pack:NAME -->` | contract files | the pack's text |
| `<!-- module:NAME -->…<!-- /module:NAME -->` | contract, repo | kept or removed with the optional module (`business-questions`, `codegraph`) |
