---
name: agents-md
description: >
    Create or maintain a repo's canonical AGENTS.md (with CLAUDE.md /
    .github/copilot-instructions.md symlinks). Auto-detects mode — composes
    AGENTS.md from templates when none exists (Create mode); when it exists,
    fixes template and config drift in place, keeping existing wording
    (Sync mode; `--dry-run` report only, `--deep` adds Sentry / source checks).
    Tailored to Python-backend and Django+Vue projects with Sentry integration.
    Use when setting up AGENTS.md from scratch, checking or updating it
    ("sync", "rebuild", "regenerate"), or after template / dependency / config changes.
---

# AGENTS.md

One skill for the whole lifecycle of a repo's `AGENTS.md`: write it when missing, keep it honest once it exists.

## Determine mode

Check whether `AGENTS.md` exists at the repo root.

- **Missing → Create mode**: compose a new `AGENTS.md` from templates.
- **Exists → Sync mode** (also for "rebuild", "regenerate", "check", "update"): fix template + config drift
  in place. Never recompose an existing file from scratch.

---

## Create mode

Project type determines which section templates compose the file:

| Type         | Stack                                                                     | Sections                                            |
| ------------ | ------------------------------------------------------------------------- | --------------------------------------------------- |
| `python-lib` | Bare Python library / scripts                                             | `main` + `python`                                   |
| `django`     | Django backend only                                                       | `main` + `python` + `django`                        |
| `fastapi`    | FastAPI service                                                           | `main` + `python` + `fastapi`                       |
| `django+vue` | Fullstack monorepo: Django backend + Vue frontend in `/vue/`              | `main` + `python` + `django` + `typescript` + `vue` |
| `mcp`        | MCP server (official `mcp` Python SDK; `MCPServer` class, Starlette/ASGI) | `main` + `python` + `mcp`                           |
| `vue`        | Vue/TS frontend only (no backend in this repo)                            | `main` + `typescript` + `vue`                       |
| `typescript` | Non-Vue TS project (React/Svelte/plain TS library)                        | `main` + `typescript`                               |
| `other`      | Other                                                                     | `main` only; adapt                                  |

`main` is always present and holds high-level, framework-agnostic instructions. `python` covers Python-specific conventions shared across all Python projects; `django` / `fastapi` add framework-specific sections on top. `typescript` covers TypeScript-specific conventions shared across all TS projects (Vue, React, Svelte, plain TS); `vue` adds Vue+Quasar+Pinia+reactivity specifics on top of `typescript` — mirroring the `python` + `django` split. `mcp` is a self-contained framework section (a peer of `fastapi`, not a child) for MCP servers built with the `mcp` Python SDK (`MCPServer`; Starlette/ASGI under the hood). It includes the Django ORM + async guardrail when the server uses Django. For `vue`-only or `typescript`-only projects, do **not** include `python` / `django` / `fastapi` / `mcp`.

A Sentry section is always added: backend endpoint + frontend endpoint when both exist; backend-only when no TS frontend; **frontend-only when the backend lives in a separate repo**.

### When to use Create mode

- User says "set up AGENTS.md", "write AGENTS.md for this repo", "normalize agent instructions".
- Repo has no `AGENTS.md` yet — a fresh repo, or one that still carries scattered legacy AI-instruction files (`.copilot/*`, `.github/instructions/*`, `.cursorrules`, `copilot-instructions.md`, …) from a boilerplate/template.

### What belongs in AGENTS.md vs global skills

- **Repo-specific truth → `AGENTS.md`:** stack list, non-negotiable rules ("never edit shipped migrations", async-route-blocking for FastAPI+Django ORM), command rules (`./run`, pre-commit gate) / test markers with usage rules / config locations, API contract, Sentry slugs — anything that changes when you switch repos. Guardrails stay here regardless of cross-repo constancy: they bind on every routine turn.
- **Named, explicitly-invoked procedures → global skill:** release playbook, model+migration recipe, setup tutorial. Patterns that are merely cross-repo-constant are not skills — they're knowledge the model already has.
- **Niche domain deep-dives → `docs/agent/<topic>.md`**, one-line pointer from `AGENTS.md`.
- **Cross-repo agent workflow (OpenSpec usage, risk-tiered branch/PR policy) → global `~/.claude/CLAUDE.md`** (`files/agents/AGENTS.md` in dotfiles). Repo `AGENTS.md` carries only the one-line `## Specs` pointer and a one-line, self-contained `## Git workflow` summary — sensitive-area categories + in-doubt→branch + direct-to-`main` otherwise — because teammates / Copilot don't see the global file. Name concrete paths only for repo-specific extensions the categories don't cover; never restate specs, OpenSpec workflow steps, or the full tiered policy.

