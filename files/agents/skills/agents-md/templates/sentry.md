# Sentry section

Always append unless project has no Sentry. Agent should use Sentry MCP (when configured) proactively while debugging.

## Single template — delete lines that don't apply

- Backend + frontend in same repo: keep both `[BACKEND]` / `[FRONTEND]` lines.
- Backend-only (no TS frontend): keep `[BACKEND]`, delete `[FRONTEND]`.
- Frontend-only (backend in separate repo): keep `[FRONTEND]`, delete `[BACKEND]`; no backend Sentry project here.

```markdown
## Error monitoring (Sentry)

You have access to the Sentry MCP server. Use it to investigate errors proactively when debugging issues.

- **`regionUrl`**: [REGION_URL, defaults to https://de.sentry.io]
- **`organizationSlug`**: [ORG_SLUG]
  [BACKEND] - **`projectSlugOrId`**: [BACKEND_PROJECT_SLUG] ← backend service
  [FRONTEND] - **`projectSlugOrId`**: [FRONTEND_PROJECT_SLUG] ← Vue/TS app

When resolving issues, prefer **`resolvedInNextRelease`** over `resolved` — fix ships with next deployment rather than already live.

### Bug fix workflow

Sentry issue reveals a bug not covered by existing test — add regression test before/alongside the fix:

1. Reproduce first: write failing test against current code, confirming root cause isolated.
2. Fix the code: make test pass.
3. Verify no related paths left uncovered.

Never close a Sentry bug without corresponding regression test.
```

## Notes

- Find org / project / region values from the project's Sentry dashboard or existing legacy instruction files.
- `regionUrl` = Sentry region URL (e.g. `https://de.sentry.io`); omit for self-hosted.
- Keep bug-fix workflow verbatim — same across all projects.
- Frontend-only repo: backend Sentry project lives in backend repo; don't duplicate slugs.
