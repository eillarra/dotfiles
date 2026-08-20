# MCP server sections

Append these sections **on top of** `python.md` when the backend is an MCP server (`mcp` Python SDK, `MCPServer`). Adapt the `<pkg>` placeholder. Prune what doesn't apply.

## General

- Tool handlers are the MCP-protocol equivalent of HTTP routers: validate input (Pydantic), call a service, return a structured result. No business logic in tool bodies — push it into `services/`.
- `services/` **must not** import from `tools/` or the server entrypoint.
- The `MCPServer` instance is constructed in `<pkg>/__init__.py` (or `app.py`); tools and resources are registered there via `@mcp.tool()` / `@mcp.resource()`.

## Tool definitions

- Tools live in `<pkg>/tools/<name>.py` and are registered on the `MCPServer` instance via `@mcp.tool()`.
- Each tool is a thin wrapper: validate inputs, call a service, return a structured result. No business logic in tool bodies — push it into `services/`.
- Tool inputs and outputs use Pydantic models (`<pkg>/schemas/`) for type safety and auto-generated schemas. Use `structured_output=True` and `ToolAnnotations(readOnlyHint=True)` where appropriate.
- MCP resources live in `<pkg>/resources/` (e.g. `hipeac://vision/{year}/{slug}`).
- `@track_usage` (or the project's analytics decorator) wraps tools for usage analytics. [ADAPT or drop if the project has no analytics decorator.]

## MCP tool docstrings (critical)

MCP tool docstrings are **not** documentation for human developers — they are instructions sent verbatim to the LLM as the tool's system prompt. Write them accordingly:

- **Opening line**: tell the model *when* to call the tool ("Call this when…"), not what it returns.
- **Body**: explain how to *interpret and act on* the result — which fields to prioritise, what decisions to make, what to avoid.
- **`:param` lines**: keep these as usage instructions (how to call correctly), not prose descriptions.
- **Avoid passive voice** like "Returns a list of…" — the model already sees the return type.
- **Tone**: direct second-person ("use `complexity_level` to…", "never persist without…").

Example:

```python
@mcp.tool(structured_output=True, annotations=ToolAnnotations(readOnlyHint=True))
async def search_standings(race_id: str, complexity_level: str = "all") -> list[StandingSchema]:
    """Call this when the user asks for race standings, rankings, or positions.

    Use `complexity_level` to narrow to a difficulty tier (`all`, `easy`, `hard`).
    Prioritise the `position` and `points` fields; ignore `evo` unless the user
    explicitly asks about movement. Never present standings without the race name.
    """
    return await services.standings.search(race_id, complexity_level)
```

## ORM — Django

[DROP ENTIRE SECTION IF THE MCP SERVER DOES NOT USE THE DJANGO ORM.]

This organisation's MCP servers use the **Django ORM** for models (not SQLAlchemy / SQLModel / Tortoise / asyncpg). Django is used purely as the ORM layer alongside the MCP server.

- Models live in `<pkg>/models/` (Django models, grouped by domain). Business logic belongs in models or managers — "fat models, thin tools/services".
- `DJANGO_SETTINGS_MODULE = "<pkg>.settings"`; call `setup_django()` (from `<pkg>/db.py`) once before any model use. It also pre-populates the content-type cache for async safety. [ADAPT: confirm the setup helper name.]
- **Never create or run migrations in this repo if the database is read-only.** A `ReadOnlyRouter` returning `False` from `allow_migrate` / `None` from `db_for_write` enforces this — there are no migrations to edit. [ADAPT: drop this bullet if the project owns its migrations.]
- `CONN_MAX_AGE = 0` — connections are not persisted across async thread-pool calls.

### Async tools and the (sync) Django ORM

The Django ORM is synchronous. MCP tool handlers are `async def` and run on the event loop.

- Use async ORM methods (`afirst()`, `acount()`, async queryset iteration) or wrap sync ORM calls with `sync_to_async`.
- **Call `ensure_connection_async()` (or equivalent) before DB operations in async contexts.** It closes stale thread-local connections and prevents transient MySQL errors (2006/2026) after long-running AI/FAISS operations.
- A `DatabaseConnectionMiddleware` (or equivalent) that closes stale connections before/after each request should be kept on the ASGI app — do not remove it.
- **Do not write sync ORM queries directly inside `async def` tool handlers.**

## Schemas

- Pydantic models in `<pkg>/schemas/` (grouped by domain).
- Keep Pydantic schemas as the tool contract and Django models as the persistence layer — they evolve independently. Map via `model_config = ConfigDict(from_attributes=True)` where needed.

## Background tasks

[DROP ENTIRE SECTION IF NO WORKER.]

[ADAPT: huey is used by hipeac-mcp. Replace with arq / dramatiq / celery / rq as needed.]

- Long-running or scheduled work goes in `<pkg>/tasks.py` (or `<pkg>/tasks/`).
- Schedule from services/tools via the task reference, not inline execution.
- Redis-backed in production; configure via settings.
- Tests must not execute real tasks — mock the enqueue call site.

## Settings

- Django settings in `<pkg>/settings.py` (minimal, read-only ORM config when the DB is read-only).
- MCP HTTP path via `MCP_HTTP_PATH` env (default `/`). [ADAPT or drop.]
- Secrets from env vars (`.env` in dev via `./run`, platform config in prod). Never hardcode.

## Entrypoint

- ASGI app in `<pkg>/server.py`: `mcp.streamable_http_app(...)` returns a Starlette ASGI app; add request middleware there (e.g. a `DatabaseConnectionMiddleware` that closes stale Django connections per request). Served by gunicorn (`gunicorn <pkg>.server:app --config gunicorn.config.py`) or uvicorn in dev.
- `<pkg>/__main__.py` runs the MCP server via stdio transport (dev/CLI): `mcp.run(transport="stdio")`.
- `<pkg>/__init__.py` constructs the `MCPServer` instance, initialises Sentry (if configured), calls `setup_django()`, then imports `resources` and `tools` to register them.

## Commands (MCP-specific)

[ADAPT: reflect the actual entrypoint from `Procfile*` / `run` / `Dockerfile`. Drop `./run` prefix if no wrapper. Generic Python commands (pytest, ruff, mypy) are in `python.md` → "Commands"; do not repeat them here.]

```
./run python -m <pkg>                                       # run MCP server via stdio (dev/CLI)
./run gunicorn <pkg>.server:app --config gunicorn.config.py # prod ASGI
./run huey_consumer <pkg>.tasks.huey -w 2 -q                # huey worker (if queue exists)
./run python manage.py <command>                            # Django management commands (indexing, etc.)
```

## Things to avoid (MCP-specific)

- Do not import `tools/` or the server entrypoint from `services/`, `models/`, or `tasks/`.
- Do not create migrations or attempt writes if the database is read-only by router.