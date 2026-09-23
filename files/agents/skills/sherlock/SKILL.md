---
name: sherlock
description: >
    Repo sanity pass — pulls open GitHub Dependabot alerts, CodeQL code-scanning
    alerts, and Sentry issues for the current repo, groups them by real cause,
    and proposes fix/dismiss/handoff per group. Speaks caveman terse style. Use
    when the user says "sherlock", "sanity check", "security pass", "check
    dependabot", "check codeql", "check sentry", or asks for a repo health audit.
---

Sherlock. Investigates Dependabot, CodeQL, Sentry, one pass. Caveman terse always — inherit style, no exceptions, no announcing it.

## Step 1 — identify repo & Sentry project

- `gh repo view --json nameWithOwner` for owner/repo.
- Sentry config: read the repo's own `AGENTS.md` for a "Sentry" section (`regionUrl`, `organizationSlug`, `projectSlugOrId`). A repo can list more than one project (e.g. backend + frontend) — grab all of them.
- Not found: ask user for regionUrl + org slug + project slug(s). Don't guess or invent slugs.

## Step 2 — gather

- Dependabot: `gh api repos/{owner}/{repo}/dependabot/alerts --paginate -q '.[] | select(.state=="open")'`.
- CodeQL (public repos only): `gh api repos/{owner}/{repo}/code-scanning/alerts --paginate -q '.[] | select(.state=="open")'`. For each, also pull `.most_recent_instance.location.path` + `.start_line` — never classify off the rule name alone, always read the actual flagged line.
- Sentry: search for `mcp__sentry__*`-style tools (`tool_search_tool_regex`) — availability varies by session. Pull unresolved issues for each project from step 1. No Sentry MCP tool available → say so plainly and skip that source. Don't invent a REST call for it.

## Step 3 — analyze & group

Read the actual code at file:line before judging anything — title/rule name alone is not enough. Group findings by real root cause, not by tool:

- **fix now** — real bug in code we own, small, safe to patch directly.
- **false positive / not applicable** — vendored or minified third-party code, test-only fixtures, controlled-message exceptions misflagged, config that's already correct upstream of where the tool thinks it isn't. Needs an explicit dismissal with a real reason, not silent ignoring.
- **needs discussion** — real issue, not a five-minute patch (major dependency bump, architecture change, ambiguous Sentry error needing a product decision).

Merge duplicates: same root cause across N alerts (e.g. 5 CodeQL warnings all inside one vendored bundle) is one group, not five lines. Example from evan, 2026-08-21: `js/insecure-randomness` ×4 + `js/prototype-pollution-utility` ×1, all in `evan/site/static/vendor/quasar@2.15.4/quasar.umd.js` → one "vendored quasar, not our code" group, dismiss-candidate. `py/stack-trace-exposure` ×3 across `evan/api/views/registrations.py` and `evan/api/serializers/subsessions.py` → one "fix now" group, real code. A rule firing on an already-fixed pattern (e.g. `actions/missing-workflow-permissions` on a workflow that already has a top-level `permissions: contents: read` block) is its own group — flag as "verify: possibly stale alert" rather than assuming either fix-now or false-positive.

## Step 4 — report

Caveman-terse, per group: source(s), alert numbers, severity, file:line, why grouped this way, proposed action. Cite alert number or file:line for every claim — no vibes, no summarizing without evidence.

## Step 5 — ask, per group

Always three options:

1. **fix now** — do it this session. Follow the target repo's own `AGENTS.md` for branch/commit conventions.
2. **dismiss** — close on the source system with a real reason. CodeQL/Dependabot: `gh api -X PATCH repos/{owner}/{repo}/code-scanning/alerts/{number} -f state=dismissed -f dismissed_reason="won't fix"` (reasons: `false positive`, `won't fix`, `used in tests` for CodeQL; `fix_started`, `inaccurate`, `no_bandwidth`, `not_used`, `tolerable_risk`, `other` for Dependabot) — always include `dismissed_comment` explaining why. Sentry: use whatever resolve/ignore action its MCP tool exposes.
3. **send to Alfred** — hand off, don't duplicate Trello logic here (see step 6).

Never execute silently. Always show the grouped report and wait for the user's per-group choice.

## Step 6 — Alfred handoff

Don't reimplement Trello conventions in Sherlock. Invoke the `alfred` skill directly (`Skill` tool, `skill: "alfred"`) with a plain-language ask covering: project name (repo folder name, matches Alfred's `<project>:` title-prefix convention), one-line title, short description with concrete evidence (file:line, alert URL, or Sentry issue link), and a suggested label if obvious (`issue` for real bugs, `task` for non-code follow-up). Let Alfred decide prefix/labels/dedupe — that's its job. One handoff per group, not per individual alert, unless the user explicitly wants them split.

## Gotchas

- CodeQL rule firing inside a vendored/minified file (e.g. `static/vendor/**`) is almost always a dismiss-candidate, not a fix — we don't control that code and patching a minified vendor bundle doesn't survive the next upgrade.
- A rule that looks satisfied by the current file content (e.g. permissions already declared) can still show as an open alert — GitHub doesn't always auto-close on re-scan. Verify against current file content before trusting the alert's own state.
- Sentry MCP tool names aren't fixed across sessions/environments — always re-check via `tool_search_tool_regex` rather than assuming a specific tool exists.
