---
name: agents-md
description: >
    Create or maintain a repo's canonical AGENTS.md (with CLAUDE.md /
    .github/copilot-instructions.md symlinks). Auto-detects mode — composes
    AGENTS.md from templates when none exists (Create mode); reports and
    auto-corrects drift with --fix against the repo's actual config when it
    already exists (Sync mode). Tailored to Python-backend and Django+Vue
    projects with Sentry integration. Use when setting up AGENTS.md from
    scratch, checking if it's still accurate, or after dependency/config
    changes.
---

# AGENTS.md

One skill for the whole lifecycle of a repo's `AGENTS.md`: write it when missing, keep it honest once it exists.

## Determine mode

Check whether `AGENTS.md` exists at the repo root.

- **Missing → Create mode**: compose a new `AGENTS.md` from templates.
- **Exists → Sync mode**: read-only drift report by default; `--fix` auto-corrects a
  narrow set of mechanical values.

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

- **Repo-specific truth → `AGENTS.md`:** stack list, non-negotiable rules ("never edit shipped migrations", async-route-blocking for FastAPI+Django ORM), commands / test markers / config locations, API contract, Sentry slugs — anything that changes when you switch repos. Guardrails stay here regardless of cross-repo constancy: they bind on every routine turn.
- **Named, explicitly-invoked procedures → global skill:** release playbook, model+migration recipe, setup tutorial. Patterns that are merely cross-repo-constant are not skills — they're knowledge the model already has.
- **Niche domain deep-dives → `docs/agent/<topic>.md`**, one-line pointer from `AGENTS.md`.
- **Cross-repo agent workflow (OpenSpec usage) → global `~/.claude/CLAUDE.md`** (`files/agents/AGENTS.md` in dotfiles). Repo `AGENTS.md` carries only the one-line `## Specs` pointer; never restate specs or OpenSpec workflow steps.

### Inputs to gather before writing

Ask the user (or infer from the repo) before drafting:

1. **Project type** — `python-lib` / `django` / `fastapi` / `django+vue` / `mcp` / `vue` (frontend-only) / `other`.
2. **Backend framework** — confirm Django+DRF / Django + native views + Pydantic / FastAPI / MCP server (`mcp` Python SDK, `MCPServer`) / bare / **none** (frontend-only repo). Do not assume DRF — some Django projects in this org have removed DRF.
3. **MCP server?** — if the project exposes MCP tools, set type to `mcp` and include `mcp.md`.
4. **Frontend framework** — Vue 3 + Quasar + Inertia + Vite + TS (default when the frontend is server-rendered via Inertia) OR Vue 3 + Quasar standalone SPA/PWA (when the frontend is a separate repo, e.g. `tropela-app`). Other TS frameworks (React/Svelte/plain TS) → `typescript` type with no `vue.md`. Confirm which — it changes the `vue.md` layout section.
5. **Package managers** — Python: uv (preferred) / pip / poetry / hatch; Frontend: yarn (preferred) / npm / pnpm.
6. **Sentry endpoints** — backend DSN or project slug; frontend DSN or project slug. For frontend-only repos, list the frontend project only. For backend-only repos, list the backend project only. For fullstack same-repo projects, list both.
7. **Commit convention** — default Conventional Commits short form; confirm.
8. **Docstring style** — reST (Sphinx) / Google / NumPy / none; detect from existing code before keeping the reST section in `python.md` (frontend-only repos have no Python, so skip this question).
9. **OpenSpec** — if no `openspec/` dir, suggest `openspec init --tools none` (skills are already global; `--tools agents` only if teammates need them in-repo). Run it only after the user confirms. If `openspec/config.yaml` has `store: <id>`, the repo uses a shared store — use the store variant of `## Specs`.

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

