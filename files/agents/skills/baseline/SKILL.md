---
name: baseline
description: >
    Reverse-engineer status-quo OpenSpec specs from an existing codebase —
    maps capabilities across all repos sharing an OpenSpec root (e.g. -api +
    -app), writes `specs/<capability>/spec.md` for what the code does today,
    and a `baseline.md` report with per-capability completeness plus findings
    (suspected bugs, half-built features, api↔app drift, dead code). Speaks
    caveman terse style. Use when the user says "baseline", "spec the status
    quo", "bootstrap specs", "initial specs from code", or before proposing a
    change on a capability that has no spec yet. Also "baseline triage",
    "baseline next", "baseline close" to work through the findings.
---

Baseline. Reads code, writes what it does as OpenSpec specs, reports what looks wrong or unfinished. Chat terse — inherit caveman style unless the caller asks for a plain report, no announcing it. Files written in normal prose.

Goal is two things at once: specs as source of truth going forward, and an honest snapshot of how complete the project is right now. Findings matter as much as specs.

Paths: `<root>` = directory printed by `openspec context`. Everything this skill writes lives under `<root>/openspec/`.

Long shell output (inventories, greps, listings) may be truncated or compressed: redirect to `/tmp/baseline-<source>-<topic>.txt`, one file per topic (routes, models, client calls) so each stays readable, and Read it. Same if this skill's own text arrives with elided sections — Read `SKILL.md` from disk.

## Modes

