# Contributing

ResQTwin is intentionally small while the problem and architecture are being selected. Prefer evidence-backed, reversible additions over speculative scaffolding.

## Branches and commits

- Branch from current `main`.
- Use a descriptive branch such as `docs/problem-scope` or `feat/twin-state`.
- Keep each commit focused and reviewable.
- Use Conventional Commit subjects, for example:
  - `docs: record verified PS7 wording`
  - `feat: add synthetic observation model`
  - `test: cover stale observation fallback`
  - `ci: add MATLAB advisory checks`

## Decisions

Label proposals clearly. A design, tool, interface, or requirement becomes durable only when the team explicitly records it as **LOCKED**. A pull request must not silently turn an idea into an architectural commitment.

Team-wide decisions belong in tracked documentation under `docs/` or in the README. Local AI instruction files are deliberately ignored and are not a substitute for shared decisions.

## Pull requests

Every non-bootstrap change should use a pull request. Complete the template with:

- what changed and why;
- how it was verified;
- whether it proposes, implements, or changes a locked decision;
- data provenance and licence implications; and
- follow-up work that is intentionally deferred.

The `repository-safety` job must pass, and the branch must be current with `main`. Human review is optional. Automated AI review is also optional and is not a required status check.

## Validation

Before pushing:

```bash
git diff --check
bash -n path/to/changed-script.sh
```

Also inspect the complete staged diff. Add focused tests when executable behavior changes. Never weaken a check just to make a change pass.

## Repository hygiene

Do not commit:

- credentials, private keys, tokens, or local environment files;
- `AGENTS.md`, `CLAUDE.md`, `MEMORY.md`, or assistant-specific local state;
- MATLAB/Simulink caches, generated code, autosaves, or compiled artifacts;
- raw, processed, or generated datasets that belong in ignored local storage;
- large files that should use an approved artifact or data-storage mechanism; or
- third-party data/code without provenance and redistribution permission.

If a binary MathWorks source file is necessary, explain it in the pull request and keep a reviewable text description beside it.
