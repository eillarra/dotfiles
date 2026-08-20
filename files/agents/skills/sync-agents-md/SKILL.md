---
name: sync-agents-md
description: Detect and optionally fix drift between a repo's AGENTS.md and its actual configuration (pyproject.toml, package.json, run script, Sentry). Read-only by default — reports stale commands, ruff config, pytest markers, Python version, package manager, framework deps, and Sentry project slugs. With --fix, auto-corrects only narrow mechanical values (ruff config, pytest markers, Python version) copied from config files. Structural and behavioural drift is always report-only. Use when maintaining an existing AGENTS.md, after dependency changes, or as a periodic drift check. Companion to `migrate-agents-md` (one-shot creation) — this is for ongoing maintenance.
---

# Sync AGENTS.md

Detect and optionally fix drift between a repo's `AGENTS.md` and the actual project configuration. This is the maintenance companion to `migrate-agents-md` (which creates `AGENTS.md` from templates — a one-shot). This skill keeps an existing `AGENTS.md` honest as the repo evolves.

## When to use

- After dependency changes (added/removed Django, DRF, FastAPI, huey, arq, …).
- After config changes (ruff rules, pytest markers, Python version, package manager).
- After renaming a Sentry project or switching Sentry regions.
- Periodic drift check (e.g. monthly).
- User says "check AGENTS.md", "sync AGENTS.md", "is AGENTS.md up to date".

## Modes

### Default: read-only drift report

Scan the repo, compare `AGENTS.md` claims against ground-truth config files, and output a report. No edits. The user reviews and decides what to fix.

### `--fix`: auto-correct narrow mechanical values only

Fix only values that are pure copies from config files — zero judgement required:

- **Ruff config**: `target-version`, `line-length`, selected rule sets → copy from `pyproject.toml`.
- **pytest markers** → copy from `pyproject.toml` `[tool.pytest.ini_options] markers`.
- **Python version / `target-version`** → copy from `.python-version` or `pyproject.toml` `requires-python`.

Everything else is report-only, even in `--fix` mode. Structural and behavioural drift requires human judgement — the agent does not guess.

## What to check

### Python (if `pyproject.toml` exists)

#### Ruff config

Read `pyproject.toml` → `[tool.ruff]` and `[tool.ruff.lint]`. Compare against what `AGENTS.md` says in its Style / Ruff section:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `target-version` mismatch | ✅ | ✅ |
| `line-length` mismatch | ✅ | ✅ |
| Selected rule sets (`select` list) mismatch | ✅ | ✅ |
| Per-file ignores changed | ✅ | ❌ (judgement — may be intentional) |

#### pytest markers

Read `pyproject.toml` → `[tool.pytest.ini_options] markers`. Compare against markers listed in `AGENTS.md`:

| Check | Report | Auto-fix |
| --- | --- | --- |
| Markers in `AGENTS.md` not in `pyproject.toml` (stale) | ✅ | ✅ (remove) |
| Markers in `pyproject.toml` not in `AGENTS.md` (undocumented) | ✅ | ✅ (add) |

#### Python version

Read `.python-version` (if exists) and `pyproject.toml` → `requires-python`. Compare against `AGENTS.md`:

| Check | Report | Auto-fix |
| --- | --- | --- |
| Python version in `AGENTS.md` stale | ✅ | ✅ |

#### DJANGO_SETTINGS_MODULE

Read `pyproject.toml` → `[tool.pytest.ini_options] DJANGO_SETTINGS_MODULE`. Compare against `AGENTS.md`:

| Check | Report | Auto-fix |
| --- | --- | --- |
| Settings module value mismatch | ✅ | ❌ (could be intentional for test vs prod) |

#### Framework dependencies

Read `pyproject.toml` → `dependencies`. Cross-reference against what `AGENTS.md` claims:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `AGENTS.md` mentions DRF but `djangorestframework` not in deps | ✅ | ❌ |
| `AGENTS.md` says "no DRF / native views" but `djangorestframework` IS in deps | ✅ | ❌ |
| `AGENTS.md` mentions huey but `huey` not in deps (or vice versa) | ✅ | ❌ |
| `AGENTS.md` mentions arq but `arq` not in deps (or vice versa) | ✅ | ❌ |
| `AGENTS.md` mentions celery but `celery` not in deps (or vice versa) | ✅ | ❌ |
| `AGENTS.md` mentions FastAPI but `fastapi` not in deps | ✅ | ❌ |
| `AGENTS.md` mentions Sentry but `sentry-sdk` not in deps | ✅ | ❌ |

