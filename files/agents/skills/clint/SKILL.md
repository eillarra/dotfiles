---
name: clint
description: >
    Multi-agent review — asks the same review question to N independent agents
    (default 3) in parallel, then merges: consensus findings, single-agent
    finds, and contradictions settled against the code. Speaks caveman terse
    style. Use when the user says "clint", "ask a few agents", "second opinion",
    "cross-check this review", or wants a good/bad/ugly audit with more coverage.
---

Clint. Same question, N reviewers, one verified verdict. Caveman terse always — inherit style, no announcing it.

## Step 1 — question & scope

- Args = the review question, verbatim. None → ask for it.
- Optional `xN` in args (e.g. `x5`) sets agent count; default 3, max 5.
- Infer scope paths from question + repo layout (one quick `ls`/grep). Don't read deeply yourself yet — keep own context unbiased.

## Step 2 — fan out

- Launch N agents in ONE message, in parallel. Read-only (`Explore` in plan mode, else `general-purpose` told "make no changes").
- Each gets: repo path, the question VERBATIM, scope paths, and the same report contract:
  findings grouped Good / Bad / Ugly; each = file:line, what, why it matters, concrete fix; quote decisive line; mark unverified.
- Vary only the lens per agent so coverage spreads (1: core infrastructure; 2: individual views/schemas, edge cases; 3: caching/auth/error paths + tests; 4+: performance/queries, consistency vs repo AGENTS.md). Never share prior findings with agents — independence is the point.
- Wait for all. Don't predict results.

## Step 3 — merge

- Dedupe by root cause, not wording.
- Tag each: `N/N agree`, `single (agent k)`, or `conflict`.
- Verify every single-agent find and every conflict yourself against code before reporting (read the line). Drop what doesn't hold; say it was dropped and why.
- Severity order: security, correctness bug, silent failure, performance, contract/consistency, style.

## Step 4 — report

Caveman-terse. Sections: Consensus, New (single-agent, verified), Rejected (claim + why wrong), Top N fix order. Each line with file:line. Security items in plain language (auto-clarity). Respect repo git rules (AGENTS.md) when suggesting branch vs main per fix.

## Step 5 — ask

Ask which fixes to start. Never edit code in this skill.
