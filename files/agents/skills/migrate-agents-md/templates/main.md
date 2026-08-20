# Agent guidance for [PROJECT_NAME]

This file is the canonical source of truth for AI coding agents working in this repo.
[ALIASES: `CLAUDE.md` and `.github/copilot-instructions.md` are symlinks to this file.]

## Core philosophy

- **Proactive collaboration**: do not blindly follow instructions. If a request is ambiguous, overly complex, or risky, challenge it and suggest a better alternative.
- **Maintainability first**: prioritise code that is easy to read, understand, and modify.
- **Simplicity (KISS & YAGNI)**: favour the most straightforward solution. Do not add functionality that has not been explicitly requested.
- **Consistency over novelty**: follow existing codebase conventions. Only introduce new patterns when clearly justified.

## Code generation style

- **Self-documenting code**: clear, unabbreviated names. Decompose into single-purpose functions. Use type hints.
- **Strategic commenting**: avoid comments explaining _what_ code does. Only comment _why_ when not obvious.
- **Testability**: write code that is easy to test. Prefer pure functions and clear interfaces.

## Stack

[ADAPT: list the project's actual stack. The language/framework sections appended below own the detail; keep this high-level.]

- **Backend**: [e.g. Django 6 + DRF, Python 3.14, managed with uv. — OR FastAPI / MCP server (`mcp` Python SDK, `MCPServer`) / bare library / none (frontend-only).]
- **Frontend**: [e.g. Vue 3 + Quasar + Inertia.js + Vite + TypeScript, managed with yarn 4 (see `vue/`). — OR none.]
- **Background jobs**: [e.g. huey (`<app>/tasks/`), Redis-backed. — OR drop line.]
- **DB**: [e.g. MySQL in production, SQLite (`dev.db`) in dev. — OR none.]
- **Storage**: [e.g. S3 via django-storages + boto3. — OR drop line.]
- **Observability**: Sentry SDK[, Anymail/Mailgun or Resend for email, Cloudflare in front].

## Commands

[ADAPT: keep only the line below if a `./run` wrapper exists. Framework-specific commands (dev server, migrations, build, lint) live in the framework sections appended below — do not list them here.]

If a `./run` wrapper exists, **all project commands must be prefixed with `./run`** — it loads `.env` and invokes the underlying tool (`uv run`, `yarn`, etc.). Do not call `uv` / `pytest` / `python manage.py` / `yarn` directly.

## Commit conventions

[ADAPT: confirm. Default below.]

Conventional Commits. Short form: `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`, `test: ...`, `chore: ...`, `perf: ...`.
Optional scope: `type(scope): description` (e.g. `fix(api): handle missing race id`).
Imperative mood, lowercase, no trailing period.
Breaking change: `feat!: ...` or a `BREAKING CHANGE:` footer.
Never use vague messages like `wip` or `update`.

## Git workflow

[ADAPT or DROP if the project does not enforce this.]

- Always branch from `main`. Never branch from another feature branch.
- Branch naming: `type/short-description` in kebab-case (`feat/results-import`, `fix/ranking-tiebreak`, `chore/update-deps`).
- Open a PR as soon as the branch has meaningful work — draft PRs are fine.
- The PR title becomes the squash-merge commit, so write it as a conventional commit.
- One PR per logical change — do not bundle unrelated fixes.

## Testing

[Testing conventions are language-specific — do not duplicate them here. See `python.md` → "Testing (pytest)" and `typescript.md` → "Testing (vitest)". Framework-specific test patterns (Django markers / permission-inheritance, Vue composables) live in the framework sections.]

## Error monitoring (Sentry)

[SEE `templates/sentry.md`. Always include a Sentry section. Drop only if the project genuinely has no Sentry integration.]

## Niche domain docs

[OPTIONAL: one-line pointers to deep-dives that would bloat this file. Drop section if none. Prefer `docs/agent/<topic>.md` or `docs/<topic>.md` over inline. Add one bullet per actual repo-specific deep-dive (e.g. `- Form components library: vue/src/components/forms/README.md`); do not leave placeholder or example bullets in the generated file.]
