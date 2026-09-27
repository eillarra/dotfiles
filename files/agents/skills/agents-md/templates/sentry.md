# Sentry section

Always append unless project has no Sentry. Agent should use Sentry MCP (when configured) proactively while debugging.

## Single template — delete lines that don't apply

- Backend + frontend in same repo: keep both `[BACKEND]` / `[FRONTEND]` slugs.
- Backend-only (no TS frontend): keep `[BACKEND]`, delete `[FRONTEND]`.
- Frontend-only (backend in separate repo): keep `[FRONTEND]`, delete `[BACKEND]`; no backend Sentry project here.

```markdown
## Error monitoring (Sentry)

Use the Sentry MCP server to investigate errors proactively when debugging.

- **`regionUrl`**: [REGION_URL, defaults to https://de.sentry.io]
- **`organizationSlug`**: [ORG_SLUG]
- **`projectSlugOrId`**: [BACKEND] `[BACKEND_PROJECT_SLUG]` (backend service), [FRONTEND] `[FRONTEND_PROJECT_SLUG]` (Vue app)

Prefer **`resolvedInNextRelease`** over `resolved` — fix ships with next deployment.

### Bug fix workflow

Sentry issue reveals a bug not covered by an existing test — add regression test before/alongside the fix:

1. Reproduce first: failing test against current code, confirming root cause.
2. Fix code to pass.
3. Verify no related paths left uncovered.

Never close a Sentry bug without a corresponding regression test.
```

## Notes

- Find org / project / region values from the project's Sentry dashboard or existing legacy instruction files.
- `regionUrl` = Sentry region URL (e.g. `https://de.sentry.io`); omit for self-hosted.
- Keep all three bug-fix steps + closing rule — same across all projects.
- Frontend-only repo: backend Sentry project lives in backend repo; don't duplicate slugs.