1. Always include `templates/main.md` (header, core philosophy, code style, stack, commands `./run` rule, commit conventions, git workflow, specs pointer, testing pointer, Sentry pointer, niche docs pointer).
2. For any Python project type (`python-lib`, `django`, `fastapi`, `django+vue`, `mcp`): append `templates/python.md` (General/PEP 8, docstrings, commands, pytest AAA + test location/fixtures/coverage, **test-review workflow**, Ruff).
3. If the backend is Django: append `templates/django.md` (Fat-models-thin-views / ORM efficiency, migrations, API with DRF vs native-views+Pydantic variants, Django commands, Django test patterns: file-suffix conventions, permission-inheritance pattern, test class naming).
4. If the backend is FastAPI: append `templates/fastapi.md` (routers/dependencies, **Django ORM** (models, migrations, async-route-blocking rule), schemas, background tasks, settings, entrypoint, FastAPI commands).
5. If the project is an MCP server: append `templates/mcp.md` (tool definitions, **MCP tool docstrings written for the LLM not humans**, Django ORM + async guardrail when applicable, schemas, settings, entrypoint, MCP commands). `mcp.md` is a peer of `fastapi.md` — do **not** also include `fastapi.md` (MCP servers expose tools over the MCP protocol, not REST routers).
6. If the project has any TypeScript codebase (`django+vue`, `vue`, `typescript`): append `templates/typescript.md` (General/strict mode, style + yarn-default, vitest testing — test location/mocking/coverage as one-liners, testing philosophy compressed, **no worked examples**).
7. If the frontend is Vue (`django+vue`, `vue`): append `templates/vue.md` **on top of** `typescript.md` (Stack, reactivity best practices, component structure, code organisation for testability, form components pointer, Vue commands, Vue-specific testing). In a `django+vue` monorepo, the Vue frontend lives in `/vue/` and follows `typescript`+`vue` rules independently — Django's only role re: the frontend is Inertia (rendering the right page component and providing props). (FastAPI / MCP backends do not ship Vue frontends in this organisation — do not combine `fastapi` or `mcp` with `vue`.)
8. Always append `templates/sentry.md`, filling in: backend + frontend endpoints when both exist in this repo; backend-only when no TS frontend; **frontend-only when the backend lives in a separate repo**. Keep the bug-fix workflow verbatim.

**Adapt every section to the actual repo.** Read `pyproject.toml` / `package.json` / settings / `urls.py` / `routers.py` / `run` script / CI workflows. Do not paste templates verbatim — tailor paths, commands, package manager, version pins, markers, per-file ignores.

**Target length:** ~1.2k tokens for the composed file, ceiling ~1.5k where repo-specific content earns its place — **real tokenizer tokens** (measure with e.g. `uv run --with tiktoken python -c "import tiktoken; print(len(tiktoken.get_encoding('o200k_base').encode(open('AGENTS.md').read())))"`). Chars/4.2 heuristics undercount code-heavy markdown by ~25–30% (paths and `identifiers` split into several tokens). Every token is loaded into every session. Single-stack projects should land well under 1k; fullstack `django+vue` around 1–1.5k. If a section doesn't pull its weight, move the deep-dive to `docs/agent/<topic>.md` — never delete repo facts to save tokens. Guardrails and failure-mode rules are never cut for the budget — the cost of a wrong drop is broken code shipped. Readability beats squeezing: numbered procedures stay one step per line; don't merge list items to shave bytes.

**The relevance filter — what is actually worth an agent's context?** `AGENTS.md` exists for what the model cannot derive from training data: facts that change when you switch repos, and rules the repo would otherwise see violated. Generic framework craft (AAA tests, `shallowRef` for API data, mock-the-boundary, docstring syntax) is already known — at most one line per idea.

| Keep (repo-specific delta)                                                                                                                                                                                                                             | Compress to one line max (generic craft)                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `./run` wrapper rule, test locations / markers / naming, config file locations, Sentry slugs, commit format, migration rules, framework-variant contracts (DRF vs native views), shim notes ("no `@inertiajs/vue3` — local `$page` shim + Vue Router") | Testing philosophy (black box / not-our-code / boundary testing), AAA, reactivity guidelines, docstring format details, "prefer pure functions" style advice |

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

Detect, and optionally fix, drift between an existing `AGENTS.md` and the actual project configuration.

### When to use Sync mode

- After dependency changes (added/removed Django, DRF, FastAPI, huey, arq, …).
- After config changes (ruff rules, pytest markers, Python version, package manager).
- After renaming a Sentry project or switching Sentry regions.
- Periodic drift check (e.g. monthly).
- User says "check AGENTS.md", "sync AGENTS.md", "is AGENTS.md up to date".

### Default: read-only drift report

Scan the repo, compare `AGENTS.md` claims against ground-truth config files, and output a report. No edits. The user reviews and decides what to fix.

### `--fix`: auto-correct narrow mechanical values only

Fix only values that are pure copies from config files — zero judgement required:

- **Ruff config**: `target-version`, `line-length`, selected rule sets → copy from `pyproject.toml`.
- **pytest markers** → copy from `pyproject.toml` `[tool.pytest.ini_options] markers`.
- **Python version / `target-version`** → copy from `.python-version` or `pyproject.toml` `requires-python`.