#### Commands

Read the `run` script (if exists) to see which subcommands it supports. Read `pyproject.toml` for any script entry points. Compare against commands listed in `AGENTS.md`:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `AGENTS.md` lists a `./run <cmd>` that the `run` script doesn't support | ✅ | ❌ (may be intentional) |
| `run` script has a subcommand not documented in `AGENTS.md` | ✅ | ❌ |

### Frontend (if `package.json` exists)

#### Package manager

Detect from lockfiles: `yarn.lock` → yarn, `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm. Compare against what `AGENTS.md` says:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `AGENTS.md` says yarn but `package-lock.json` exists (or vice versa) | ✅ | ❌ |

#### Scripts

Read `package.json` → `scripts`. Compare against commands listed in `AGENTS.md`:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `AGENTS.md` lists `yarn <script>` but script not in `package.json` | ✅ | ❌ |
| `package.json` has a script not documented in `AGENTS.md` | ✅ | ❌ |

### Sentry (if `AGENTS.md` has a Sentry section)

Parse the Sentry section of `AGENTS.md` for `organizationSlug`, `projectSlugOrId`, `regionUrl`. Use the Sentry MCP tools to verify:

| Check | Report | Auto-fix |
| --- | --- | --- |
| `organizationSlug` doesn't exist (call `find_organizations`) | ✅ | ❌ |
| `projectSlugOrId` doesn't exist under that org (call `find_projects`) | ✅ | ❌ |
| `regionUrl` doesn't match the org's actual region | ✅ | ❌ |

To verify: call `find_organizations()` to confirm the org exists and get its `regionUrl`. Then call `find_projects(organizationSlug=<slug>, regionUrl=<url>)` to confirm the project slug exists. If the user has Sentry MCP access, use it; if not, skip this section and report "Sentry MCP not available — could not verify".

### Structural drift (report only, never fix)

These are judgement calls. The agent reports; the user decides.

| Check | Report | Auto-fix |
| --- | --- | --- |
| `AGENTS.md` mentions a directory that no longer exists | ✅ | ❌ |
| A significant new top-level directory exists that `AGENTS.md` doesn't reflect (e.g. new `tasks/`, new `mcp/`, new `tools/`) | ✅ | ❌ |
| `AGENTS.md` claims a framework variant (DRF / native views) that doesn't match the code in `<app>/api/` | ✅ | ❌ |

## Procedure

1. **Read `AGENTS.md`** — parse it into sections. Note what claims it makes (commands, config values, framework, deps, Sentry slugs).
2. **Read config files** — `pyproject.toml`, `package.json`, `run` script, `.python-version`, lockfiles.
3. **Run checks** — go through every check above that applies (Python checks if `pyproject.toml` exists; frontend checks if `package.json` exists; Sentry checks if `AGENTS.md` has a Sentry section and MCP is available).
4. **Output a drift report** grouped by severity:
   - **🔴 Stale** — `AGENTS.md` claims something the config contradicts.
   - **🟡 Undocumented** — config has something `AGENTS.md` doesn't mention.
   - **🟢 OK** — verified matches (brief summary, not per-check).
5. **If `--fix`**: apply auto-fixes for the narrow mechanical set only (ruff config, pytest markers, Python version). Use `edit_file` to update the specific lines in `AGENTS.md`. Report each edit made.
6. **Report-only items**: list them clearly with a one-line "consider updating" note. Do not edit.

## Report format

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

## What this skill does NOT do

- **Does not regenerate `AGENTS.md` from templates.** Use `migrate-agents-md` for that (one-shot).
- **Does not auto-fix structural or behavioural claims.** Framework variant, queue presence, directory structure, Sentry slugs — all report-only. The agent does not guess whether a change is intentional.
- **Does not add new sections.** If a new `tasks/` dir appears, it reports "consider documenting" but does not write the section.
- **Does not run on repos without `AGENTS.md`.** If no `AGENTS.md`, suggest `migrate-agents-md` instead.