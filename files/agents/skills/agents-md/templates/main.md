# Agent guidance for [PROJECT_NAME]

Canonical source of truth for AI coding agents in this repo. [ALIASES: `CLAUDE.md` and `.github/copilot-instructions.md` are symlinks to this file.]

## Core philosophy

- Challenge ambiguous, overly complex, or risky requests; suggest better alternative. Don't follow blindly.
- Maintainability first; KISS & YAGNI — no unrequested functionality; consistency over novelty.
- Self-documenting code, type hints everywhere, comments only for non-obvious _why_.

## Stack

[ADAPT: project's actual stack, one line each, only lines that apply. Framework sections below own detail.]

- **Backend**: [Django 6 + DRF / FastAPI / MCP server (`mcp` SDK, `MCPServer`) / bare / none (frontend-only).]
- **Frontend**: [Vue 3 + Quasar + Vite + TypeScript, yarn 4 — OR none.]
- **Jobs / DB / Storage / Observability**: [one line each; drop lines that don't apply.]

## Commands

All project commands via `./run` — loads `.env`, invokes underlying tool. Never call `uv` / `pytest` / `yarn` directly. [ADAPT: drop if no wrapper. Framework commands live in framework sections.]

## Commit conventions

Conventional Commits: `type(scope): description` — imperative, lowercase, no trailing period, one line, no attribution trailers. Types: `feat` / `fix` / `docs` / `refactor` / `test` / `chore` / `perf`. Breaking: `feat!:` or `BREAKING CHANGE:` footer. Never vague (`wip`, `update`).

## Git workflow

PR required (branch + review) for: [ADAPT: this repo's real sensitive paths only, e.g. `accounts/`, `*/permissions.py`, `*/api/serializers.py` or `*/schemas.py`, `payments/`, `config/settings/`, `.github/workflows/`]. Everything else may go straight to `main`. [Tiered policy lives in global guidance — don't restate it. Keep the path list: teammates / Copilot don't see the global file.]

## Specs

`openspec/specs/` is source of truth for behaviour; spec-driven changes via OpenSpec (`openspec/changes/`). [Always include. If no `openspec/` dir, suggest `openspec init --tools none` first. If `openspec/config.yaml` has `store: <id>`, use instead: "Shared OpenSpec store `<id>` (`openspec context` for path): specs + changes live there, not in this repo."]

## Testing

[Language-specific — see `python.md` / `typescript.md`. Framework patterns in framework sections; no duplication here.]

## Error monitoring (Sentry)

[From `templates/sentry.md`. Always include unless no Sentry integration.]

## Niche domain docs

[OPTIONAL: one-line pointers to `docs/agent/<topic>.md` deep-dives, one bullet per real deep-dive; drop section if none.]
