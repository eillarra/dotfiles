# FastAPI sections

Append these sections **on top of** `python.md` when the backend is FastAPI. Adapt the `<pkg>` placeholder to the actual import package name. Prune what doesn't apply.

## General

- Routers handle HTTP only: validate input (Pydantic), call a service, return a response. No business logic in routers — push it into `services/`.
- `services/` **must not** import from `routers/` / `api/` or the app entrypoint.
- Reusable `Depends` callables (current user, rate-limiter, feature flags) live in `<pkg>/api/dependencies/` or `<pkg>/core/dependencies.py`. Keep them pure and injectable — no business logic in them.

## ORM — Django

This organisation's FastAPI projects use the **Django ORM** for models and migrations (not SQLAlchemy / SQLModel / Tortoise / asyncpg). Django is used purely as the ORM layer alongside FastAPI.

- Models live in `<pkg>/models/` (Django models, grouped by domain). Business logic belongs in models or managers — "fat models, thin services/routers".
- Migrations live in `<pkg>/migrations/`. Never edit a shipped migration; create a new one with `python manage.py makemigrations <app>`.
- `DJANGO_SETTINGS_MODULE = "<pkg>.settings"` is set in `pyproject.toml`; Django is initialised before the FastAPI app starts (in `apps.py` / the entrypoint).
- Tests use `pytest-django` with the Django DB fixture; never the production DB.

### Async routes and the (sync) Django ORM

The Django ORM is synchronous. In FastAPI:

- **Sync route handlers** (`def`, not `async def`) run in a threadpool — safe to call the Django ORM directly.
- **Async route handlers** (`async def`) run on the event loop — a sync ORM call blocks it. Either declare the handler as `def` for ORM-heavy endpoints, or wrap ORM calls with `sync_to_async` / `run_in_threadpool`.

Do not write sync ORM queries directly inside `async def` handlers.

## Schemas

- Pydantic models in `<pkg>/schemas/` (or colocated with routers for small projects).
- Separate request / response schemas; do not reuse Django models directly as response models. Map via `model_config = ConfigDict(from_attributes=True)`.
- Keep Pydantic schemas as the API contract and Django models as the persistence layer — they evolve independently.

## Background tasks

[DROP ENTIRE SECTION IF NO WORKER.]

[ADAPT: arq is the default for async (used by soigneur). Replace with dramatiq / celery / rq / FastAPI `BackgroundTasks` as needed.]

- Long-running or scheduled work goes in `<pkg>/tasks/`.
- Schedule from services/routers via the task reference, not inline execution.
- Redis-backed in production; configure via settings.
- Tests must not execute real tasks — mock the enqueue call site.

## Settings

- `BaseSettings` subclass in `<pkg>/core/config.py` (or `<pkg>/settings.py`), env-driven, for FastAPI-side config.
- Django settings live in the Django settings module (referenced by `DJANGO_SETTINGS_MODULE`).
- Secrets from env vars (`.env` in dev, platform config in prod). Never hardcode.

## Entrypoint

- App instance constructed in `<pkg>/app.py` or `<pkg>/main.py` (or `__main__.py`).
- Lifespan / startup / shutdown handlers in `<pkg>/core/lifespan.py` or on the app factory.
- Django is set up before the FastAPI app starts (Django apps registry + settings).
- ASGI server: `uvicorn` (dev + prod) or `gunicorn -k uvicorn.workers.UvicornWorker` (prod).

## Commands (FastAPI-specific)

```
./run uvicorn <pkg>.app:app --reload              # dev server
./run python manage.py makemigrations <app>       # new Django migration
./run python manage.py migrate                    # apply migrations
./run python manage.py makemigrations --check <app>  # CI drift check
```

[ADAPT: drop `./run` prefix if no wrapper. Generic Python commands (pytest, ruff, mypy) are in `python.md` → "Commands"; do not repeat them here.]
