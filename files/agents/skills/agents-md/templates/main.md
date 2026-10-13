# Agent guidance for [PROJECT_NAME]

Canonical source of truth for AI coding agents in this repo. [ALIASES: `CLAUDE.md` and `.github/copilot-instructions.md` are symlinks to this file.]

## Core philosophy

- Challenge ambiguous, complex, or risky requests; suggest better alternative. Don't follow blindly.
- Maintainability first; KISS & YAGNI; consistency over novelty; self-documenting code, type hints everywhere, comments only for non-obvious _why_.

## Stack

[ADAPT: project's actual stack, one line each, only lines that apply. Framework sections below own detail.]

- **Backend**: [Django 6 + DRF / FastAPI / MCP server (`mcp` SDK, `MCPServer`) / bare / none (frontend-only).]
- **Frontend**: [Vue 3 + Quasar + Vite + TypeScript, yarn 4 — OR none.]
- **Jobs / DB / Storage / Observability**: [one line each; drop lines that don't apply.]

## Commands

All project commands via `./run` (loads `.env`, invokes underlying tool). Never call `uv` / `pytest` / `yarn` directly. [ADAPT: drop if no wrapper. No command lists or code blocks anywhere in `AGENTS.md` — agents read `run` / `pyproject.toml` / `package.json` / `Procfile`. Only a rule about a command (a pre-commit gate, a "never run X") earns a line.]

## Commit conventions

Conventional Commits: `type(scope): description` — imperative, lowercase, no trailing period, one line, no attribution trailers. Types: `feat` / `fix` / `docs` / `refactor` / `test` / `chore` / `perf`. Breaking: `feat!:` / `BREAKING CHANGE:` footer. Never vague (`wip`, `update`).

## Git workflow

[Self-contained on purpose: teammates / Copilot don't see the global policy. ADAPT: name concrete paths only where this repo extends a category, e.g. "all of `config/settings/`, not only security settings".]

- Branch + PR for sensitive areas — auth / login / sessions, permissions / access control, serializers / API schemas, payments / billing, security settings / secrets handling, CI workflows (`.github/workflows/`) — or when in doubt. Decide before the first commit; a direct-to-`main` change that grows into a sensitive area moves to a branch before committing.
- Everything else (copy, styling, docs, tests, isolated bug fixes, dependency bumps) may go straight to `main`.
- Branch `type/short-description` from `main`; PR title in Conventional Commits form (becomes the squash commit). Never merge your own PR; leave it for review.
- This decides _where_ commits go, not _whether_: commit / push / open PRs only when asked.

## Specs

`openspec/specs/` is source of truth for behaviour; spec-driven changes via OpenSpec (`openspec/changes/`). [Always include. If no `openspec/` dir, suggest `openspec init --tools none` first. If `openspec/config.yaml` has `store: <id>`, use instead: "Shared OpenSpec store `<id>` (`openspec context` for path): specs + changes live there, not in this repo."]

## Testing

[Language-specific — see `python.md` / `typescript.md`. Framework patterns in framework sections; no duplication here.]

## Error monitoring (Sentry)

[From `templates/sentry.md`. Always include unless no Sentry integration.]

## Niche domain docs

[OPTIONAL: one-line pointers to `docs/agent/<topic>.md` deep-dives, one bullet per real deep-dive; drop section if none.]