### Inputs to gather before writing

Ask the user (or infer from the repo) before drafting:

1. **Project type** — `python-lib` / `django` / `fastapi` / `django+vue` / `mcp` / `vue` (frontend-only) / `other`.
2. **Backend framework** — confirm Django+DRF / Django + native views + Pydantic / FastAPI / MCP server (`mcp` Python SDK, `MCPServer`) / bare / **none** (frontend-only repo). Do not assume DRF — some Django projects in this org have removed DRF.
3. **MCP server?** — if the project exposes MCP tools, set type to `mcp` and include `mcp.md`.
4. **Frontend framework** — Vue 3 + Quasar + Inertia + Vite + TS (default when the frontend is server-rendered via Inertia) OR Vue 3 + Quasar standalone SPA/PWA (when the frontend is a separate repo, e.g. `tropela-app`). Other TS frameworks (React/Svelte/plain TS) → `typescript` type with no `vue.md`. Confirm which — it changes the `vue.md` layout section.
5. **Package managers** — Python: uv (preferred) / pip / poetry / hatch; Frontend: yarn (preferred) / npm / pnpm.
6. **Sentry endpoints** — backend DSN or project slug; frontend DSN or project slug. For frontend-only repos, list the frontend project only. For backend-only repos, list the backend project only. For fullstack same-repo projects, list both.
7. **Commit convention** — default Conventional Commits short form; confirm.
8. **Git workflow summary** — default one-liner from `main.md` (sensitive-area categories: auth, permissions, serializers/schemas, payments, security settings, CI workflows → branch + PR; in doubt → branch; else direct to `main`). Name concrete paths only for repo-specific extensions the categories don't cover (e.g. a whole `settings/` dir, a bespoke billing module). Confirm with the user.
9. **Docstring style** — reST (Sphinx) / Google / NumPy / none; detect from existing code before keeping the reST section in `python.md` (frontend-only repos have no Python, so skip this question).
10. **OpenSpec** — if no `openspec/` dir, suggest `openspec init --tools none` (skills are already global; `--tools agents` only if teammates need them in-repo). Run it only after the user confirms. If `openspec/config.yaml` has `store: <id>`, the repo uses a shared store — use the store variant of `## Specs`.

### Legacy files (rare)

Most repos are already on `AGENTS.md`. Occasionally a fresh clone of a boilerplate still carries a stray legacy instruction file — check once and fold in anything repo-specific:

```sh
find . -type f \( \
  -name "CLAUDE.md" -o -name "copilot-instructions.md" \
  -o -name ".cursorrules" -o -name ".windsurfrules" -o -name "GEMINI.md" \
  -o -name ".aider.conf.md" -o -path "*/.copilot/*" -o -path "*/.github/instructions/*" \
\) -not -path "*/node_modules/*" -not -path "*/.venv/*" -not -path "*/.git/*"
```

Classify anything found:

- **Repo-specific truth** → fold into `AGENTS.md`.
- **Generic pattern/procedure** → leave as external doc, or suggest moving to a global skill, or drop.
- **Niche deep-dive** → move to `docs/agent/<topic>.md`, reference from `AGENTS.md`.

### Build AGENTS.md

Compose from the templates in `templates/`:

1. Always include `templates/main.md` (header, core philosophy, code style, stack, commands `./run` rule, commit conventions, git workflow one-liner (categories + repo extensions), specs pointer, testing pointer, Sentry pointer, niche docs pointer).
2. For any Python project type (`python-lib`, `django`, `fastapi`, `django+vue`, `mcp`): append `templates/python.md` (General/PEP 8, docstrings, Ruff pre-commit gate + `pyproject.toml` pointer, pytest test location/fixtures, **test-review workflow**).
3. If the backend is Django: append `templates/django.md` (Fat-models-thin-views / ORM efficiency, migrations, API with DRF vs native-views+Pydantic variants, Django test patterns: file-suffix conventions, permission-inheritance pattern, test class naming).
4. If the backend is FastAPI: append `templates/fastapi.md` (routers/dependencies, **Django ORM** (models, migrations, async-route-blocking rule), schemas, background tasks, settings, entrypoint).
5. If the project is an MCP server: append `templates/mcp.md` (tool definitions, **MCP tool docstrings written for the LLM not humans**, Django ORM + async guardrail when applicable, schemas, settings, entrypoint). `mcp.md` is a peer of `fastapi.md` — do **not** also include `fastapi.md` (MCP servers expose tools over the MCP protocol, not REST routers).
6. If the project has any TypeScript codebase (`django+vue`, `vue`, `typescript`): append `templates/typescript.md` (General/strict mode, style + yarn-default, vitest testing — test location/mocking/coverage as one-liners, testing philosophy compressed, **no worked examples**).
7. If the frontend is Vue (`django+vue`, `vue`): append `templates/vue.md` **on top of** `typescript.md` (Stack, reactivity best practices, component structure, code organisation for testability, form components pointer, Vue-specific testing). In a `django+vue` monorepo, the Vue frontend lives in `/vue/` and follows `typescript`+`vue` rules independently — Django's only role re: the frontend is Inertia (rendering the right page component and providing props). (FastAPI / MCP backends do not ship Vue frontends in this organisation — do not combine `fastapi` or `mcp` with `vue`.)
8. Always append `templates/sentry.md`, filling in: backend + frontend endpoints when both exist in this repo; backend-only when no TS frontend; **frontend-only when the backend lives in a separate repo**. Keep all bug-fix workflow steps.