- **Full** — no `<root>/openspec/specs/*/spec.md` yet (`.gitkeep` doesn't count). Steps 1–6.
- **One capability** — `baseline <capability>`, or invoked before `openspec-propose` on an unspecced area. Step 1, steps 3–4 for that capability only (anchors from the stored map, else by grepping), step 5 appending a dated section, step 6.
- **Fill gaps** — some specs exist. Reuse the map stored in `baseline.md` (remap only if asked or none stored); steps 3–4 only for capabilities without a spec. Existing specs are source of truth: never rewrite them; code that contradicts one is a `drift` finding.
- **triage / next / close** — work existing findings; see _Working the findings_, skip steps 1–6.
- **auto** (argument) — no pause at the map checkpoint, no routing offer at the end.

## Step 1 — resolve root & sources

- `openspec context` from the current repo gives `<root>`. `store: <id>` in `openspec/config.yaml` = shared store; add `--store <id>` to every `openspec` command.
- Sources = every sibling repo pointing at the same root: `grep -l "store: <id>" <parent-of-current-repo>/*/openspec/config.yaml`. Repo-local root = current repo only.
- Per source: `git rev-parse --short HEAD`, and `git status --porcelain -uall | wc -l` plus the folders touched, two levels below the repo root. Uncommitted work gets described like committed code, so it must show in the report.
- Store root: `git -C <root> status --short -- openspec/` must be empty (ignore `.DS_Store`). Not empty → stop, ask. Reset after a run is always `git -C <root> checkout -- openspec/ && git -C <root> clean -fd openspec/`.
- Read the root's own `README.md` / `AGENTS.md`: its conventions (commit style, `ideas.md` format) override this skill's defaults; spec layout is decided in step 2 from code.
- Read each source's `AGENTS.md` / `README.md`: stack, layout, domain words, declared external consumers.

## Step 2 — map

Inventory surfaces per source. Read shared code (models, services, stores) once here; step 3 reuses it rather than re-reading per capability.

- **Django backend**: `urls.py` (every route, with its URL name), `models/` (including signal receivers and `save()` side effects defined there), `services/` (usually where the real logic is), `api/` views, `admin/` custom actions and admin templates/JS, `tasks/` (scheduled + queued), `management/commands/`, `signals.py`, settings for external services (payments, mail, storage).
- **Vue/Quasar frontend**: `router/` routes, `pages/`, `stores/`, `api/` client modules, composables, PWA/offline bits, i18n locales.
- **Tests**: which areas have tests, per source. Tests show what someone meant the code to do, so they count as stronger evidence than the code alone.
- Other stacks: same idea — entry points, persisted data, jobs, integrations, UI routes.

Cross-link backend and clients. Clients = frontend app, admin templates/JS, and declared external consumers (calendar feeds, webhooks, third-party callers). Recipe:

1. List every exported function in the frontend's API modules with the endpoint it hits.
2. Find call sites: distinctive names by bare name (`grep -rn "\bcreatePorra\b" src --include='*.vue' --include='*.ts'`, quoted globs); generic names (`search`, `join`, `create`) by first listing files that import the module's namespace, then grepping the name within those, allowing a line break after the namespace (chained calls).
3. Count as calls too: URLs taken from API payloads (`rel_*`, `self` links fed to a generic request composable) and admin templates' `{% url '<name>' %}`, mapped to routes via the URL names from `urls.py`.
4. Diff against backend routes.
5. For every called endpoint, compare the frontend's response type (`src/types`, inline interfaces) with the backend schema: field names, optionality, enums, objects vs strings.

Outcomes (first match wins):

- client function nobody calls → `dead` (whether or not its endpoint exists)
- called client function, endpoint backend lacks or shape differs → `drift`
- backend endpoint no client calls, with evident UI intent (half a feature: permissions, validation, app types or copy for it) → `gap`
- public read endpoint no client calls, external consumer not declared in any README/AGENTS → `question`
- other endpoint no client calls → `dead`
- page with no backing endpoint → `gap`

Group into **capabilities**: user-visible feature areas that cut across repos (`race-predictions`, `standings`, `subscriptions`), not Django apps or Vue folders. Kebab-case, roughly 5–15. A capability needing more than ~12 requirements → split; fewer than 3 → fold into a neighbour. Staff tooling (admin custom actions, commands) belongs to the capability whose data it touches, as staff requirements; plain admin CRUD is not specced. `platform` holds only truly global behaviour (auth tokens, i18n, error contract, app-wide notices/redirects), never a dumping ground.

Code structure leads: capabilities usually line up with the backend's domain modules (`models/porras.py`, `models/events/`), merged or split only where users see it differently.

Areas come from code, never invented: domain subpackages (`models/events/`, `models/network/`), separate Django apps, or domain packages. Technical groupings (`core`, `utils`, `api`, `base`, `services/calculators`) don't count. Code has an area level → nested `specs/<area>/<capability>/`, area names as in code. Flat code → flat specs, even if the root's README shows nesting (flag the mismatch to the user). Spec areas are not `ideas.md` `#area` headings — those are product sections, often finer (`#acaces`, `#conference` both under `events/`); leave them alone.

**Checkpoint** (skipped in auto): show the map (capability, area if nested, one-line scope, backend anchors, client anchors) and wait for OK/merge/split/rename. The map is the unstable part of this skill — two runs will group differently — so a human OK here is what makes the specs stick.

## Step 3 — spec each capability

Inline by default. More than 15 capabilities, or user asks → one subagent per capability, each given name, scope, anchors, and a pointer to this file's **Spec rules** + **Findings** sections; collect their findings and renumber.

Per capability: read its specific code (views, tasks, pages, components) and tests, and `git log --oneline -- <paths> | head` when intent is unclear. Then write `<root>/openspec/specs/<capability>/spec.md` (or `specs/<area>/<capability>/spec.md` if step 2 chose nesting).

### Spec rules

Format (validator-enforced):

```markdown
# <capability> Specification

## Purpose

<1–2 sentences, 50+ chars: what this capability is for, from the user's side.>

## Requirements

### Requirement: <behaviour, not implementation>

The system SHALL <observable behaviour>.

#### Scenario: <short name>

- **WHEN** <condition>
- **THEN** <outcome>
- **AND** <further outcome>
```

Content:

- Spec behaviour that is observed and plausibly intended. Code deviates from a rule whose intent is evident (tests, error copy, UI text, sibling code) → spec the intended rule, log a `bug`, and end that requirement's prose (before its first `#### Scenario:`) with `Currently violated: baseline B<n>, B<m>.` so nobody reads the spec as a description of today (fixing the bug removes the line). Intent unclear, or two sources of intent conflict → spec neither side, log a `question`. Never encode a bug as a SHALL.
- Observable behaviour only: what users, staff, scheduled jobs, emails, payments and other external systems see. HTTP status codes and error messages are observable. External services users deal with (payment provider, social login, newsletter tool) may be named. Internal file paths, function/class names, libraries, table names may not — they go in findings.
- Frontend-only behaviour: spec it when it's a rule (condition → outcome: gating, redirects, limits, what's shown to whom), not layout or styling.
- Be concrete: real limits, deadlines, roles, states, numbers, pulled from constants and validation code ("at most 3 riders per stage", "locked 1 hour before stage start"). Concrete detail is what makes a spec worth more than the README.
- Permissions explicit: anonymous / authenticated / owner / staff — who can do what, and what happens when they can't.
- Scenarios: happy path plus the edge and error cases the code actually handles. Missing case that looks like a problem → `gap` finding, not an invented scenario.
- Half-built feature: spec only the part that works end-to-end, log the rest as `gap`.
- Each rule lives in one capability — the one that owns it. Rules that show up elsewhere (premium perks inside predictions and chat) are specced in the owner and only referenced by name elsewhere, not restated. A scheduled job feeding several capabilities: each capability specs the value it shows; the schedule itself lives in one of them.
- Headings, SHALL/MUST in English even if the domain is not.
- 3–12 requirements per capability, not one per endpoint. Requirement body over ~500 chars is usually two requirements — split it.

