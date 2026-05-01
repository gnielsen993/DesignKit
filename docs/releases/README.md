# Internal Release Logs

Per-version release notes for the **DesignKit** Swift Package. Scope =
anything that ships in a tagged version of the package.

Mirrors the convention used in the sibling repos (ParkedUp, GameKit,
FitnessTracker) so any AI session crossing repos sees the same shape.

## How to use

- Version source: **git tag** (semver, e.g. `v1.0.0`). DesignKit is a
  Swift Package — no `MARKETING_VERSION` exists. Consumers pin via
  `Package.swift` `from:` / `exact:`.
- Create one file per release: `vX.Y.Z.md`.
- Use [`TEMPLATE.md`](TEMPLATE.md) as the starting point.
- Keep entries factual, brief, bullet-pointed.
- For every significant change (new token / component / public API
  shift / behavior change / fix), append to the in-progress version's
  file in the same commit as the code change.
- A new release file is opened when the next intended tag changes
  (e.g. start landing v1.1.0 work → create `v1.1.0.md`).
- Tag the release commit only after the file is finalized and CI
  passes; the tag and the file land together.

## Semver in practice

- **patch** — bug fix, internal-only change, doc-only token tweak
- **minor** — additive: new tokens / new components / new presets,
  default-behavior changes that don't break existing consumers
- **major** — public API removed or renamed; preset semantic flip;
  default theme change that consumers can't ignore

## Sections in each file

- **Summary** — one or two sentences on the release theme
- **API changes** — public tokens / components / functions added,
  removed, renamed, or behavior-shifted
- **Internal changes** — refactors, file moves, test additions
- **Fixes** — bug fixes (with root cause when non-obvious)
- **Consumer migration notes** — what GameKit / FitnessTracker /
  HabitTracker / PantryPlanner need to do to absorb this version
- **Risks / notes** — visual regressions in specific presets, etc.
- **QA checklist** — pre-tag verification steps

## What NOT to put here

- Self-explanatory commits, comment tweaks, doc-only changes
- Per-file modification lists (commit history covers that)
- Anything that didn't actually ship in the tagged version

## Related artifacts

- Architecture doc: `Architecture_Constitution.md`
- Plan / roadmap: `Plan.md`, `Plan_EcosystemThemeSharing.md`
- Production theme notes: `PRODUCTION_THEME_NOTES.md`
- Recent commits: `git log --oneline -20`

## Entries

- `v1.0.0.md` — first stable tag (in progress)