**Adapt every section to the actual repo.** Read `pyproject.toml` / `package.json` / settings / `urls.py` / `routers.py` / `run` script / CI workflows. Do not paste templates verbatim — tailor paths, commands, package manager, version pins. Markers only when they carry a usage rule; never per-file ignores or other config values.

**Target length:** ~1.2k tokens for the composed file, ceiling ~1.5k where repo-specific content earns its place — **real tokenizer tokens** (measure with e.g. `uv run --with tiktoken python -c "import tiktoken; print(len(tiktoken.get_encoding('o200k_base').encode(open('AGENTS.md').read())))"`). Chars/4.2 heuristics undercount code-heavy markdown by ~25–30% (paths and `identifiers` split into several tokens). Every token is loaded into every session. Single-stack projects should land well under 1k; fullstack `django+vue` around 1–1.5k. If a section doesn't pull its weight, move the deep-dive to `docs/agent/<topic>.md` — never delete repo facts to save tokens. Guardrails and failure-mode rules are never cut for the budget — the cost of a wrong drop is broken code shipped. Readability beats squeezing: numbered procedures stay one step per line; don't merge list items to shave bytes.

**The relevance filter — what is actually worth an agent's context?** `AGENTS.md` exists for what the model cannot derive from training data: facts that change when you switch repos, and rules the repo would otherwise see violated. Generic framework craft (AAA tests, `shallowRef` for API data, mock-the-boundary, docstring syntax) is already known — at most one line per idea.

| Keep (repo-specific delta)                                                                                                                                                                                                                                                           | Compress to one line max (generic craft)                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `./run` wrapper rule, test locations / markers / naming, config file locations, Sentry slugs, commit format, git-workflow extension paths, migration rules, framework-variant contracts (DRF vs native views), shim notes ("no `@inertiajs/vue3` — local `$page` shim + Vue Router") | Testing philosophy (black box / not-our-code / boundary testing), AAA, reactivity guidelines, docstring format details, "prefer pure functions" style advice |

Trim rules:

- **Telegraphic bullets for content** (drop articles/filler, merge related bullets); guardrails, [ADAPT] composer notes, and multi-step procedures stay unambiguous full syntax.
- **No worked examples of generic patterns.** No ❌/✅ code blocks teaching mocking, no ref-type tables, no docstring examples. If a code example isn't about _this repo's_ conventions, it's a token leak.
- **Minimal skeletons only** for repo-specific patterns the agent would get wrong by guessing (e.g. Django permission-test inheritance: class chain + override mechanism in ~5 lines, not a full test class).
- **Drop what the agent finds by reading the code**: enumerations (app / entry-point lists, fixture names, auth providers, example filenames), config values (ruff/tsconfig flags, DRF classes, page sizes, coverage paths), script lists already in `package.json`. Keep rules, contracts and guardrails — facts an agent would violate, not ones it would look up. "Never delete repo facts" above protects the former, not the latter.
- Cut `Things to avoid` blocks that restate the section above them.
- No "Repo layout" / "Where new code goes" tables; no layering diagrams unless a non-obvious enforced rule. Drop sections for domains the repo doesn't have. Point at config in `pyproject.toml` / `package.json` instead of restating it.
- Each rule lives at its most specific level only. Framework sections point at the language/main section for the generic rule instead of restating it.
- **The repo's actual conventions win over template defaults.** Templates carry defaults (e.g. `*.spec.ts` colocated tests); read the real vitest/eslint/pytest config and write what's true (e.g. `__tests__/*.test.ts`).

