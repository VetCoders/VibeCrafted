---
name: vetcoders-prune
description: >
  Repository pruning and runtime cone extraction skill. Use when the team wants
  to strip a large AI-grown repo down to the code that actually participates in
  runtime, separate product code from tooling, archives, experiments, agent
  exhaust, reports, and stale surfaces, or plan a safe staged cleanup without
  breaking boot, build, packaging, or core user flows. Trigger phrases:
  "prune repo", "sprzatanie repo", "obierz repo", "strip non-runtime",
  "remove cruft", "cleanup architecture", "runtime cone", "odchudz repo",
  "co mozna usunac", "what can we delete", "safe repo cleanup",
  "trim the tree", "living tree cleanup".
---

# vetcoders-prune - Runtime Cone Pruning

> A repo is a living tree.
> Keep the trunk, cut the scaffolding, archive the fossils.

This skill answers a narrower and more useful question than "what looks messy?":
what code, files, and directories are required for runtime truth, and what only
exists because the repo kept absorbing tools, experiments, reports, and history.

The goal is not cosmetic cleanup.
The goal is to reduce the product surface until runtime, build, and QA are
explicit and defendable.

## Core Contract

- Use loctree as the first exploration layer.
- Define the runtime cone before proposing deletes.
- Classify every candidate as `KEEP-RUNTIME`, `KEEP-BUILD`, `KEEP-QA`,
  `MOVE-ARCHIVE`, `DELETE-NOW`, or `VERIFY-FIRST`.
- Prefer quarantine, branch-archive, or staged removal before hard delete when
  confidence is not high.
- Run gates after every pruning wave.
- Treat runtime leaks from dev-only code as high-priority cleanup.

## The Pruning Classes

| Class | Meaning | Action |
|------|---------|--------|
| `KEEP-RUNTIME` | Participates directly or transitively in app runtime | Keep; refactor separately if ugly |
| `KEEP-BUILD` | Required to build, package, sign, bundle, or release | Keep; do not delete with runtime cuts |
| `KEEP-QA` | Required to verify behavior, smoke flows, or release confidence | Keep; possibly move later, not in first prune |
| `MOVE-ARCHIVE` | Historical but still worth preserving outside main working tree | Move to archive branch, external repo, or attic |
| `DELETE-NOW` | Generated, disposable, reproducible, or obviously dead | Delete directly |
| `VERIFY-FIRST` | Suspicious, possibly dead, but dynamic imports/registries/config may still reach it | Prove with impact + grep + gates before removal |

## Workflow

### Phase 1 - Establish Runtime Truth

Start by declaring what "runtime" means for this repo:

- Desktop app, web app, CLI, library, or mixed surface
- Primary entrypoints
- Mandatory user flows that must still work after pruning
- Packaging/build path that must stay intact

For a Tauri + Vite repo, usually inspect:

- Frontend entrypoints such as `src/main.tsx` and `src/App.tsx`
- Backend entrypoints such as `src-tauri/src/main.rs` and `src-tauri/src/lib.rs`
- Tauri config such as `src-tauri/tauri.conf.json`
- Build scripts referenced by `beforeDevCommand`, `beforeBuildCommand`,
  bundling resources, and package scripts

Use shell-level evidence for build truth:

```bash
rg -n "before(Build|Dev)Command|frontendDist|resources" src-tauri/tauri.conf.json*
rg -n '"(dev|build|test|lint|tauri:dev|tauri:build)"\\s*:' package.json
```

Do not start with "unused exports".
Start with "what must boot".

### Phase 2 - Map the Runtime Cone

Build the transitive runtime cone from the true entrypoints outward.

Use loctree in this order:

```text
repo-view(project)
slice(file="src/App.tsx", consumers=true)
slice(file="src-tauri/src/lib.rs", consumers=true)
focus(directory="src")
focus(directory="src-tauri/src")
follow(scope="all") when cycles, hotspots, or twins look relevant
impact(file=<candidate>) before deleting any non-obvious file
find(mode="who-imports", name=<candidate>) for reverse dependency checks
```

Evidence that something is runtime-critical includes:

- Imported from a real entrypoint
- Registered in router, providers, command registries, plugin registries, event
  bridges, or background job setup
- Referenced from build/bundle config
- Required by smoke flows the product cannot lose

Evidence that something is not runtime includes:

- Generated artifacts
- Reports, logs, review packs, or screenshots
- Agent memory and session residue
- Playground or prototype code not referenced by build or packaging
- Archived docs or superseded experiments

### Phase 3 - Classify the Repo Surface

Classify root directories before diving into leaf files.
This prevents wasting time micro-pruning a subtree that should simply move out.

Typical early classifications in AI-grown repos:

- Usually `DELETE-NOW`:
  `dist/`, `playwright-report/`, logs, cached outputs, generated proof artifacts
- Usually `MOVE-ARCHIVE`:
  `.ai-*`, `.codex/`, `.claude/`, `.junie/`, `.trash/`, `.attic/`,
  `docs/archive/`, prototype folders, abandoned landing experiments
