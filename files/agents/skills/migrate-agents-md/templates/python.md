# Python sections

Append these sections to the `main.md` skeleton for **any** Python project (library, Django, FastAPI, MCP server, scripts). Framework-specific sections (`django.md` / `fastapi.md` / `mcp.md`) are added on top. Adapt the `<pkg>` placeholder to the actual import package name; prune rows that don't apply.

## General

- All code must be PEP 8 compliant.
- All function signatures must use type hints.

## Docstring format (reStructuredText)

[ADAPT: some projects require reST docstrings for Sphinx; others use Google/NumPy style or none. Detect from existing code. If reST is the project convention, keep this section; otherwise replace with the project's style or drop.]

- All public functions, methods, and modules **must** have a docstring.
- Format must be reStructuredText (reST) to be compatible with Sphinx.
- Provide clear descriptions for parameters, return values, and any exceptions raised.
- Do not include type information — it is already in the function signature.
- All `:param`, `:returns`, and `:raises` descriptions must end with a period (`.`) for consistency.

```python
def get_user_by_id(user_id: int, is_active: bool = True) -> User | None:
    """Fetch a user from the database by their primary key.

    :param user_id: The primary key of the user to retrieve.
    :param is_active: If True, only search for active users.
    :returns: The User object or None if not found.
    :raises User.DoesNotExist: If no user with the given ID is found.
    """
    # ... function implementation ...
```

## Commands

```
./run pytest --cov=<pkg> --cov-report=term      # full test suite with coverage
./run ruff format .                              # format
./run ruff check <pkg>                           # lint (must be clean before commit)
./run mypy <pkg>                                 # type-check (if configured)
```

[ADAPT: drop `./run` prefix if no wrapper; drop mypy if not configured. Framework-specific commands (dev server, migrations, alembic, huey) live in the framework sections — do not repeat them here.]

## Testing (pytest)

We test **behaviour**, not functions. We test **boundaries**, not external libraries.

- All new code requires tests.
- Tests live in `tests/`, never inline next to source (no `tests.py` inside package modules).
- Structure tests using the Arrange-Act-Assert (AAA) pattern.
- Use `@pytest.fixture` for setup and `@pytest.mark.parametrize` for testing multiple inputs.
- Fixtures and factories: `tests/_factories/` (factory-boy), `tests/_helpers.py`, `tests/conftest.py`. Reuse them; do not redefine model factories per test.
- Anything touching the filesystem or external services must be guarded/mocked. Never hit the production DB or live APIs in tests.
- Coverage config lives in `pyproject.toml` (`[tool.coverage.*]`).

### Test-review workflow

When asked to review, audit, or add tests to existing code, apply this sequence:

1. **Read the tests first.** Critically evaluate each test: does the assertion actually verify the claimed behaviour, or is it trivially true? Are edge cases and failure paths covered? Are there implicit assumptions that could make the test fragile?
2. **Adjust the tests** to fix any identified weaknesses before running them.
3. **Run the adjusted suite.** A failing test after adjustment is valuable — it reveals a real bug in production code.
4. **Fix the production code** to make failing tests pass — never weaken a test to force it green.

[Framework-specific test patterns (Django markers, file-suffix conventions, permission-inheritance, test class naming) live in the framework sections — do not duplicate them here.]

## Ruff

- Ruff handles both linting and formatting. Config lives in `pyproject.toml`.
- Selected rule sets, `target-version`, `line-length`, and per-file ignores are declared there — do not inline-ignore without a justification comment.
- Run `ruff format . && ruff check <pkg>` (via `./run` if the wrapper exists) before committing. CI enforces a clean tree.