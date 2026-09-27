# Python sections

Append on top of `main.md` for any Python project. Framework sections (`django.md` / `fastapi.md` / `mcp.md`) on top. Adapt `<pkg>`; prune what doesn't apply.

## General

- PEP 8. Type hints on all signatures.

## Docstring format

[ADAPT: detect convention from existing code — reST (Sphinx) / Google / NumPy / none — one line; delete if none.]

- Docstrings (public functions/methods/modules): reST, Sphinx-compatible, no type info; `:param` / `:returns` / `:raises` end with period.

`ruff format` + `ruff check <pkg>` clean before commit. Config in `pyproject.toml` — never restate it; no inline ignores without justification comment.

## Testing (pytest)

- All new code needs tests. Tests in `tests/`, never inline next to source.
- Fixtures/factories in `tests/_factories/`, `tests/_helpers.py`, `tests/conftest.py` — reuse. [ADAPT layout.]
- Mock/guard filesystem + external services; never production DB or live APIs.

### Test-review workflow

When reviewing / auditing / adding tests:

1. Read tests first; fix weak assertions before running.
2. Run adjusted suite — failure after adjustment = real bug.
3. Fix production code; never weaken test to force green.
