# TypeScript sections

Append for any TypeScript project. Framework sections (`vue.md`) on top. Prune what doesn't apply.

## General

- TS mandatory, no plain JS. No `any` without justification comment; `unknown` + type guards for untrusted input.
- `strict` in `tsconfig.json`; never relax flags to silence error — fix code.
- `interface` for extensible object shapes, `type` for unions / mapped types.

## Style

- Prettier + ESLint (flat config `eslint.config.js`, `.prettierrc`); editor defaults `.editorconfig`.
- yarn 4 via corepack default; frontend commands via `yarn` directly, not `./run`. [ADAPT npm/pnpm.]

## Testing (vitest)

- All new code needs tests. [ADAPT: project's real convention — `__tests__/<name>.test.ts` next to module OR `*.spec.ts` colocated, matching vitest `include` pattern. Never inline.]
- Mock external APIs / HTTP; never hit backend or live services from unit tests.
- Philosophy, one line each: test behaviour + boundaries, not functions + mocks; test public API of modules, not internals; libraries work as advertised — test our reaction to their success/failure; never spy on internals.
- Coverage `@vitest/coverage-v8` if configured; vitest config [ADAPT location].

## Things to avoid

- Never commit `dist/`, `node_modules/`, build artifacts (see `.gitignore`).
