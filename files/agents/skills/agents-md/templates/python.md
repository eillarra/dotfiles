# Python sections

Append on top of `main.md` for any Python project. Framework sections (`django.md` / `fastapi.md` / `mcp.md`) on top. Adapt `<pkg>`; prune what doesn't apply.

## General

- PEP 8. Type hints on all signatures.

## Docstring format

[ADAPT: detect convention from existing code — reST (Sphinx) / Google / NumPy / none — one line; delete if none.]

- Docstrings required on public functions, methods, modules.
- Format: reST, Sphinx-compatible. No type info in docstrings (signatures carry it); `:param` / `:returns` / `:raises` end with period.

## Commands

```
./run pytest --cov=<pkg> --cov-report=term
./run ruff format .
./run ruff check <pkg>          # clean before commit
```

[ADAPT: drop `./run` if no wrapper. Framework commands in framework sections.]

## Testing (pytest)

- All new code needs tests. Tests in `tests/`, never inline next to source.
- Shared fixtures/factories in `tests/_factories/`, `tests/_helpers.py`, `tests/conftest.py` — reuse, don't redefine. [ADAPT layout.]
- Mock/guard filesystem + external services; never hit production DB or live APIs.
- Coverage config: [ADAPT, e.g. `pyproject.toml` `[tool.coverage.*]`].

### Test-review workflow

When asked to review / audit / add tests:

1. Read tests first; fix weak assertions before running.
2. Run adjusted suite — failure after adjustment means real bug.
3. Fix production code; never weaken test to force green.

## Ruff

Lint + format via Ruff; config in `pyproject.toml` (`target-version`, `line-length`, rules, per-file ignores). No inline-ignores without justification. `ruff format . && ruff check <pkg>` before commit; CI enforces clean tree.
