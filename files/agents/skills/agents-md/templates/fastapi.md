# FastAPI sections

Append on top of `python.md` when backend is FastAPI. Adapt `<pkg>`; prune what doesn't apply.

## General

- Routers HTTP only: validate input (Pydantic), call service, return response. Business logic in `services/`.
- `services/` **must not** import from `routers/` / `api/` or app entrypoint.
- Reusable `Depends` callables (current user, rate-limiter, feature flags) in `<pkg>/api/dependencies/` or `<pkg>/core/dependencies.py`; pure, injectable, no business logic.

## ORM — Django

Django ORM only (no SQLAlchemy / SQLModel / Tortoise / asyncpg); Django is persistence layer alongside FastAPI.

- Models in `<pkg>/models/`, grouped by domain; business logic in models/managers.
- Migrations in `<pkg>/migrations/`. Never edit shipped migration — new one via `python manage.py makemigrations <app>`.
- `DJANGO_SETTINGS_MODULE = "<pkg>.settings"` in `pyproject.toml`; Django initialised before FastAPI app starts (`apps.py` / entrypoint).
- Tests: `pytest-django` DB fixture; never production DB.

### Async routes and the (sync) Django ORM

Django ORM is synchronous:

- `def` handlers run in threadpool — ORM calls safe.
- `async def` handlers run on event loop — sync ORM call blocks it. Use `def` for ORM-heavy endpoints, or wrap with `sync_to_async` / `run_in_threadpool`.

Never write sync ORM queries directly inside `async def` handlers.

## Schemas

- Pydantic models in `<pkg>/schemas/` (or colocated with routers in small projects).
- Separate request / response schemas; never Django models as response models — map via `model_config = ConfigDict(from_attributes=True)`. Schemas = API contract, models = persistence; evolve independently.

## Background tasks

[DROP ENTIRE SECTION IF NO WORKER.]

[ADAPT: arq is the default for async (used by soigneur). Replace with dramatiq / celery / rq / FastAPI `BackgroundTasks` as needed.]

- Long-running / scheduled work in `<pkg>/tasks/`; enqueue via task reference from services/routers, never inline. Redis-backed in production.
- Tests never execute real tasks — mock enqueue call site.

## Settings

- FastAPI config: env-driven `BaseSettings` subclass in `<pkg>/core/config.py` (or `<pkg>/settings.py`). Django settings in `DJANGO_SETTINGS_MODULE`.
- Secrets from env vars (`.env` dev, platform config prod); never hardcode.

## Entrypoint

- App in `<pkg>/app.py` / `<pkg>/main.py` (or `__main__.py`); lifespan handlers in `<pkg>/core/lifespan.py` or app factory; Django set up before app starts.
- ASGI: `uvicorn` (dev + prod) or `gunicorn -k uvicorn.workers.UvicornWorker` (prod).