Everything else is report-only, even in `--fix` mode. Structural and behavioural drift requires human judgement — the agent does not guess.

### What to check

#### Python (if `pyproject.toml` exists)

##### Ruff config

Read `pyproject.toml` → `[tool.ruff]` and `[tool.ruff.lint]`. Compare against what `AGENTS.md` says in its Style / Ruff section:

| Check                                       | Report | Auto-fix                            |
| ------------------------------------------- | ------ | ----------------------------------- |
| `target-version` mismatch                   | ✅     | ✅                                  |
| `line-length` mismatch                      | ✅     | ✅                                  |
| Selected rule sets (`select` list) mismatch | ✅     | ✅                                  |
| Per-file ignores changed                    | ✅     | ❌ (judgement — may be intentional) |

##### pytest markers

Read `pyproject.toml` → `[tool.pytest.ini_options] markers`. Compare against markers listed in `AGENTS.md`:

| Check                                                         | Report | Auto-fix    |
| ------------------------------------------------------------- | ------ | ----------- |
| Markers in `AGENTS.md` not in `pyproject.toml` (stale)        | ✅     | ✅ (remove) |
| Markers in `pyproject.toml` not in `AGENTS.md` (undocumented) | ✅     | ✅ (add)    |

##### Python version

Read `.python-version` (if exists) and `pyproject.toml` → `requires-python`. Compare against `AGENTS.md`:

| Check                               | Report | Auto-fix |
| ----------------------------------- | ------ | -------- |
| Python version in `AGENTS.md` stale | ✅     | ✅       |

##### DJANGO_SETTINGS_MODULE

Read `pyproject.toml` → `[tool.pytest.ini_options] DJANGO_SETTINGS_MODULE`. Compare against `AGENTS.md`:

| Check                          | Report | Auto-fix                                   |
| ------------------------------ | ------ | ------------------------------------------ |
| Settings module value mismatch | ✅     | ❌ (could be intentional for test vs prod) |

##### Framework dependencies

Read `pyproject.toml` → `dependencies`. Cross-reference against what `AGENTS.md` claims:

| Check                                                                         | Report | Auto-fix |
| ----------------------------------------------------------------------------- | ------ | -------- |
| `AGENTS.md` mentions DRF but `djangorestframework` not in deps                | ✅     | ❌       |
| `AGENTS.md` says "no DRF / native views" but `djangorestframework` IS in deps | ✅     | ❌       |
| `AGENTS.md` mentions huey but `huey` not in deps (or vice versa)              | ✅     | ❌       |
| `AGENTS.md` mentions arq but `arq` not in deps (or vice versa)                | ✅     | ❌       |
| `AGENTS.md` mentions celery but `celery` not in deps (or vice versa)          | ✅     | ❌       |
| `AGENTS.md` mentions FastAPI but `fastapi` not in deps                        | ✅     | ❌       |
| `AGENTS.md` mentions Sentry but `sentry-sdk` not in deps                      | ✅     | ❌       |

##### Commands

Read the `run` script (if exists) to see which subcommands it supports. Read `pyproject.toml` for any script entry points. Compare against commands listed in `AGENTS.md`:

| Check                                                                   | Report | Auto-fix                |
| ----------------------------------------------------------------------- | ------ | ----------------------- |
| `AGENTS.md` lists a `./run <cmd>` that the `run` script doesn't support | ✅     | ❌ (may be intentional) |
| `run` script has a subcommand not documented in `AGENTS.md`             | ✅     | ❌                      |

#### Frontend (if `package.json` exists)

##### Package manager

