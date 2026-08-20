---
name: migrate-agents-md
description: Consolidate fragmented AI-agent instruction files (.copilot/*, .github/instructions/*, CLAUDE.md, copilot-instructions.md, .cursorrules, …) into a single canonical AGENTS.md with symlinked aliases. Tailored to Python-backend and Django+Vue projects with Sentry integration. Use when migrating legacy copilot instructions, setting up AGENTS.md from scratch, or normalizing agent guidance across tools. One-shot per repo — for ongoing drift detection use the companion skill `sync-agents-md`.
---

# Migrate agent instructions

Consolidate scattered AI-agent instruction files into one canonical `AGENTS.md` with symlinked aliases, plus a Sentry section. Designed for the project shapes the user usually works in.

Project type determines which section templates compose the file:

| Type | Stack | Sections |
| --- | --- | --- |
| `python-lib` | Bare Python library / scripts | `main` + `python` |
| `django` | Django backend only | `main` + `python` + `django` |
| `fastapi` | FastAPI service | `main` + `python` + `fastapi` |
| `django+vue` | Fullstack monorepo: Django backend + Vue frontend in `/vue/` (Inertia glue) | `main` + `python` + `django` + `typescript` + `vue` |
| `mcp` | MCP server (official `mcp` Python SDK; `MCPServer` class, Streamable HTTP transport, Starlette/ASGI) | `main` + `python` + `mcp` |
| `vue` | Vue/TS frontend only (no backend in this repo) | `main` + `typescript` + `vue` |
| `typescript` | Non-Vue TS project (React/Svelte/plain TS library) | `main` + `typescript` |
| `other` | Other | `main` only; adapt |

`main` is always present and holds high-level, framework-agnostic instructions. `python` covers Python-specific conventions shared across all Python projects; `django` / `fastapi` add framework-specific sections on top. `typescript` covers TypeScript-specific conventions shared across all TS projects (Vue, React, Svelte, plain TS); `vue` adds Vue+Quasar+Pinia+reactivity specifics on top of `typescript` — mirroring the `python` + `django` split. `mcp` is a self-contained framework section (a peer of `fastapi`, not a child) for MCP servers built with the `mcp` Python SDK (`MCPServer`; Starlette/ASGI under the hood). It includes the Django ORM + async guardrail when the server uses Django. For `vue`-only or `typescript`-only projects, do **not** include `python` / `django` / `fastapi` / `mcp`.

A Sentry section is always added: backend endpoint + frontend endpoint when both exist; backend-only when no TS frontend; **frontend-only when the backend lives in a separate repo** (this repo has no backend Sentry project).

## When to use

- User says "migrate copilot instructions", "consolidate agent files", "set up AGENTS.md", "normalize agent instructions".
- Repo has legacy/fragmented AI instruction files.
- Starting `AGENTS.md` from scratch for a Python or Django+Vue project.

## What belongs in AGENTS.md vs global skills

This is the key judgment call. Get it right.

**Project-specific truth → AGENTS.md (always loaded, repo-bound):**
- Stack list (high-level — backend / frontend / queue / DB / storage / observability)
- Non-negotiable rules the repo enforces and the agent would otherwise miss (e.g. "never edit shipped migrations", DRF vs native-views variant, async-route-blocking for FastAPI+Django ORM)
- Repo-specific commands, test markers, coverage config locations
- API versioning / response format contract for this repo
- Sentry org / project / region for this repo
- Anything that changes when you switch repos

**Do NOT include** directory-layout tables, "where new code goes" tables, or layering diagrams — the agent reads the repo for structure (consistency over novelty). These are zad-style scaffolding for public OSS repos, not your private repos.

**Cross-project reusable procedure/pattern → global skill (on-demand, cross-repo):**
- "How to write a Django model + migration" recipe
- "How to ship a release" playbook
- "How to set up Sentry in a fresh Vue app" tutorial
- Generic framework patterns not tied to one repo
- Anything that stays the same across all your repos — **only when it is a named, explicitly-invoked procedure** (a recipe you run on request: release playbook, model+migration recipe, setup tutorial)

**Rule of thumb:** if the fact changes when you switch repos → `AGENTS.md`. If the procedure stays the same across all your repos → global skill — **but only for named, explicitly-invoked procedures.** Guardrails and failure-mode rules ("never edit shipped migrations", "async route + sync ORM blocks the event loop", "no business logic in routers") stay in `AGENTS.md` regardless of cross-repo constancy, because they bind on every routine turn, not on explicit invocation. The cost of a wrong drop is broken code shipped.

**Niche domain deep-dives** (e.g. "form components library" spec, "vision_builder recipe") do not belong in `AGENTS.md` — they bloat every session. Put them in `docs/agent/<topic>.md` and reference with a one-line pointer from `AGENTS.md`. The agent reads them only when relevant.

## Inputs to gather before writing

Ask the user (or infer from the repo) before drafting:

1. **Project type** — `python-lib` / `django` / `fastapi` / `django+vue` / `mcp` / `vue` (frontend-only) / `other`.
2. **Backend framework** — confirm Django+DRF / Django + native views + Pydantic / FastAPI / MCP server (`mcp` Python SDK, `MCPServer`) / bare / **none** (frontend-only repo). Do not assume DRF — some Django projects in this org have removed DRF.
3. **MCP server?** — if the project exposes MCP tools, set type to `mcp` and include `mcp.md`.
4. **Frontend framework** — Vue 3 + Quasar + Inertia + Vite + TS (default when the frontend is server-rendered via Inertia) OR Vue 3 + Quasar standalone SPA/PWA (when the frontend is a separate repo, e.g. `tropela-app`). Other TS frameworks (React/Svelte/plain TS) → `typescript` type with no `vue.md`. Confirm which — it changes the `vue.md` layout section.
5. **Package managers** — Python: uv (preferred) / pip / poetry / hatch; Frontend: yarn (preferred) / npm / pnpm.
6. **Sentry endpoints** — backend DSN or project slug; frontend DSN or project slug. For frontend-only repos, list the frontend project only. For backend-only repos, list the backend project only. For fullstack same-repo projects, list both.
7. **Commit convention** — default Conventional Commits short form; confirm.
8. **Docstring style** — reST (Sphinx) / Google / NumPy / none; detect from existing code before keeping the reST section in `python.md` (frontend-only repos have no Python, so skip this question).

## Discovery

Find every existing AI-instruction file before writing:

```sh
find . -type f \( \
  -name "AGENTS.md" -o -name "CLAUDE.md" -o -name "copilot-instructions.md" \
  -o -name ".cursorrules" -o -name ".windsurfrules" -o -name "GEMINI.md" \
  -o -name ".aider.conf.md" -o -path "*/.copilot/*" -o -path "*/.github/instructions/*" \
\) -not -path "*/node_modules/*" -not -path "*/.venv/*" -not -path "*/.git/*"
```

Read each. Classify its content:
- **Repo-specific truth** → fold into `AGENTS.md`.
- **Generic pattern/procedure** → leave as external doc, or suggest moving to a global skill, or drop.
- **Niche deep-dive** → move to `docs/agent/<topic>.md`, reference from `AGENTS.md`.

## Build AGENTS.md

Compose from the templates in `templates/`:

1. Always include `templates/main.md` (header, core philosophy, code style, stack, commands `./run` rule, commit conventions, git workflow, testing pointer, Sentry pointer, niche docs pointer).
2. For any Python project type (`python-lib`, `django`, `fastapi`, `django+vue`, `mcp`): append `templates/python.md` (General/PEP 8, docstrings, commands, pytest AAA + test location/fixtures/coverage, **test-review workflow**, Ruff).
3. If the backend is Django: append `templates/django.md` (Fat-models-thin-views / ORM efficiency, migrations, API with DRF vs native-views+Pydantic variants, Django commands, Django test patterns: file-suffix conventions, permission-inheritance pattern, test class naming).
4. If the backend is FastAPI: append `templates/fastapi.md` (routers/dependencies, **Django ORM** (models, migrations, async-route-blocking rule), schemas, background tasks, settings, entrypoint, FastAPI commands).
5. If the project is an MCP server: append `templates/mcp.md` (tool definitions, **MCP tool docstrings written for the LLM not humans**, Django ORM + async guardrail when applicable, schemas, settings, entrypoint, MCP commands). `mcp.md` is a peer of `fastapi.md` — do **not** also include `fastapi.md` (MCP servers expose tools over the MCP protocol, not REST routers).
6. If the project has any TypeScript codebase (`django+vue`, `vue`, `typescript`): append `templates/typescript.md` (General/strict mode, style + yarn-default, vitest testing — test location/mocking/coverage + philosophy: black box / not-our-code / functionality-over-implementation / boundary testing).
7. If the frontend is Vue (`django+vue`, `vue`): append `templates/vue.md` **on top of** `typescript.md` (Stack, reactivity best practices, component structure, code organisation for testability, form components pointer, Vue commands, Vue-specific testing). In a `django+vue` monorepo, the Vue frontend lives in `/vue/` and follows `typescript`+`vue` rules independently — Django's only role re: the frontend is Inertia (rendering the right page component and providing props). (FastAPI / MCP backends do not ship Vue frontends in this organisation — do not combine `fastapi` or `mcp` with `vue`.)
8. Always append `templates/sentry.md`, filling in: backend + frontend endpoints when both exist in this repo; backend-only when no TS frontend; **frontend-only when the backend lives in a separate repo**. Keep the bug-fix workflow verbatim.

**Adapt every section to the actual repo.** Read `pyproject.toml` / `package.json` / settings / `urls.py` / `routers.py` / `run` script / CI workflows. Do not paste templates verbatim — tailor paths, commands, package manager, version pins, markers, per-file ignores.

**Target length:** 1–2k tokens is a **soft budget, not a cap.** Guardrails and failure-mode rules count as in-scope and must not be cut to hit the budget — the cost of a wrong drop is broken code shipped. Cut only true redundancy (a `Things to avoid` block that restates the section above it verbatim) and scaffolding (layout tables, layering diagrams):
- **Do not include a "Repo layout" or "Where new code goes" table.** These are zad-style scaffolding for public OSS repos where drive-by contributors don't know the layout. Your repos are private; you set up the structure and steer the model. The agent reads the repo for layout — consistency over novelty. Only keep a one-line pointer if a placement is genuinely non-obvious (e.g. a hidden `docs/agent/<topic>.md`).
- **Do not include layering diagrams or import-direction tables** unless the project enforces a non-obvious rule the agent would violate. "Push business logic into services" is a code-gen principle already in `main.md` → "Core philosophy" / "Code generation style" — do not repeat it at every level.
- Drop sections for domains the repo doesn't have (no `tasks/` → drop the queue block; no S3 → drop the storage line).
- Avoid restating config already in `pyproject.toml` / `package.json` — point at it instead of duplicating.
- Each rule lives at its **most specific** level only — no rule in two files. `main.md` = cross-cutting; `python`/`typescript` = language-level; `django`/`fastapi`/`vue`/`mcp` = framework-level. Framework sections point at the language/main section for the generic rule rather than restating it.

## Create symlinks

From repo root:

```sh
ln -s AGENTS.md CLAUDE.md
ln -s ../AGENTS.md .github/copilot-instructions.md
```

Optional aliases (only if the user actually uses these tools):

```sh
ln -s AGENTS.md .cursorrules
ln -s AGENTS.md .windsurfrules
ln -s AGENTS.md GEMINI.md
```

Codex reads `AGENTS.md` natively — never alias it.

Verify the symlinks resolve:

```sh
ls -l CLAUDE.md .github/copilot-instructions.md
head -3 CLAUDE.md
```

## Cleanup

- Remove empty `.copilot/` and `.github/instructions/` dirs if no longer used.
- Repoint any in-repo markdown links that referenced deleted `.copilot/*` files to `AGENTS.md` (or fold their content in).
- Update `.gitignore`: drop `.copilot/` and `.github/instructions/` entries if fully migrated.
- Leave `.vscode/` gitignored.

## Final validation

Before handing back, scan the new `AGENTS.md` for accidentally leaked secrets. It is repo-bound — if the repo is public, a Sentry DSN or AWS key there is exposed.

```sh
grep -inE "dsn|token|secret|api[_-]?key|password|sk-|AKIA|xox|SECRET_KEY|AWS_ACCESS|AWS_SECRET|mysql://|redis://|smtp_pass|MAILGUN_KEY|BEGIN.*PRIVATE" AGENTS.md
```

Sentry org slug, region URL, and project slugs are **not** secrets (they require auth to access) — safe to keep. DSN strings, API keys, tokens, passwords are **secrets** — remove them. If the Sentry section uses DSN values instead of project slugs, replace with slugs and keep the DSN out of the file.

## Done

The build + symlink-verify + cleanup + secrets-scan steps above are the whole job. No separate checklist file.