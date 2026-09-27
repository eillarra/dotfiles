# MCP server sections

Append on top of `python.md` when backend is an MCP server (`mcp` Python SDK, `MCPServer`). Adapt `<pkg>`; prune what doesn't apply.

## Tools

- `MCPServer` instance in `<pkg>/__init__.py` (or `app.py`); tools in `<pkg>/tools/<name>.py` via `@mcp.tool()`, resources in `<pkg>/resources/` via `@mcp.resource()` (e.g. `hipeac://vision/{year}/{slug}`).
- Tools = thin wrappers (MCP equivalent of HTTP routers): validate input, call service, return structured result. Business logic in `services/`; `services/` / `models/` / `tasks/` **must not** import `tools/` or server entrypoint.
- Inputs / outputs as Pydantic models in `<pkg>/schemas/`; `structured_output=True`, `ToolAnnotations(readOnlyHint=True)` where appropriate.
- `@track_usage` (or project's analytics decorator) wraps tools. [ADAPT or drop if no analytics decorator.]

## MCP tool docstrings (critical)

Tool docstrings are sent verbatim to the LLM as the tool's prompt — not human docs:

- Opening line: _when_ to call ("Call this when…"), not what it returns.
- Body: how to interpret / act on result — fields to prioritise, decisions, what to avoid.
- `:param` lines: usage instructions, not descriptions.
- Direct second person ("use `complexity_level` to…"); no passive "Returns a list of…".

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

Django ORM only (no SQLAlchemy / SQLModel / Tortoise / asyncpg); Django is persistence layer alongside MCP server.

- Models in `<pkg>/models/`, grouped by domain; business logic in models/managers.
- `DJANGO_SETTINGS_MODULE = "<pkg>.settings"`; call `setup_django()` (`<pkg>/db.py`) once before any model use — also pre-populates content-type cache for async safety. [ADAPT: confirm setup helper name.]
- **Read-only DB: never create or run migrations, never write.** `ReadOnlyRouter` (`allow_migrate` → `False`, `db_for_write` → `None`) enforces it. [ADAPT: drop if project owns its migrations.]
- `CONN_MAX_AGE = 0` — connections not persisted across async thread-pool calls.

### Async tools and the (sync) Django ORM

Tool handlers are `async def` on the event loop; Django ORM is synchronous:

- Async ORM methods (`afirst()`, `acount()`, async iteration) or wrap sync calls with `sync_to_async`.
- **Call `ensure_connection_async()` (or equivalent) before DB operations in async contexts** — closes stale thread-local connections, prevents MySQL 2006/2026 after long AI/FAISS operations.
- Keep `DatabaseConnectionMiddleware` (or equivalent) on ASGI app — closes stale connections per request.
- **Never write sync ORM queries directly inside `async def` tool handlers.**

## Schemas

- Pydantic models in `<pkg>/schemas/`, grouped by domain. Schemas = tool contract, models = persistence; evolve independently. Map via `model_config = ConfigDict(from_attributes=True)`.

## Background tasks

[DROP ENTIRE SECTION IF NO WORKER.]

[ADAPT: huey is used by hipeac-mcp. Replace with arq / dramatiq / celery / rq as needed.]

- Long-running / scheduled work in `<pkg>/tasks.py` (or `<pkg>/tasks/`); enqueue via task reference from services/tools, never inline. Redis-backed in production.
- Tests never execute real tasks — mock enqueue call site.

## Settings

- Django settings in `<pkg>/settings.py` (minimal; read-only ORM config when DB is read-only).
- MCP HTTP path via `MCP_HTTP_PATH` env (default `/`). [ADAPT or drop.]
- Secrets from env vars (`.env` dev via `./run`, platform config prod); never hardcode.

## Entrypoint

- `<pkg>/server.py`: `mcp.streamable_http_app(...)` returns Starlette ASGI app; request middleware there. Served by gunicorn (`gunicorn <pkg>.server:app --config gunicorn.config.py`), uvicorn in dev.
- `<pkg>/__main__.py`: stdio transport for dev/CLI (`mcp.run(transport="stdio")`).
- `<pkg>/__init__.py`: builds `MCPServer`, inits Sentry (if configured), calls `setup_django()`, then imports `resources` + `tools` to register them.
