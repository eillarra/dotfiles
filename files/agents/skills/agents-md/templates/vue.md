# Vue sections

Append on top of `typescript.md`. Prune what doesn't apply.

## Stack

- Vue 3 Composition API; `<script setup lang="ts">` mandatory. No Options API, no `defineComponent({})` unless feature requires it.
- Pinia only for state. Quasar components + utility classes (`q-pa-md`, `row`, `col`) over native HTML / custom CSS.
- Build: Vite. [ADAPT: Quasar CLI if used.]
- Server glue: [ADAPT: Inertia (`@inertiajs/vue3`) — OR local `$page` shim + Vue Router — OR none (standalone SPA/PWA).]
- `@sentry/vue` when configured.

## Reactivity

- `shallowRef` for API data; replace `.value` wholesale, don't mutate nested fields.
- Expose read-only composable state via `readonly()`; writable refs internal.
- Fire-and-forget async: `unawaited()` helper if present, never bare `void`. [ADAPT: drop if no helper.]

## Code organisation for testability

- Complex logic out of `<script setup>`: pure functions in `utils/` (no Vue imports), stateful logic in `composables/`. Both isolated-testable.

## Form components

[DROP if none. One-line pointer at library README only.]

## Commands

```
corepack enable        # one-time
yarn                   # install deps
yarn dev               # dev server
yarn build             # production build
yarn lint              # eslint
yarn format            # prettier --write
yarn typecheck         # vue-tsc --noEmit
yarn test:unit         # vitest
```

## Testing (Vue-specific)

- Components: `@vue/test-utils` mounting; [ADAPT happy-dom / jsdom]. Mock axios / router / Quasar plugins; never hit backend.
- Composables: call directly, assert returned refs; no mounting needed.

## Things to avoid

- No API-calling logic in components — Pinia store or composable.
- No backend Python types in frontend — TS types in `types/`.
