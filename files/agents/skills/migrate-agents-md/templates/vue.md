# Vue sections

Append these sections **on top of** `typescript.md` when the frontend is Vue 3. Prune what doesn't apply.

## Stack

- **Vue 3** with the Composition API — `<script setup lang="ts">` is mandatory. No Options API.
- **State management:** Pinia is the only state management library.
- **Component library:** Quasar. Prefer Quasar components (`<q-btn>`) over native HTML; use Quasar utility classes (`q-pa-md`, `row`) instead of custom CSS.
- **Build / dev server:** Vite. [ADAPT: some projects use Quasar CLI — check `quasar.config.ts` vs `vite.config.ts`.]
- **Server-rendered glue:** Inertia.js when the backend lives in the same repo (Django+Vue). Standalone SPA/PWA when the frontend is a separate repo (e.g. `tropela-app` paired with `tropela-api`).
- **Sentry:** `@sentry/vue` when configured. [Cross-reference the Sentry section in `AGENTS.md`.]
- Package manager: yarn 4 (Berry; `corepack enable` then `yarn`). [ADAPT: npm / pnpm if the project uses them.]

[ADAPT: the two shapes above (Inertia same-repo vs standalone separate-repo) change which layout the project uses. The agent reads the repo (`vue/src/apps/<area>/` for Inertia, `src/pages/` for standalone Quasar) — do not duplicate the directory structure here.]

## Reactivity best practices

### Choosing the right ref type

| Type | Use for | Example |
| :--- | :--- | :--- |
| `ref` | Primitives, small objects where deep reactivity is needed | `ref(0)`, `ref({ name: '' })` |
| `shallowRef` | Large arrays, objects from API responses | `shallowRef<User[]>([])` |
| `readonly` | Exposing state that should not be mutated | `readonly(state)` in composables |

### Guidelines

- **API responses:** always use `shallowRef` for data fetched from APIs to avoid the performance cost of deep reactivity.
- **Updating `shallowRef`:** always replace the `.value` entirely — do not mutate nested fields.
- **Fire-and-forget async:** use the project's `unawaited()` helper (or equivalent) for fire-and-forget calls — never use `void` directly. [ADAPT: confirm the helper exists; drop this line if the project has no such helper.]
- Expose read-only state from composables via `readonly()`; keep the writable ref internal.

## Component structure

- **File order:** follow the order already used in the repo's existing components — do not mix `<template>` / `<script setup>` / `<style scoped>` orders within the same project. [ADAPT: state the project's actual order here, e.g. `<style scoped>` → `<template>` → `<script setup>`.]
- **Naming:** `PascalCase.vue` for components, `useSomething.ts` for composables.
- **Quasar:** prefer Quasar components (`<q-btn>`, `<q-input>`, …) over native HTML. Use Quasar utility classes (`q-pa-md`, `row`, `col`) instead of custom CSS wherever possible.
- **`<script setup lang="ts">`** is mandatory — no Options API, no `defineComponent({})` unless a specific feature requires it.

## Code organisation for testability

- **Pure functions** (`utils/`): stateless, no Vue imports. Testable in isolation.
- **Composables** (`composables/`): stateful, use Vue reactivity. Tested by calling the composable and asserting on returned refs.
- Do not write complex transformation logic inside `<script setup>`. Extract it to a pure function (utils) or a composable so it can be tested in isolation.

## Form components

[DROP THIS SECTION IF THE PROJECT HAS NO FORM COMPONENT LIBRARY. Point at its README instead — do not duplicate the spec in `AGENTS.md`. Example pointer for hipeac-style projects:]

- Form components library: `vue/src/components/forms/README.md`. Two variants exist (`v-model` for create flows, `Api` for edit flows); see the README.

## Commands (Vue-specific)

```
corepack enable        # one-time, enables yarn 4
yarn                   # install deps
yarn dev               # vite dev server (Inertia hot reload)
yarn build             # production build
yarn lint              # eslint
yarn format            # prettier --write
yarn test:unit         # vitest
```

[The yarn-default note and command-running policy live in `typescript.md` → "Style"; do not duplicate them here. Vue-specific commands only.]

## Testing (Vue-specific)

- Use `@vue/test-utils` for component mounting; `happy-dom` for the DOM environment.
- Mock axios / Inertia router / Quasar plugins as needed — never hit the backend from unit tests.
- **Composables** usually do not need to be mounted in a component — call the composable directly and assert on the returned refs.

```typescript
describe('usePagination', () => {
  it('navigates to the next page', () => {
    const { page, nextPage } = usePagination({ total: 100 });
    nextPage();
    expect(page.value).toBe(2);
  });
});
```

[The framework-agnostic testing philosophy (black box, not-our-code, functionality-over-implementation, boundary testing) lives in `typescript.md` → "Testing (vitest)"; do not duplicate it here.]

## Things to avoid (Vue-specific)

- Do not put API-calling business logic in components — push it into a Pinia store or composable.
- Do not import backend Python types into the frontend; maintain TS types in `types/`.