Detect from lockfiles: `yarn.lock` → yarn, `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm. Compare against what `AGENTS.md` says:

| Check                                                                | Report | Auto-fix |
| -------------------------------------------------------------------- | ------ | -------- |
| `AGENTS.md` says yarn but `package-lock.json` exists (or vice versa) | ✅     | ❌       |

##### Scripts

Read `package.json` → `scripts`. Compare against commands listed in `AGENTS.md`:

| Check                                                              | Report | Auto-fix |
| ------------------------------------------------------------------ | ------ | -------- |
| `AGENTS.md` lists `yarn <script>` but script not in `package.json` | ✅     | ❌       |
| `package.json` has a script not documented in `AGENTS.md`          | ✅     | ❌       |

#### Sentry (if `AGENTS.md` has a Sentry section)

Parse the Sentry section of `AGENTS.md` for `organizationSlug`, `projectSlugOrId`, `regionUrl`. Use the Sentry MCP tools to verify:

| Check                                                                 | Report | Auto-fix |
| --------------------------------------------------------------------- | ------ | -------- |
| `organizationSlug` doesn't exist (call `find_organizations`)          | ✅     | ❌       |
| `projectSlugOrId` doesn't exist under that org (call `find_projects`) | ✅     | ❌       |
| `regionUrl` doesn't match the org's actual region                     | ✅     | ❌       |

To verify: call `find_organizations()` to confirm the org exists and get its `regionUrl`. Then call `find_projects(organizationSlug=<slug>, regionUrl=<url>)` to confirm the project slug exists. If the user has Sentry MCP access, use it; if not, skip this section and report "Sentry MCP not available — could not verify".

#### OpenSpec

| Check                                                                         | Report | Auto-fix                                     |
| ----------------------------------------------------------------------------- | ------ | -------------------------------------------- |
| No `openspec/` dir                                                            | ✅     | ❌ (suggest `openspec init --tools none`)    |
| `openspec/` exists but `AGENTS.md` has no `## Specs` pointer                  | ✅     | ❌                                           |
| `AGENTS.md` restates OpenSpec workflow or spec content (lives in global file) | ✅     | ❌                                           |
| `openspec/config.yaml` has `store: <id>` but `## Specs` doesn't name the store | ✅     | ✅ (store variant from `main.md`)            |

#### Structural drift (report only, never fix)

These are judgement calls. The agent reports; the user decides.

| Check                                                                                                                                                                               | Report | Auto-fix |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | -------- |
| `AGENTS.md` mentions a directory that no longer exists                                                                                                                              | ✅     | ❌       |
| A significant new top-level directory exists that `AGENTS.md` doesn't reflect (e.g. new `tasks/`, new `mcp/`, new `tools/`)                                                         | ✅     | ❌       |
| `AGENTS.md` claims a framework variant (DRF / native views) that doesn't match the code in `<app>/api/`                                                                             | ✅     | ❌       |
| `AGENTS.md` carries multi-line worked examples of generic craft knowledge (❌/✅ code blocks, ref-type tables, docstring examples) — bloat; see the relevance filter in Create mode | ✅     | ❌       |

### Procedure

1. **Read `AGENTS.md`** — parse it into sections. Note what claims it makes (commands, config values, framework, deps, Sentry slugs).
2. **Read config files** — `pyproject.toml`, `package.json`, `run` script, `.python-version`, lockfiles, `openspec/` presence (+ `store:` in `openspec/config.yaml`).
3. **Run checks** — go through every check above that applies (Python checks if `pyproject.toml` exists; frontend checks if `package.json` exists; Sentry checks if `AGENTS.md` has a Sentry section and MCP is available).
4. **Output a drift report** grouped by severity:
    - **🔴 Stale** — `AGENTS.md` claims something the config contradicts.
    - **🟡 Undocumented** — config has something `AGENTS.md` doesn't mention.
    - **🟢 OK** — verified matches (brief summary, not per-check).
5. **If `--fix`**: apply auto-fixes for the narrow mechanical set only (ruff config, pytest markers, Python version). Use `edit_file` to update the specific lines in `AGENTS.md`. Report each edit made.
6. **Report-only items**: list them clearly with a one-line "consider updating" note. Do not edit.

### Report format

```
## AGENTS.md drift report for [PROJECT]

### 🔴 Stale (AGENTS.md contradicts config)

- Ruff `target-version`: AGENTS.md says `py312`, pyproject.toml says `py314` [auto-fixable]
- pytest markers: AGENTS.md lists `@pytest.mark.slow` but it's not in pyproject.toml [auto-fixable]
- Sentry project `tropela-api` not found under org `tropela` [manual review]

### 🟡 Undocumented (config has, AGENTS.md doesn't mention)

- `arq` in dependencies but AGENTS.md doesn't mention a background queue
- `yarn test:e2e` in package.json but not documented in AGENTS.md

### 🟢 Verified OK

- Ruff `line-length`: 120 ✓
- Package manager: yarn ✓
- DJANGO_SETTINGS_MODULE: matches ✓

### Auto-fixed (--fix mode)

- Updated Ruff `target-version` → `py314`
- Updated pytest markers (removed `slow`, added `integration`)
```

### What Sync mode does NOT do

- **Does not regenerate `AGENTS.md` from templates.** That's Create mode.
- **Does not auto-fix structural or behavioural claims.** Framework variant, queue presence, directory structure, Sentry slugs — all report-only. The agent does not guess whether a change is intentional.
- **Does not add new sections.** If a new `tasks/` dir appears, it reports "consider documenting" but does not write the section.
