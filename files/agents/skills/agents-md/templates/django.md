# Django sections

Append on top of `python.md`. Adapt `<app>`; prune what doesn't apply.

## General

- Fat models, thin views; business logic in models/managers. [ADAPT: `services/` layer if the project uses one.]
- `select_related` / `prefetch_related` against N+1; `values()` / `values_list()` for few columns.
- Raw SQL only if ORM genuinely can't express query; then `Manager.raw()` / parameterised, never string interpolation.

## Migrations

- Never edit shipped migration — always create new via `makemigrations <app>`.
- Data migrations in own file, reversible where possible.
- Drift check: `makemigrations --check <app>`.

## API

[DROP if no HTTP API. Versioning by URL prefix `/api/v{N}/`; JSON, ISO 8601 UTC dates, ISO 3166-1 alpha-2 country codes; errors `{"detail": "..."}` — confirm against project. Contract docs in `docs/` — update on endpoint changes.]

### DRF variant

- Every viewset registered in `<app>/api/routers.py` with explicit `basename`.

### Native views + Pydantic variant

- Plain function views with project decorators — real names from `<app>/api/`, don't guess. Pydantic schemas, no DRF serializers.
- Public endpoints: no auth, `Cache-Control` caching. Private: token auth. [ADAPT from code.]

Commands: `./run server`, `./run huey`, `./run python manage.py migrate`. [ADAPT: drop `./run` if no wrapper, huey if no queue. Makemigrations lives in Migrations above; pytest/ruff in `python.md`.]

## Testing (Django-specific)

- Markers: [ADAPT: e.g. `api`, `site`, `slow`, `unit` — each with one-line purpose].

### Test file naming suffixes

`_permissions.py` (access by role), `_api.py` (API behaviour), `_serializers.py` (serializer/schema validation), `_validation.py` (validation, business rules), no suffix (model/service/mixed). [ADAPT: keep only suffixes the repo uses.]

### Permission tests (inheritance pattern)

`TestForAnonymous` defines full `expected_status_codes` dict + endpoint tests. `TestForAuthenticated` subclasses it, force-authenticates in autouse fixture. `TestForOwner` subclasses that, overrides status codes only (CRUD allowed). Extend with `TestForManager` / `TestForStaff`. [ADAPT auth mechanism + fixture names from project.]

Class naming: permission `TestForAnonymous` / `TestForAuthenticated` / `TestForOwner` / `TestForManager` / `TestForStaff`; behaviour `TestJobCreate`; serializers `TestJobSerializer`.