## Step 4 — findings sweep

Findings noticed while mapping or specking go in as you go. Then, per capability, a deliberate sweep — reading for specs finds the rules, not the breakage. Walk the capability's code against this list:

- **Error paths reported as success**: backend returns 2xx on a handled failure; frontend `catch` that only toasts, then navigates or shows success anyway.
- **Forms that don't persist**: payload built from the wrong field names, save that sends nothing, success toast without a request.
- **Client state after mutations**: cached store / user object not refreshed after payment, join, delete.
- **Cache invalidation**: writes via bulk `update()` / raw SQL / admin actions that bypass the signals or tags that invalidate caches.
- **State windows**: status computed from dates with gaps (between registration close and start), guards checking the wrong status.
- **Partial validation**: PATCH paths that skip full validation; unconstrained enums/integers; self-demotion or last-admin removal.
- **Destructive writes without a transaction**: delete-then-insert, multi-step updates.
- **Hardcoded production ids / magic numbers** and TODO/FIXME with substance.
- **Scheduled jobs** with filters narrower than the feature (one plan id, one type).
- **Links and emails** pointing at routes the frontend doesn't have.
- **Privacy / exposure**: private data in shared caches (service worker, CDN, server cache keyed without user), endpoints returning other users' private fields, visibility flags stored but not enforced.

Before logging a sweep candidate, trace it to the end: the signal, other write path or later refresh that might already handle it. Dropped candidates aren't findings.

### Findings format

Never fix code. Each finding: id (`B1`, `B2`, …), type, origin (`map` / `spec` / `sweep` — step where it was first spotted), capabilities (one or more; `cross-cutting` if repo-wide), claim in 1–3 sentences, evidence as one or more `repo:path:line` or `repo:path:start-end` (working-tree lines; suffix `(uncommitted)` when the file has uncommitted changes), and what would settle it.

- `bug` — code contradicts evident intent (tests, naming, UI copy, sibling code).
- `gap` — half-built: backend with no UI, UI with no backend, TODO/FIXME with substance, unhandled case users will hit.
- `drift` — backend↔client contract mismatch (fields, endpoints, enum values, response shape), or code contradicting an existing spec.
- `dead` — uncalled client function, endpoint with no client and no evident intent, unused model/field/task/composable, stale feature flag.
- `question` — can't tell if intended; needs a human. Hardcoded ids default here unless they demonstrably break something (then `bug`).

Evidence or it isn't a finding. Style nits, refactor wishes, dependency age are not findings.

## Step 5 — report & config

Write `<root>/openspec/baseline.md` (overwrite on full run; append a dated section otherwise):

```markdown
# Baseline — <YYYY-MM-DD>

Sources: <repo>@<sha> (uncommitted: <n> paths, <folders>), …

## Map

| Capability | Scope | Backend anchors                  | Client anchors                |
| ---------- | ----- | -------------------------------- | ----------------------------- |
| standings  | …     | tropela/services/calculators/, … | src/pages/races/standings/, … |

## Capabilities

| Capability    | Reqs | Completeness | Tests                   | Findings           |
| ------------- | ---- | ------------ | ----------------------- | ------------------ |
| standings     | 7    | complete     | api: tested · app: none | B9 (bug)           |
| subscriptions | 4    | partial      | api: thin · app: none   | B3 (bug), B7 (gap) |

## Findings

### B1 · bug · standings, porras · open

<claim>
Origin: sweep
Evidence: tropela-api:tropela/services/calculators/standings.py:88
Settle: <what would confirm/refute>
```

