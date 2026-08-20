# TypeScript sections

Append these sections for **any** TypeScript project (Vue, React, Svelte, plain TS library, Node service). Framework-specific sections (`vue.md`, etc.) are added on top. Prune what doesn't apply.

## General

- TypeScript is mandatory; no plain JS source.
- All function signatures use explicit types; no `any` without a justification comment explaining why a narrower type is impossible. Prefer `unknown` over `any` when accepting untrusted input; narrow it with type guards.
- Enable `strict` in `tsconfig.json`; do not relax compiler flags to silence a single error — fix the code.
- Prefer `interface` for object shapes that may be extended, `type` for unions and mapped types.

## Style

- Prettier + ESLint: config in `package.json` / `eslint.config.js` / `.prettierrc`.
- **Package manager:** yarn is the default for this organisation's frontends (yarn 4 via `corepack enable`). Run all frontend commands via `yarn` directly — the frontend is not run through `./run`. Only swap to npm / pnpm if the project genuinely uses them.
- Editor defaults: see `.editorconfig`.

## Testing (vitest)

We test **behaviour**, not functions. We test **boundaries**, not external libraries.

- All new code requires tests.
- Tests colocate as `*.spec.ts` next to the module under test (e.g. `vue/src/utils/format.spec.ts`). Never inline next to source.
- Structure tests using Arrange-Act-Assert.
- Mock external APIs / HTTP calls — never hit the backend or live services from unit tests.
- Coverage via `@vitest/coverage-v8`; config in `vitest.config.ts`.

### The "black box" rule

Test the public API of your modules. Do not test private methods or internal implementation details. If you refactor internal code but the output stays the same, tests should not break.

### The "not our code" rule

Assume external libraries work as advertised. Do not write tests to verify library behaviour.

- ❌ Testing the library: asserting that `date-fns(date).format()` returns a string tests `date-fns`, not us.
- ❌ Testing the mock: mocking a function and asserting it returns what you told it to return.
- ✅ Testing integration: asserting that _our_ code handles the library's success/failure correctly.

### Functionality over implementation

Test _what_ the result is, not _how_ we got it. Do not spy on internal method calls.

```typescript
// ❌ BAD: Brittle, tied to implementation
it('should call validateInput then calculateTax', () => {
  const spy1 = vi.spyOn(service, 'validateInput');
  service.processOrder(100);
  expect(spy1).toHaveBeenCalled();
});

// ✅ GOOD: Robust, tests behaviour
it('should return the total price including 20% tax', () => {
  const result = service.processOrder(100);
  expect(result.total).toBe(120);
});
```

### Boundary testing

When using external libraries, mock the **boundary**, not the logic. Test _our reaction_ to external success/failure.

```typescript
// ❌ BAD: Testing if our mock works
it('axios should return data', async () => {
  mockAxios.get.mockResolvedValue({ data: 'foo' });
  const result = await axios.get('/url');
  expect(result.data).toBe('foo');
});

// ✅ GOOD: Testing our error handling
it('should throw CustomLibError when the network fails', async () => {
  mockAxios.get.mockRejectedValue(new Error('Network Error'));
  await expect(myLibrary.fetchData()).rejects.toThrow(CustomLibError);
});
```

[Framework-specific testing (Vue composables, Quasar plugin mocking) lives in the framework sections — do not duplicate it here.]

## Things to avoid (TypeScript-specific)

- Do not commit `dist/`, `node_modules/`, build artifacts (see `.gitignore`).