### Create symlinks

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

### Cleanup

- Remove empty `.copilot/` and `.github/instructions/` dirs if no longer used.
- Repoint any in-repo markdown links that referenced deleted `.copilot/*` files to `AGENTS.md` (or fold their content in).
- Update `.gitignore`: drop `.copilot/` and `.github/instructions/` entries if fully migrated.
- Leave `.vscode/` gitignored.

### Final validation

Before handing back, scan the new `AGENTS.md` for accidentally leaked secrets. It is repo-bound — if the repo is public, a Sentry DSN or AWS key there is exposed.

```sh
grep -inE "dsn|token|secret|api[_-]?key|password|sk-|AKIA|xox|SECRET_KEY|AWS_ACCESS|AWS_SECRET|mysql://|redis://|smtp_pass|MAILGUN_KEY|BEGIN.*PRIVATE" AGENTS.md
```

Sentry org slug, region URL, and project slugs are **not** secrets (they require auth to access) — safe to keep. DSN strings, API keys, tokens, passwords are **secrets** — remove them. If the Sentry section uses DSN values instead of project slugs, replace with slugs and keep the DSN out of the file.

The build + symlink-verify + cleanup + secrets-scan steps above are the whole Create-mode job. No separate checklist file.

---

## Sync mode

Bring an existing `AGENTS.md` back in line with the current templates and the repo's config. Fixes in place by default — the user reviews with `git diff`.

- `--dry-run`: report only, no edits.
- `--deep`: also run the expensive checks (Sentry MCP, source scans). Default runs skip them.

### Reads

Default: `AGENTS.md`, the templates this project type composes from (see Create mode), `pyproject.toml`, `.python-version`, `package.json`, lockfiles, `run`, `openspec/config.yaml`. Paths mentioned in `AGENTS.md` get one existence check (single `ls` / glob) — never read source files.

`--deep` adds: Sentry MCP, `<app>/api/` code, sensitive modules (auth / permissions / serializers / payments / settings), `.github/workflows/`.

### Reconcile rules

- Existing wording wins wherever it says the same thing as the template — never reword for template parity.
- Add template rules the file lacks, only where they apply to this repo; remove rules the repo no longer supports.
- Never drop repo facts (paths, commands, globs, repo-specific extensions) unless verified stale.
- Cross-repo policy lines (philosophy, commit conventions, git workflow categories, Sentry workflow) follow the template: a clause the template dropped goes too.
- Token count grows only by added rules; stay within the Create-mode budget.

### Auto-fix

- Template drift per the reconcile rules above.
- Restated config values (Ruff / pytest / coverage) → delete, leave a `pyproject.toml` pointer.
- Marker in `AGENTS.md` not defined in `pyproject.toml` → remove.
- Python version → `requires-python` / `.python-version`.
- `openspec/config.yaml` has `store: <id>` but `## Specs` doesn't name it → store variant from `main.md`.
- Duplicate headings or the same rule in two sections → keep the most specific one.

### Report only (needs the user's call)

- **Python**: DRF / huey / arq / celery / FastAPI / `sentry-sdk` claimed but not in deps, or in deps but unmentioned; `DJANGO_SETTINGS_MODULE` mismatch; marker with a usage rule (e.g. `api` vs `site`) missing; `./run <cmd>` the `run` script doesn't support.
- **Frontend**: package manager contradicts lockfile; `yarn <script>` not in `package.json`.
- **OpenSpec**: no `openspec/` (suggest `openspec init --tools none`); no `## Specs` pointer; workflow restated.
- **Git workflow**: section missing; named extension path gone; restates the full tiered policy or enumerates paths the categories cover.
- **Structure**: mentioned path gone; new significant top-level dir (`tasks/`, `mcp/`, `tools/`) not reflected; command lists / code blocks / worked examples of generic craft (bloat).
- **`--deep` only**: Sentry org / project / region don't exist or mismatch (`find_organizations`, `find_projects`; skip with a note if MCP unavailable); framework variant contradicts `<app>/api/`; new sensitive area not named as a git-workflow extension.

### Output

```
## AGENTS.md sync — [PROJECT]

Edited:
- Python version 3.13 → 3.14
- Added: data migrations in own file (django.md)

Needs your call:
- `arq` in deps, no background-queue section
```

One line per item. No "verified OK" list. Empty section → omit it.

### Never

- Auto-fix structural or behavioural claims (framework variant, queue presence, directory layout, Sentry slugs).
- Recompose the file from scratch or restyle wording that already says the right thing.
