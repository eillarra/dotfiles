# Django sections

Append these sections **on top of** `python.md` when the backend is Django. Adapt the `<app>` placeholder to the actual Django app label. Prune what doesn't apply.

## General

- Follow the "Fat Models, Thin Views" principle. Business logic belongs in models or managers; views stay thin. [ADAPT: some projects in this org push logic into a `services/` layer instead — detect from existing code and stay consistent.]
- Prefer Class-Based Views / ViewSets over function-based views (DRF projects).
- Use the ORM efficiently. Prevent N+1 with `select_related` (FK / one-to-one) and `prefetch_related` (M2M / reverse). Prefer `values()` / `values_list()` when you only need a few columns.
- Avoid raw SQL unless the ORM genuinely cannot express the query efficiently — and even then, prefer `Manager.raw()` or parameterised queries over string-interpolated SQL.

## Migrations

- Never edit a shipped migration. Always `makemigrations <app>` to create a new one.
- Data migrations go in their own migration file; keep them reversible where possible.
- Run `python manage.py makemigrations --check <app>` in CI to catch drift. [ADAPT: drop the CI line if not set up.]

## API

[DROP ENTIRE SECTION IF NO HTTP API.]

### Common

- All public endpoints live under `/api/v{version}/` (current: `v{N}`). Versioning is by URL prefix, not header.
- Response format: JSON, ISO 8601 UTC dates, ISO 3166-1 alpha-2 country codes. Errors use `{"detail": "..."}` (or the project's error envelope — confirm).
- See `docs/` for the public contract. When you change a public endpoint, update the relevant `docs/` file.

### DRF variant (if the project uses Django REST Framework)

- `DefaultRouter` (or the project's `Router` subclass) is defined in `<app>/api/routers.py`; every viewset must be registered there with an explicit `basename`.
- Serializers in `<app>/api/serializers/`, filters in `<app>/api/filters/`, permissions in `<app>/api/permissions/`.

### Native views + Pydantic variant (if the project removed DRF)

- Views are plain Django functions decorated with the project's view decorators (e.g. `@public_api_view`, `@private_api_view`). Confirm the actual decorator names from `<app>/api/`.
- Validation and serialization via Pydantic schemas — not DRF serializers.
- Public endpoints: no auth, HTTP caching via `Cache-Control` (`max-age` / `s-maxage`).
- Private endpoints: token auth via `Authorization: Token <session_key>` (or whatever the project uses).
- [ADAPT: read `<app>/api/` to learn the exact decorators and conventions; do not guess.]

## Commands (Django-specific)

```
./run server                                     # Django dev server
./run huey                                       # huey worker (if queue exists)
./run python manage.py makemigrations <app>      # new migration
./run python manage.py migrate                   # apply migrations
./run python manage.py makemigrations --check <app>  # CI drift check
```

[ADAPT: drop `./run` prefix if no wrapper; drop the huey line if no queue. Generic Python commands (pytest, ruff) are in `python.md` → "Commands"; do not repeat them here.]

## Testing (Django-specific patterns)

[Extends `python.md` → "Testing (pytest)" and `main.md` → "Test conventions". Django-specific only.]

- Backend settings module: `DJANGO_SETTINGS_MODULE = "<app>.settings.test"` (already set in `pyproject.toml`).
- Markers: `@pytest.mark.api`, `@pytest.mark.site`, `@pytest.mark.slow` (e.g. WeasyPrint PDF rendering). [ADAPT to the project's actual markers.]

### Test file naming suffixes

Test files are named to indicate what aspect they test:

| Suffix | Purpose | Example |
| --- | --- | --- |
| `_permissions.py` | Permission / access-control tests by user role | `test_jobs_permissions.py` |
| `_api.py` | API behaviour tests (CRUD, response format) | `test_jobs_api.py` |
| `_serializers.py` | Serializer / schema field validation, read/write behaviour | `test_registration_serializers.py` |
| `_validation.py` | Input validation and business-rule tests | `test_coupon_validation.py` |
| (no suffix) | Model tests, service tests, or mixed tests | `test_jobs.py`, `test_payments.py` |

### Permission tests (inheritance pattern)

For HTTP API endpoints, use an inheritance pattern to cover permission levels consistently:

```python
@pytest.mark.api
class TestForAnonymous:
    """Tests for anonymous users."""

    expected_status_codes: dict[str, status] = {
        "list": status.OK,
        "create": status.FORBIDDEN,
        "retrieve": status.OK,
        "update": status.FORBIDDEN,
        "delete": status.FORBIDDEN,
    }

    def test_list(self, api_client, resource):
        response = api_client.get(url)
        assert response.status_code == self.expected_status_codes["list"]


class TestForAuthenticated(TestForAnonymous):
    """Tests for authenticated users (no special permissions)."""

    @pytest.fixture(autouse=True)
    def setup(self, api_client, t_user):
        api_client.force_authenticate(user=t_user)


class TestForOwner(TestForAuthenticated):
    """Tests for resource owners."""

    expected_status_codes = {
        "list": status.OK,
        "create": status.CREATED,
        "retrieve": status.OK,
        "update": status.OK,
        "delete": status.NO_CONTENT,
    }
```

[ADAPT: the exact `force_authenticate` mechanism and fixture names depend on the project. For native-view (non-DRF) projects, replace `api_client` with the project's test client and `force_authenticate` with the project's auth helper.]

### Test class naming

- **Permission tests**: `TestForAnonymous`, `TestForAuthenticated`, `TestForOwner`, `TestForManager`, `TestForStaff`.
- **Behaviour tests**: `TestJobCreate`, `TestJobUpdate`, `TestCouponValidation`.
- **Serializer/schema tests**: `TestJobSerializer`, `TestRegistrationSerializer`.