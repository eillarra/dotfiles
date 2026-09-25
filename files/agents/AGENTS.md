# Global agent guidance

## Specs (OpenSpec)

If the repo has an `openspec/` dir, it is project memory: `openspec/specs/` = current behaviour (source of truth), `openspec/changes/archive/` = why it got there.

- Read relevant `openspec/specs/<capability>/spec.md` before changing that behaviour.
- New feature / behaviour or API change: propose first (`openspec-propose`), no code until reviewed; implement via `openspec-apply-change`; archive (`openspec-archive-change`) once all tasks checked.
- Skip OpenSpec for bug fixes restoring specced behaviour, typos, dependency bumps, config, behaviour-neutral refactors.
- Ideas, lightest first: unscoped / not committed → entry in `openspec/ideas.md` under `#area`, origin noted; scoped but unplanned → draft change (`proposal.md` only, no `tasks.md`); `tasks.md` present = active. Promote idea → draft: create change, delete idea entry.
- Repo-local `openspec/` is globally gitignored (personal memory) — never commit or un-ignore it.
- Shared store: `openspec/config.yaml` has `store: <id>` → specs + changes live in a separate store repo, not here. CLI resolves it from this repo (`openspec context` prints path); read/edit spec files there and commit them in the store repo, not with code.
- No `openspec/` dir: when asked for a new feature or behaviour change, suggest `openspec init --tools none` before planning. Run it only if the user confirms.