Completeness (first match wins); minor bugs don't count, they show in the Findings column:

- `broken` — a `bug` or `drift` breaks a main user flow (payment, signup, saving the core object).
- `partial` — at least one `gap` (half-built flow).
- `complete` — every user-facing flow the capability offers exists and works end to end.
- `api-only` / `app-only` — only one side exists.
- `dead` — nothing reachable.

Tests per source: `tested` — the capability's core rules have tests; `thin` — tests exist but core rules don't have them; `none`.

A finding with several capabilities is listed in each of their rows. `cross-cutting` stays `cross-cutting` in its heading and is listed in the `platform` row.

Root `config.yaml` has no real `context:` → add a `context: |` block right after `schema:`, leaving the commented examples alone: stack per source, repos and their roles, domain glossary gathered while mapping (under ~25 lines). Existing `context:` → leave it. Check it parses: `ruby -ryaml -e 'YAML.load_file(ARGV[0])' <root>/openspec/config.yaml`.

## Step 6 — validate & hand over

- `openspec validate --specs --strict` until no errors. INFO lines flagging a requirement body over 500 chars → split it; other INFO → ignore.
- Never commit. Summarise in chat: capability count, requirement count, completeness spread, findings by type, top 3–5 findings worth acting on.
- Not auto → offer a second sweep (see Gotchas). Commit only on user's go — store root: `docs: baseline specs` in the store repo.
- Don't route findings to Trello or `ideas.md` in bulk: `baseline.md` stays the one list, and findings leave it only when picked up (next section).

## Working the findings

Every finding heading ends with a status: `open` · `fixed <repo>@<sha>` · `dropped: <reason>` · `→ card` · `→ idea`. `baseline.md` stays the one list; a finding leaves `open` only through the commands below. Each command edits the store and commits (`docs: …`) — never code.

- **`baseline triage`** — open `question`s, one at a time: claim + evidence, then user picks
    - intended → spec it (requirement or scenario), `dropped: intended`
    - not intended → spec the right rule with `Currently violated: baseline B<n>.`, retype to `bug`
    - undecided → skip, stays `open`
    - Gap needing a product decision → `ideas.md` under its product `#area`, origin `_(baseline, YYYY-MM-DD)_`, `→ idea`; worth thinking through now → `openspec-explore`, then `openspec-propose`.
    - Commit once at the end: `docs: triage baseline questions`.

- **`baseline next`** — propose one PR-sized batch of open bugs/drift sharing a root cause or flow (e.g. payment flow = B2 + B3 + B4). Order: `broken` capabilities → privacy/data exposure → the rest; dead code as one cleanup batch per repo. Show ids, files, requirements it un-violates. Fix happens in the code repo per its `AGENTS.md` — no OpenSpec change when it restores specced behaviour; `openspec-propose` if it adds user-visible behaviour. Picked into the week → Alfred card with `spec: <root>/baseline#B<n>`, no copied text, `→ card`.

- **`baseline close <ids> <repo>@<sha>`** — after merge: remove the ids from `Currently violated` lines (drop empty lines), mark `fixed <repo>@<sha>`, validate, commit `docs: close B<n>, …`.

No `open` left → `baseline.md` is a frozen snapshot; delete it or keep it, never update it again.

## Gotchas

- Specs describe the system once, not once per repo. A behaviour spread over backend + frontend is one requirement, not two.
- One run finds roughly three quarters of what two runs find together. For a first baseline worth keeping, offer a second step 4 sweep: fresh subagent, same map, given the existing findings, told to add only new ones and to re-check existing evidence. Optional, only on user's go.
- Evidence line numbers come from the source file itself (Read tool or `grep -n` on the file), never from a `/tmp` inventory dump — dumps with headers or concatenated files shift every line.
- A test run is resettable (step 1 reset command); the specs from a kept run are not — once committed, later changes go through `openspec-propose`, not a rerun.
