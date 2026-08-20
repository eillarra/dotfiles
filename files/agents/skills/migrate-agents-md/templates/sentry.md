# Sentry section

Always append a Sentry section to `AGENTS.md` when the project has Sentry integration (the default for this organisation's projects). Drop only if the project genuinely has no Sentry.

The agent has access to the Sentry MCP server (when configured in the editor) and should use it to investigate errors proactively while debugging.

## Single template — delete the lines that don't apply

The same skeleton covers all three project shapes. Delete the lines marked `[BACKEND]` for frontend-only repos, the lines marked `[FRONTEND]` for backend-only repos, and keep both for fullstack same-repo projects.

- **Backend + frontend in the same repo** — keep both `[BACKEND]` and `[FRONTEND]` lines.
- **Backend-only** (no TS frontend) — keep `[BACKEND]`, delete `[FRONTEND]`.
- **Frontend-only** (backend lives in a separate repo, e.g. `tropela-app` paired with `tropela-api`) — keep `[FRONTEND]`, delete `[BACKEND]`; there is no backend Sentry project in this repo.

```markdown
## Error monitoring (Sentry)

You have access to the Sentry MCP server. Use it to investigate errors proactively when debugging issues.

- **`regionUrl`**: [REGION_URL, defaults to https://de.sentry.io]
- **`organizationSlug`**: [ORG_SLUG]
[BACKEND] - **`projectSlugOrId`**: [BACKEND_PROJECT_SLUG]            ← backend service
[FRONTEND] - **`projectSlugOrId`**: [FRONTEND_PROJECT_SLUG]  ← Vue/TS app

When resolving issues, prefer **`resolvedInNextRelease`** over `resolved` — this signals the fix is in the next deployment rather than already live.

### Bug fix workflow

When a Sentry issue reveals a bug that is not covered by an existing test, always add a regression test before (or alongside) the fix:

1. **Reproduce first**: write a test that fails against the current code, confirming you have isolated the root cause.
2. **Fix the code**: make the test pass.
3. **Verify no new gaps**: confirm no related paths are left uncovered.

Never close a Sentry bug without a corresponding regression test. The fix lives in the code; the test ensures it stays fixed.
```

## Notes for the agent doing the migration

- Find the Sentry org / project / region from the project's Sentry dashboard, or from existing `.copilot/*.md` / `.github/instructions/*.instructions.md` files (`tropela-api`, `soigneur`, and `tropela-app` all carry these values in their `main.instructions.md`).
- `regionUrl` is the Sentry region URL (e.g. `https://de.sentry.io`, `https://us.sentry.io`). Omit it entirely for self-hosted Sentry where the org slug alone is enough.
- Keep the bug-fix workflow verbatim — it is the same across all projects in this organisation.
- If a frontend talks to the backend over HTTP, the backend Sentry project lives in the backend repo — do not duplicate backend project slugs in a frontend-only `AGENTS.md`.