- Usually `KEEP-BUILD`:
  `.github/workflows/`, packaging scripts, release scripts, bundle resources
- Usually `KEEP-QA`:
  `e2e/`, `tests/`, smoke scripts, fixtures, test harnesses
- Usually `VERIFY-FIRST`:
  `devtools/`, Storybook hooks, browser mocks, preview shims, alternate app
  shells, duplicate engines, legacy adapters, vendor folders, manifest generators

Do not assume `scripts/` is trash.
In messy repos, `scripts/` often contains half the actual build contract.

### Phase 4 - Prune in Waves

Never do the whole cleanup in one cut.
Prune in waves from safest to riskiest.

#### Wave 0 - Disposable Surface

Remove generated and reproducible output first:

- build outputs
- report folders
- logs
- cached artifacts
- stale screenshots and preview outputs

This wave should not change runtime at all.

#### Wave 1 - Agent Exhaust and Archaeology

Move or remove:

- agent session folders
- planning/report residue
- superseded prototypes
- attic/trash buckets inside the repo
- archived docs that are no longer part of the working product surface

This wave reduces noise for all later analysis.

#### Wave 2 - Dev-Only Bleed Into Runtime

Look for code that exists only for local hacking but leaks into the main app path:

- browser mocks imported by default
- preview-only providers in app entrypoints
- dual shells and duplicate startup paths
- env-gated branches with broad permanent imports

These are high-value cuts because they sharpen the boundary between product and
debug scaffolding.

#### Wave 3 - Unreachable Product Surface

Now prune inside `src/` and `src-tauri/src/`:

- unmounted routes
- unregistered commands
- panels no live route reaches
- duplicate services
- stale fallback systems retained after migration
- feature folders that survive only through legacy glue

Use the dead parrots rule here:
if a subtree exists only to support a removed path, delete the whole subtree
instead of trimming leaves forever.

#### Wave 4 - Contract Tightening

After removals, clean the references that still point at deleted surface:

- package scripts
- CI workflows
- manifests
- docs indexes
- test matrices
- import aliases
- release and setup scripts

If you skip this wave, the repo still behaves as if dead code is alive.

### Phase 5 - Verify

After each wave, run the closest safe gates for the repo.

For mixed TypeScript + Rust desktop repos, prefer:

```bash
semgrep --config auto --error --quiet src src-tauri/src e2e tests scripts .github/workflows
pnpm build
cargo clippy --manifest-path src-tauri/Cargo.toml -- -D warnings
pnpm test:e2e:ts
```

Add targeted tests for the surfaces touched in the wave.
Run at least one cross-pipeline smoke flow after any structural pruning.

## Evidence Rules

Use this hierarchy when deciding whether a candidate can go:

1. `impact(file)` and `who-imports` say nothing consumes it
2. `rg` finds no config, script, glob, or manifest reference
3. No dynamic import, registry, or env-gated path points to it
4. Build still passes
5. One real smoke flow still passes

If only rules 1-2 are true, classify as `VERIFY-FIRST`.
If all five are true, deletion is usually safe.

Static tools are hints, not verdicts.
`knip`, `madge`, dead-export scanners, and "unused file" heuristics help, but
they do not understand runtime registries, Tauri commands, or dynamic imports by
themselves.

## Output Format

Use this exact top-level structure in the final response:

```text
Current state: <what is bloated, mixed, or leaking>
Proposal: <target repo shape and why it is safer>
Migration plan: <ordered pruning waves>
Quick win: <one immediate high-impact cleanup>
```

Then include:

- Runtime cone summary
- `KEEP/MOVE/DELETE/VERIFY` classification list
- Wave plan with blast radius
- Gate results
- Open risks and what still needs proof

## Integration with VetCoders Pipeline

Use this flow for major cleanup:

```text
vetcoders-init -> vetcoders-prune -> vetcoders-followup -> vetcoders-marbles
```

- `vetcoders-init` gives memory plus structure
- `vetcoders-prune` defines the cone and removes non-runtime surface
- `vetcoders-followup` verifies runtime truth after the cuts
- `vetcoders-marbles` loops if residual P1/P2 chaos remains

## Anti-Patterns

- Deleting by folder name intuition alone
- Treating docs, tests, and build scripts as equally disposable
- Running one giant cleanup PR across runtime, QA, docs, CI, and packaging
- Trusting "unused" reports without checking dynamic loading paths
- Keeping dev-only imports inside real app entrypoints
- Preserving fossils because deleting them feels emotionally risky
- Archiving everything inside the same repo forever instead of moving it out

## The Pruning Principle

Do not ask the repo to explain every scar.
Ask it to justify every surviving surface.

If a file, folder, or subsystem cannot clearly answer one of these questions,
it is a pruning candidate:

- Does runtime load it?
- Does build or packaging require it?
- Does QA need it to prove safety?
- Does the team intentionally preserve it as archive?

If the answer is no, cut it.

