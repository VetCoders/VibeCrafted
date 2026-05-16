---
name: vibecrafted-meta-22-scaffold-to-release
description: 22-plan meta-roadmap for 𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. v1.7.0 → v2.0 → public market release. Mirrors the scope ambition of the loctree-suite LSP 22-plan roadmap (now in audit close-out). Natural split: 12 plans here in `vibecrafted/` (framework engine) + 8 plans in `../vibecrafted-io/` (public + commercial surface) + 2 cross-cutting (polarize gate + release sequence). Lifecycle arc /vc-scaffold → /vc-release.
type: meta_roadmap
project: VetCoders/vibecrafted + VetCoders/vibecrafted-io
created: 2026-05-10
parent_branch_vibecrafted: release/v1.7.1
parent_branch_vibecrafted_io: feat/new-layout-mon
audit_inheritance: ~/.vibecrafted/artifacts/Loctree/loctree-suite/2026_0510/reports/audit-22/22_task_audit_report.md (LSP roadmap close-out doctrine)
arc: /vc-scaffold → /vc-init → /vc-workflow → /vc-marbles → /vc-polarize → /vc-dou → /vc-hydrate → /vc-decorate → /vc-release
---

# 𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. — 22-Plan Meta-Roadmap · Scaffold to Release

> _"Not hating on vibe coding. It got you to launch... but founders who built
> in a weekend with Cursor are stuck. Can't close enterprise deals. Can't pass
> security review. Their Stripe integration works until it doesn't."_
> — Vibecrafted MANIFESTO
>
> v1.7.0 shipped 113-check doctor green with 20 skills + 10 foundations live.
> This 22-plan roadmap takes us from "framework that installs and runs" to
> "framework with a public commercial surface, a polished agent-native runtime,
> and a launch sequence that turns 'done in repo' into 'someone can buy this.'"

---

## §0 — North Star

`𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍.` is the **release engine for AI-developed software** — the
answer to the 80/20 ↔ 20/80 trap that strands vibe-coded weekend MVPs.

Three product surfaces (the polarize question — see §3 prism):

1. **Local framework** (the 80%) — `vibecrafted install` brings 20 skills +
   10 foundations + agent CLIs onto the operator's machine. Vibecrafted is
   first installed locally, then it earns its place in the cloud.
2. **Skill marketplace** — a curated bundle of `/vc-*` workflows that
   compose: scaffold → init → workflow → marbles → polarize → dou →
   hydrate → decorate → release. Each skill is operator-honest discipline
   wrapped in agent-portable form.
3. **Cloud Sync platform** — cross-machine AICX corpus sync + multi-agent
   coordination across VetCoders mesh (dragon, sztudio, silver, div0).
   Bills $4.90/seat/month add-on. The bridge to enterprise.

The 22 plans in this roadmap close v1.7 → v2.0 across **all three** surfaces.
Polarize gate in W1 (Plan 01) decides which is _primary_ before W2-W7 commit.

---

## §1 — Where we stand (2026-05-10)

### vibecrafted (this repo, `.` in operator notation)

| Field                 | Value                                                                                                                                                                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Version               | `1.7.0` (tag), branch `release/v1.7.1`                                                                                                                                                                                                                                                     |
| Doctor                | **113 ok / 0 warnings / 0 failures**                                                                                                                                                                                                                                                       |
| Skills shipped        | 20 (`vc-agents`, `vc-decorate`, `vc-delegate`, `vc-dou`, `vc-followup`, `vc-hydrate`, `vc-implement`, `vc-init`, `vc-intents`, `vc-justdo`, `vc-marbles`, `vc-ownership`, `vc-partner`, `vc-polarize`, `vc-prune`, `vc-release`, `vc-research`, `vc-review`, `vc-scaffold`, `vc-workflow`) |
| Foundations           | 10 (aicx-mcp, loctree-mcp, prview, screenscribe, semgrep, mise, starship, atuin, zoxide, zellij)                                                                                                                                                                                           |
| Agent CLIs            | claude (2.1.138) · codex (0.130.0) · gemini (0.35.3) — symlinked through 60+ verified entries                                                                                                                                                                                              |
| Stack                 | Rust (operator/mux-agent + operator/tray-agent) · Python (vibecrafted-core + vibecrafted-mcp) · Shell helpers (bash + zsh) · Makefile workflow (63 idiom:make-target hits) · Docker bundle (Dockerfile + docker/)                                                                          |
| Hubs (`loct context`) | `operator/mux-agent/src/config.rs` (12 importers) · `operator/mux-agent/src/scan.rs` (10) · `operator/mux-agent/src/state.rs` (10) — 3 files over fan-in threshold                                                                                                                         |
| Active intent (AICX)  | iTerm2 OSC primitives + Hammerspoon URL handlers + dynamic profiles (claude 2026-05-08) — _experimental_ status, needs GA cut                                                                                                                                                              |
| Cross-shell helpers   | `~/.config/vetcoders/vc-skills.sh` (bash + zsh)                                                                                                                                                                                                                                            |
| Launcher              | `vibecrafted help`, `vc-help`, `vc-dashboard` smoke-passed                                                                                                                                                                                                                                 |

### vibecrafted-io (sibling, `../vibecrafted-io`)

| Field           | Value                                                                                                                              |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Branch          | `feat/new-layout-mon`                                                                                                              |
| Stack           | Astro + Svelte + i18n                                                                                                              |
| Hub             | `site/src/lib/i18n/index.ts` (53 importers — heavy i18n surface)                                                                   |
| Components live | `Reveal.svelte` (14 importers), `LayoutV2.astro` (11), `SectionFooter.astro` (8)                                                   |
| Sections        | `site/src/{components,content,layouts,lib,pages,styles,assets}`                                                                    |
| Bundle pipeline | `Makefile` heavy — 71 idiom:make-target hits (bundle, bundle-build, bundle-preflight, bundle-preview, bundle-sign, bundle-archive) |
| Roadmap         | `docs/roadmap/` partial                                                                                                            |
| Brand state     | `index.html` + landing draft live; needs design system pass aligned with sibling loctree-com BRAND.md + design-system.md           |

### Inheritable doctrine (from loctree-suite audit-22)

The LSP roadmap (22 plans, 6 weeks) closed with:

- **8 PASS · 10 PASS_WITH_GAPS · 1 PARTIAL · 0 FAIL · 3 staged-by-design**
- 2 P1 wire breaks tracked in `meta-marbles-22-completion.prompt` for post-close iteration
- 5 cross-task patterns surfaced (emit/consume drift, frontmatter overclaim, capability vs params mismatch, forward-drift positive, stub-honesty enforcement variation)
- Stage-aware audit pattern proven for multi-stage plans

**Apply same discipline here.** Each plan below has acceptance criteria,
files to touch, verification commands, non-goals, and a stage label if it
naturally spans two cuts.

---

## §2 — Scaffold context (the /vc-scaffold output)

This roadmap is the deliverable of one mental `/vc-scaffold` pass over the
vibecrafted product surface. The skill description: _"Founder-first
architecture planning. Takes a vague idea, maps the landscape, produces a
scoped build plan."_

### What we explored

- Current install path (macOS-first → cross-platform need)
- Skill loader smoke (works on `make install`, no isolated test gate yet)
- Agent dispatch model-parity discipline (kronika 2026-04-10 axiom; currently
  manual rule, needs automatic enforcement)
- AICX corpus sync across mesh (currently `~/.scripts/sync-tool.py` + rsync;
  Memex retrieval layer half-wired)
- Visual + dispatch stack (iTerm2 OSC + Hammerspoon URL handlers + Zellij
  layouts — kronika 2026-05-08 showed it works end-to-end, but still flagged
  `[experimental]` and not yet GA)
- Commercial path (vibecrafted-io has landing draft; no pricing, no checkout,
  no tier-gated state — loctree-com Polar.sh pattern available to adopt)
- Marketing (manifesto exists in `vibecrafted/docs/THE_VIBE_HANGOVER.md` and
  `vibecrafted-io` partials; no unified site experience yet)
- Showcase (Loctree LSP audit-22 + Vista sealed-env weekend are first-class
  case studies; not yet on public surface)

### What we ruled in

The 22 plans below. Each is scoped to land in 1-3 days agent-time at frontier
SoTA discipline (per kronika 2026-05-05: _"plany powinny być rama, nie kratka"_).

### What we ruled out (explicit non-roadmap)

- **Re-architecting skill execution model.** Current shell-out + skill-tool
  pattern works; agents consume skills cleanly through Claude Code Skill tool,
  Codex AGENTS.md path, Gemini activate_skill. Not changing the contract.
- **Custom MCP server replacement of foundation MCPs.** aicx-mcp, loctree-mcp,
  prview, semgrep already work; no NIH rewrite.
- **Migrating away from Makefile workflow.** Makefiles are operator-friendly
  - agent-readable + idempotent. 63 + 71 hits across two repos = doctrine.
- **New brand colors / typography.** loctree-com BRAND.md is the source of
  truth for VetCoders design system; vibecrafted-io adopts, doesn't fork.
- **Light-theme variant in v2.0.** Single dark theme matching loctree.com.
  Light theme = v3.0 or later if customer demand emerges.

---

## §3 — Polarize gate (W1 / Plan 01)

Before W2-W7 commit, run `/vc-polarize` with prism task array:

```jsonc
{
  "tool": "prism",
  "task": [
    "𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. is a local CLI framework — install and work from your machine, never phone home",
    "𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. is a curated skill marketplace for AI agents — Cursor, Claude Code, Codex, Gemini consume the same skill primitives",
    "𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. is a Cloud Sync platform for VetCoders mesh — cross-machine AICX corpus + multi-agent coordination",
    "𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. is an enterprise release engine — bills per-seat to dev teams shipping AI-developed software",
    "𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. is the manifesto + community brand — 𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚜𝚖𝚊𝚗𝚜𝚑𝚒𝚙 as a movement",
  ],
}
```

Expected output `loctree.prism.v1`: smear score across framings. If smear >
0.3, polarize chooses primary axis + emits DoU template + ICP definition.
**The primary axis decides W2-W7 priorities.** If polarize lands "local
framework" as primary, W6 (commercial) descopes. If "enterprise release
engine," W6 expands.

---

## §4 — The 22 plans (waves, repo split)

Legend: `(.)` = `vibecrafted/` (framework engine) · `(io)` = `../vibecrafted-io/` (public surface) · `(both)` = cross-cutting

### Wave 1 — Polarize identity (1 plan, both repos)

#### 01. polarize-identity-icp-dou-template — `(both)`

`/vc-polarize` over the 5 framings in §3. Emit decision-of-record:
`docs/POLARIZE_v2.md` in both repos (default in `vibecrafted/`, cross-link
in `vibecrafted-io/docs/roadmap/`). Output:

- Primary axis (one of 5 framings or a synthesis)
- DoU template specialized for primary axis
- ICP (Ideal Customer Profile): role + size + pain + budget signal
- Anti-ICP: who NOT to chase (e.g., solo hobbyists if "enterprise engine" wins)
- W2-W7 reprioritization based on polarize verdict

**Files:** `vibecrafted/docs/POLARIZE_v2.md` (NEW) · `vibecrafted-io/docs/roadmap/POLARIZE_v2.md` (NEW, symlink-or-copy).

**Acceptance:** decision-of-record exists; smear score documented; ICP one-paragraph; W2-W7 column status (scope-up / scope-down / unchanged) per plan.

**Non-goals:** does NOT implement; just decides.

**Verification:** operator + 2 agents agree on the verdict in <90 min.

---

### Wave 2 — Foundation hardening (4 plans, vibecrafted)

#### 02. skill-loader-integration-test-gate — `(.)`

Currently `make install` smokes loader via `doctor`. No isolated gate that
verifies every skill loads cleanly under a fresh `~/.vibecrafted/`. This
plan: `make test-skills` target spawns ephemeral install, asserts all 20 +
experimental + foundations skills are activatable via stub agent shell.

**Files:** `Makefile` (new target `test-skills`); `tests/skill_loader_smoke.sh` (NEW); `tests/fixtures/agent_stub.sh` (NEW); CI workflow `.github/workflows/skill-loader.yml` (NEW).

**Acceptance:**

- [ ] `make test-skills` exits 0 in clean `~/.vibecrafted/` checkout.
- [ ] CI runs on every PR; failure blocks merge.
- [ ] Tests cover each of 20 skills + experimental layer + each of 10 foundations binary discoverability.

**Non-goals:** no skill-content validation; only loading + discoverability.

**Verification:** `make test-skills` + CI green on a fresh `git clone`.

---

#### 03. cross-platform-install-linux-windows-minimal — `(.)`

Currently `install.sh` is macOS-shaped (assumes brew, Apple HOME paths, dyld
behavior). Add Linux first (Debian/Ubuntu + Arch), Windows minimal (PowerShell

- WSL). Detect platform, branch installer paths, fallback to Homebrew on Linux
  if available, document edge cases.

**Files:** `install.sh` (refactor with `case "$(uname -s)" in ...` branching); `install.ps1` (NEW, Windows entry); `docs/INSTALL.md` (NEW, per-platform); `Dockerfile` (refresh for Linux base).

**Acceptance:**

- [ ] Linux install (Debian Ubuntu) lands all 20 skills + foundations binaries (or graceful skip with explicit reason).
- [ ] WSL install runs the Linux path.
- [ ] PowerShell install fails-cleanly with "use WSL" message + docs link (v1 deferral).
- [ ] Each platform documented with prerequisites + known limitations.

**Non-goals:** no native Windows binaries this cut (WSL acceptable for v2.0).

**Verification:** Docker-based CI matrix across `ubuntu-latest`, `debian-12`, `archlinux:latest`, `wsl-ubuntu`; manual macOS smoke.

---

#### 04. vc-skill-new-scaffolding-plugin-authoring-kit — `(.)`

Operators can install `𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍.` but cannot trivially extend it. Need
`vc-skill new <name>` that scaffolds: `skills/<name>/{SKILL.md, README.md, examples/}`

- test harness + registration hook + brief contributing guide.

**Files:** `tools/vc-skill-new.sh` (NEW); `skills/_template/` (NEW); `docs/CONTRIBUTING-SKILLS.md` (NEW).

**Acceptance:**

- [ ] `vc-skill new my-test-skill` creates a working skill under `skills/my-test-skill/`.
- [ ] Skill is immediately discoverable via `vibecrafted doctor`.
- [ ] Template includes example trigger phrases, frontmatter, helper integration.

**Non-goals:** no marketplace UI; no auto-publish.

**Verification:** `vc-skill new test-foo && vibecrafted doctor | grep test-foo`.

---

#### 05. installer-rollback-and-partial-recovery — `(.)`

Current installer is best-effort; partial failure leaves orphan files +
broken state. Add transaction log + rollback path: every install step records
to `~/.vibecrafted/install.log` + `~/.vibecrafted/install-state.json`; on
failure or `vibecrafted uninstall --partial`, walk log backwards.

**Files:** `install.sh` (transaction wrapper); `scripts/lib/install-state.sh` (NEW); `vibecrafted uninstall` command (refactor for partial mode).

**Acceptance:**

- [ ] Forced failure mid-install (kill -9 between steps) leaves state.json with partial-step marker.
- [ ] `vibecrafted uninstall --partial` walks back to clean state idempotently.
- [ ] Full uninstall removes everything except user-modified config (with explicit dry-run preview).

**Non-goals:** no auto-recovery on next install attempt (operator decides).

**Verification:** kill-during-install fixture test.

---

### Wave 3 — Agent orchestration (4 plans, vibecrafted)

#### 06. model-parity-enforcement-automatic — `(.)`

Kronika 2026-04-10 axiom: **every native delegation must pass parent's model
tier (no Sonnet/Haiku fallback from Opus parent)**. Currently a manual rule.
This plan: wrap spawn primitives in `scripts/lib/spawn.sh` + `vibecrafted-core`
agent dispatch helpers with auto-detect + reject-on-downgrade + explicit
override flag for operator-acknowledged exceptions.

**Files:** `scripts/lib/spawn.sh` (refactor + parity guard); `vibecrafted-core/agent_dispatch.py` (similar); `tests/spawn_parity_test.sh` (NEW); `skills/vc-agents/SKILL.md` (update doctrine).

**Acceptance:**

- [ ] Spawn helpers detect parent model from `CLAUDE_MODEL` / `CODEX_MODEL` / similar env or last-known signal.
- [ ] Downgrade dispatch (Opus parent → Sonnet child) rejects with explicit error + override flag.
- [ ] Test fixtures simulate each downgrade scenario; all rejected unless override set.

**Non-goals:** no enforcement on third-party tools that bypass these helpers.

**Verification:** `tests/spawn_parity_test.sh`; manual smoke from each agent CLI.

---

#### 07. living-tree-race-protection-helpers — `(.)`

Kronika 2026-04-16/17 incident: `git commit --only` is NOT atomic vs parallel
agent commit — message can land under another agent's envelope. Helper:
`scripts/lib/living-tree-commit.sh` wraps commit with pre-flight git index
snapshot + post-commit verification + race-detect retry-once-with-rebase.

**Files:** `scripts/lib/living-tree-commit.sh` (NEW); `Makefile` target `commit-safe`; `skills/LIVING_TREE_RULE.md` (refresh with helper invocation).

**Acceptance:**

- [ ] Helper detects race (HEAD moved between `git add` and `git commit --only`).
- [ ] On race: prints diagnostic + offers rebase-then-retry or abort.
- [ ] Idempotent on no-race (just behaves as normal commit).
- [ ] Skill doc updated; every `/vc-*` workflow that commits adopts the helper.

**Non-goals:** does NOT prevent races; detects + retries.

**Verification:** synthetic race test (two parallel commits on same file).

---

#### 08. aicx-cross-machine-sync-v2-with-conflict-resolution — `(.)`

Current `~/.scripts/sync-tool.py` + `~/.frontier-vault/` pattern (kronika
2026-05-05) is one-directional with guardian mode. v2 = bidirectional with
conflict resolution: each chunk has authority label, conflict resolution
picks higher authority (RepoVerified > AicxOperator > AicxAgent > SemanticGuess);
ties prompt operator interactively + recorded as decision.

**Files:** `vibecrafted-core/aicx_sync.py` (NEW or refactor); `scripts/aicx-sync.sh` (CLI entry); `~/.frontier-vault/conflict-log.jsonl` (state).

**Acceptance:**

- [ ] Two-machine sync (div0 ↔ sztudio) bidirectional clean run.
- [ ] Authority-based conflict resolution documented with rule table.
- [ ] Operator-decided ties logged; future syncs respect logged decisions.
- [ ] Performance: 5GB corpus sync over 15 Mbps uplink completes in <90 min (kronika SF→PL benchmark).

**Non-goals:** no full re-architecture; extend existing sync-tool.

**Verification:** end-to-end sync between dragon ↔ silver via sztudio relay (kronika topology) returns clean state on both sides.

---

#### 09. memex-retrieval-integration-cross-session — `(.)`

`rust-memex` foundation is installed (per doctor output) but not wired into
`/vc-init` perception layer. Wire it as Sense 1 (intentions) augmentation:
when AICX local search is sparse (< 5 chunks for current scope), fall through
to memex SSE for cross-session semantic retrieval.

**Files:** `skills/vc-init/SKILL.md` (extend Sense 1); `vibecrafted-core/memex_client.py` (NEW); `tests/memex_integration_test.sh` (NEW).

**Acceptance:**

- [ ] `/vc-init` Sense 1 falls through to memex when local AICX < threshold.
- [ ] Memex chunks tagged with authority `MemexDerived` (new label).
- [ ] Test fixture with sparse AICX + populated memex returns memex hits.

**Non-goals:** does NOT replace AICX; augments it.

**Verification:** integration test against running memex SSE endpoint.

---

### Wave 4 — Stack agent-native runtime GA (3 plans, vibecrafted)

#### 10. iterm2-osc-primitives-and-dynamic-profiles-GA — `(.)`

Currently shipped under `[experimental]` prefix per kronika 2026-05-08. v2.0
promotes to GA: `vibecrafted-core/iterm2_osc.py` + `iterm2_profiles.py` lose
`[experimental]` framing; profiles get stable `VetCoders / <namespace>`
naming (no `[experimental]` prefix); operator-confirmed via Monika demo
acceptance.

**Files:** `vibecrafted-core/iterm2_osc.py` (rename framing); `vibecrafted-core/iterm2_profiles.py` (drop `[experimental]`); `Makefile` (rename `iterm-plugin*` targets to GA-clean names); `README.md` (document GA status).

**Acceptance:**

- [ ] Profile GUID convention stable: `vetcoders.<namespace>.<name>` (no experimental marker).
- [ ] Existing experimental profiles migrate via `make iterm-plugin-migrate` (idempotent, .bak on overwrite).
- [ ] CLI install/refresh/show/uninstall paths documented in `docs/iTERM2.md`.
- [ ] Monika demo signed-off (post-Drew demo per kronika).

**Non-goals:** no new OSC primitives; just GA polish.

**Verification:** `make iterm-plugin-refresh` on clean iTerm2; profiles appear without `[experimental]` prefix.

---

#### 11. hammerspoon-url-handlers-extend-stack-stabilize — `(.)`

Plan A handlers (`vc-ping`, `vc-loct`, `vc-aicx`, `vc-open-file`) shipped per
kronika 2026-05-08. Extend with `vc-atlas` (open atlas card via MCP), `vc-prism`
(run polarize on selection), `vc-marbles` (spawn marble run in iTerm2 tab),
`vc-followup` (auto-open last marbles report). Plus harden injection
sanitization regex coverage.

**Files:** `~/.hammerspoon/init.lua` (extend handlers — but ship in `config/hammerspoon/init.lua` template); `tests/hammerspoon_smoke.sh` (NEW); `docs/HAMMERSPOON.md` (NEW reference).

**Acceptance:**

- [ ] All 8 vc-\* handlers (4 existing + 4 new) registered + tested via `open` URL invocation.
- [ ] Injection sanitization: regex `^[%w%s%-_=%./%+]+$` for cmd param; explicit list of allowed scheme params.
- [ ] Manual smoke: each handler from iTerm2 OSC 8 hyperlink → AppleScript spawn → CLI dispatch → AICX returns relevant chunks.

**Non-goals:** no Karabiner alt-binding integration (separate plan).

**Verification:** Hammerspoon test runner + manual click-through smoke per handler.

---

#### 12. zellij-multi-agent-layouts-finalize-with-aicx-status — `(.)`

6 layouts shipped (research, workflow, marbles, dashboard, operator + one
more per kronika). v2: add AICX status tap (live count of in-progress agent
sessions per workstation) + drift indicator (loctree snapshot age across
panes) + default color scheme per workstation host (dragon=red, sztudio=purple,
silver=cyan, div0=green — kronika 2026-05-05 mesh-aware identity).

**Files:** `config/zellij/layouts/*.kdl` (refresh each); `config/zellij/aicx-status.sh` (NEW status bar plugin); `config/zellij/themes/vetcoders-mesh.kdl` (NEW).

**Acceptance:**

- [ ] AICX status appears in zellij status bar across all 6 layouts.
- [ ] Color scheme detects host via `scutil --get LocalHostName` and themes accordingly.
- [ ] Drift indicator: green (<5 min), yellow (<1h), red (stale).

**Non-goals:** no per-pane state persistence across zellij restarts.

**Verification:** `vibecrafted layout research` on each workstation shows host-themed status bar.

---

### Wave 5 — Public surface foundation (4 plans, vibecrafted-io)

#### 13. landing-v2-editorial-tech-design-pass — `(io)`

Adopt loctree-com design system: `tokens.css` (warm dark ink `#0e0e0e` +
cream-on-ink `#f5f1e7` + restrained teal/amber accents) + `fonts.css` (serif
display + sans body + monospace UI, variable WOFF2 self-hosted) + 5 CSS files
pattern. Anti-aesthetic gates: no pure black, no gradient soup, no CRT
scanlines (kronika 2026-04 doctrine).

**Files:** `vibecrafted-io/styles/tokens.css` (vendor from loctree-com); `vibecrafted-io/styles/fonts.css` (vendor); `vibecrafted-io/styles/main.css` (refactor); `vibecrafted-io/site/src/layouts/LayoutV2.astro` (consume tokens); `vibecrafted-io/public/fonts/*.woff2` (vendor).

**Acceptance:**

- [ ] All hardcoded hex purged from `site/src/`. Grep: `grep -rE '#[0-9a-fA-F]{3,6}' site/src/components/` returns no non-comment hits.
- [ ] All 5 CSS files inlined via Astro layout `<style>` blocks.
- [ ] Anti-aesthetic test: no `gradient-`, `backdrop-filter:`, `scanline`, `animation:.*entrance` in rendered HTML.
- [ ] Mobile responsive at 375px viewport.
- [ ] Visual diff vs loctree.com landing: same brand feel + type rhythm.

**Non-goals:** no new sections; restyle existing.

**Verification:** `make site-test` (visual contract + lint) + manual Safari/Firefox/Chrome smoke.

---

#### 14. manifesto-bilingual-en-pl-unified — `(io)`

`vibecrafted/docs/THE_VIBE_HANGOVER.md` is the default EN manifesto. PL
translation partial in `vibecrafted-io/pl/`. Unify both into a single
public-facing `/manifesto` route in vibecrafted-io with language toggle. Add
CTA to install (`https://loct.io/install.sh` per BRAND.md).

**Files:** `vibecrafted-io/site/src/pages/manifesto.astro` (NEW); `vibecrafted-io/site/src/content/manifesto-en.md` (NEW, copy from vibecrafted/docs); `vibecrafted-io/site/src/content/manifesto-pl.md` (NEW); `vibecrafted-io/site/src/lib/i18n/manifesto.ts` (NEW).

**Acceptance:**

- [ ] `/manifesto` route renders cleanly in both EN and PL.
- [ ] Language toggle preserves scroll position.
- [ ] Install CTA prominent + dark-pattern-free (no email-gate, no popup).
- [ ] PL translation lint-pass (no untranslated strings).

**Non-goals:** no auto-translate; human-curated only.

**Verification:** `pnpm run check` + manual smoke per language.

---

#### 15. docs-site-astro-docsearch-skills-architecture-install — `(io)`

Scattered docs in `vibecrafted/docs/` (FRONTIER.md, SKILLS.md, WORKFLOWS.md,
FAQ.md, MARKETPLACE_LISTING.md, etc.) need unified public docs site at
`vibecrafted-io/docs/` (live route, not just markdown files). Astro DocSearch
for fast retrieval; sidebar nav for architecture / install / skills reference.

**Files:** `vibecrafted-io/site/src/pages/docs/[...slug].astro` (NEW catch-all); `vibecrafted-io/site/src/content/docs/` (NEW, mirror from vibecrafted/docs/ via sync script); `vibecrafted-io/scripts/sync-docs.sh` (NEW); `vibecrafted-io/site/src/lib/docsearch.ts` (NEW).

**Acceptance:**

- [ ] All vibecrafted/docs/\*.md surfaced at `/docs/<slug>`.
- [ ] Sidebar nav: Architecture / Install / Skills Reference / FAQ / Manifesto.
- [ ] Search box returns relevant results within 200ms.
- [ ] Sync script idempotent; doc changes in vibecrafted/ flow through.

**Non-goals:** no doc-editing UI; read-only.

**Verification:** `make docs-sync && pnpm run build && pnpm run preview` + manual search smoke.

---

#### 16. showcase-case-studies-loctree-vista-audit22 — `(io)`

`vibecrafted` as a product needs proof. Three case studies surface real
work: (1) **Loctree LSP roadmap close-out** (22 plans, 6 weeks, this very
roadmap's inheritance), (2) **Vista sealed-env weekend** (kronika 2026-04-27/28
— Sentry pipeline + crypto contract alignment), (3) **Audit-22 parallel-truth
reconciliation** (the audit that wrote this roadmap's inheritance doctrine).

**Files:** `vibecrafted-io/site/src/pages/showcase/index.astro` (NEW); `vibecrafted-io/site/src/pages/showcase/loctree-lsp-roadmap.astro` (NEW); `vibecrafted-io/site/src/pages/showcase/vista-sealed-env.astro` (NEW); `vibecrafted-io/site/src/pages/showcase/audit-22-parallel-truth.astro` (NEW).

**Acceptance:**

- [ ] Each case study has: problem framing + skill arc used + outcome metrics + 1-2 quote-grade lessons.
- [ ] No PII / no operator-personal details (public-source-only — kronika 2026-05-09 doctrine).
- [ ] Links out to public GitHub commits where citable; no link to private repos.

**Non-goals:** no comment section; no analytics tracking on case study reads.

**Verification:** manual content review by operator; no sensitive leak.

---

### Wave 6 — Brand & marketing polish (3 plans, vibecrafted-io)

#### 17. og-images-and-social-cards-per-page-dynamic — `(io)`

Static `og-image.png` for landing; need per-page dynamic OG (e.g., `/manifesto`
has manifesto-themed card; `/showcase/loctree-lsp-roadmap` has plan-grid card).
Use Vercel OG-style edge function or pre-rendered via Astro endpoint.

**Files:** `vibecrafted-io/site/src/pages/og/[slug].png.ts` (NEW Astro endpoint); `vibecrafted-io/site/src/lib/og-renderer.ts` (NEW); `vibecrafted-io/scripts/og-prerender.sh` (NEW); `vibecrafted-io/public/og/` (output).

**Acceptance:**

- [ ] Each top-level route has unique OG card.
- [ ] Cards use brand tokens (warm dark + cream + accents); no stock images.
- [ ] Social preview tested on X/LinkedIn/Slack — renders correctly.

**Non-goals:** no animated OG; static only.

**Verification:** manual smoke per route + Twitter Card Validator.

---

#### 18. seo-indexability-llms-txt-schema-org — `(io)`

Currently `index.html` + sitemap + robots present but minimal. Audit-grade:
sitemap.xml comprehensive (manifesto, docs, showcase, install); robots.txt
allow-all except wp-admin-style noise; schema.org JSON-LD on landing
(`Software`, `Organization`, `Product`); `llms.txt` for LLM-discovery.

**Files:** `vibecrafted-io/site/public/sitemap.xml` (regen); `vibecrafted-io/site/public/robots.txt` (refresh); `vibecrafted-io/site/src/components/SchemaOrg.astro` (NEW); `vibecrafted-io/site/public/llms.txt` (NEW).

**Acceptance:**

- [ ] Google Search Console + Bing Webmaster accept the sitemap.
- [ ] Schema.org validator returns 0 errors.
- [ ] `llms.txt` lists primary entry points + skill references for LLM crawlers.

**Non-goals:** no SEO content rewriting (separate marketing pass).

**Verification:** webmaster tools + schema validator + manual `curl` of llms.txt.

---

#### 19. newsletter-buttondown-community-surface — `(io)`

Operator builds in public; community presence missing. Add Buttondown (or
similar markdown-first newsletter) integration: signup in footer, archive at
`/newsletter`, RSS feed. Goal: 50 signups by post-launch.

**Files:** `vibecrafted-io/site/src/components/NewsletterSignup.astro` (NEW); `vibecrafted-io/site/src/pages/newsletter/index.astro` (NEW archive); `vibecrafted-io/site/src/pages/newsletter/[slug].astro` (NEW per-issue); `vibecrafted-io/scripts/buttondown-sync.sh` (NEW).

**Acceptance:**

- [ ] Footer signup works (Buttondown API integration).
- [ ] Archive renders past issues in markdown.
- [ ] RSS at `/newsletter/rss.xml`.

**Non-goals:** no transactional email; no analytics on opens.

**Verification:** manual signup smoke + RSS reader test.

---

### Wave 7 — Commercial & release (3 plans, split)

#### 20. pricing-surface-and-tier-definition — `(io)`

Define tier shape based on polarize verdict (Plan 01). Working hypothesis if
polarize lands "skill marketplace + cloud sync platform":

| Tier           | Price          | Includes                                                                                  |
| -------------- | -------------- | ----------------------------------------------------------------------------------------- |
| **Solo**       | Free           | Local install, 20 skills, foundations, single-machine AICX                                |
| **Pro**        | $9/mo          | All Solo + Cloud Sync cross-machine + memex retrieval cross-session                       |
| **Team**       | $19.90/seat/mo | All Pro + multi-agent mesh coordination + shared AICX corpus + zellij dashboard team mode |
| **Enterprise** | Contact        | All Team + self-host bundle + SSO + audit log + SLA                                       |

**Files:** `vibecrafted-io/site/src/pages/pricing.astro` (NEW); `vibecrafted-io/site/src/content/pricing/tiers.md` (NEW); `vibecrafted-io/site/src/components/PricingTable.astro` (NEW).

**Acceptance:**

- [ ] Pricing page renders tiers with bullet-point features.
- [ ] No dark patterns (no "Most Popular" forced highlight on Pro; let buyer decide).
- [ ] Each tier links to Plan 21 checkout flow.

**Non-goals:** no per-feature gating logic in this plan; that's Plan 21.

**Verification:** operator + 2 trusted advisors review tier shape + Monika sign-off.

---

#### 21. polar-sh-checkout-integration — `(io)`

Adopt loctree-com Polar.sh pattern (already shipped per `loctree-com/docs/licensing/polar-sh/`
plans 01-11). Re-use: `vibecrafted-io/src/server/polar.rs` (or equivalent
Astro endpoint) for product creation, checkout session, webhook signature,
event dispatcher, tier gating. Products map to Plan 20 tiers.

**Files:** `vibecrafted-io/site/src/pages/api/v1/checkout.ts` (NEW); `vibecrafted-io/site/src/pages/api/v1/webhook.ts` (NEW); `vibecrafted-io/site/src/lib/polar-client.ts` (NEW); `vibecrafted-io/.env.example` (POLAR_API_KEY + POLAR_WEBHOOK_SECRET); `vibecrafted-io/site/src/pages/account.astro` (NEW post-checkout); `~/.keys/polar-sh.env` (operator-side, NOT committed).

**Acceptance:**

- [ ] 4 Polar.sh products created (Solo trial, Pro, Team, Enterprise contact).
- [ ] Checkout flow: tier select → Polar.sh → return to `/account` → tier-gated state set.
- [ ] Webhook handles `checkout.succeeded`, `subscription.created`, `subscription.canceled` events.
- [ ] Signature verification on every webhook.

**Non-goals:** no Cloud Sync platform delivery in this plan (just billing seam); the actual sync platform is Plans 08 + 09 territory.

**Verification:** Polar.sh test mode end-to-end + signature test.

---

#### 22. release-engine-self-shipping-v2-launch-with-drew-demo — `(both)`

The capstone. `𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍.` ships itself end-to-end through its own
`/vc-release` skill: DoU audit (Plan 01 ICP gate + Plan 13-19 surface gate);
Sentry/observability (Sentry self-hosted per Vista pattern from kronika
2026-04-27); analytics minimal (no FB pixel; Plausible or self-hosted Umami);
SEO indexability check (Plan 18 validates); install path smoke (Plan 02 cross-
platform); post-launch smoke checklist; **Drew demo (postponed per kronika
2026-05-08 for quality threshold) executed**.

**Files:** `vibecrafted/skills/vc-release/SKILL.md` (refresh with v2.0 ship checklist); `vibecrafted-io/site/src/pages/launch.astro` (announcement); `vibecrafted-io/docs/LAUNCH_CHECKLIST.md` (NEW); `vibecrafted/CHANGELOG.md` (v2.0 entry); `vibecrafted/VERSION` (bump); `~/.vibecrafted/artifacts/vetcoders/vibecrafted/2026_MMDD/launch-runbook.md` (NEW operator artifact).

**Acceptance:**

- [ ] All prior 21 plans landed (or explicitly descoped per polarize verdict).
- [ ] DoU audit returns "ready" or "ready-with-known-issues" (no P0/P1 open).
- [ ] Sentry receives test event from vibecrafted v2.0 install.
- [ ] Analytics: pageview tracked on vibecrafted-io landing.
- [ ] SEO: Google Search Console verified; first crawl complete.
- [ ] Install smoke: macOS + Linux fresh-machine install → `vibecrafted doctor` returns 113+ ok.
- [ ] Drew demo: scheduled, executed, debrief recorded in `~/.vibecrafted/artifacts/.../drew-demo-debrief.md`.
- [ ] Public announcement (manifesto refresh + showcase update + newsletter blast).
- [ ] First public release tag `v2.0.0` on both repos; release notes generated.

**Non-goals:** no growth marketing campaign (separate plan post-launch); no paid acquisition.

**Verification:** the launch happens; post-launch 24h smoke check (Sentry quiet, analytics shows pageviews, no install path break reports).

---

## §5 — Dependency graph

```
                                01 polarize-identity-ICP
                                         │
            ┌────────────────────────────┼────────────────────────────┐
            │                            │                            │
            ▼                            ▼                            ▼
       (Wave 2 + 3)                 (Wave 4)                     (Wave 5 + 6)
       Foundation                   Stack runtime                Public surface
            │                            │                            │
       02 skill-loader            10 iterm2-GA               13 landing-v2
       03 cross-platform          11 hammerspoon-extend      14 manifesto-EN-PL
       04 vc-skill-new            12 zellij-layouts          15 docs-site
       05 installer-rollback                                 16 showcase
                                                             17 og-images
       06 model-parity                                       18 seo-llms-txt
       07 living-tree-helpers                                19 newsletter
       08 aicx-sync-v2
       09 memex-retrieval
                                                             20 pricing
                                                             21 polar-sh-checkout
            │                            │                            │
            └────────────────────────────┴────────────────────────────┘
                                         │
                                         ▼
                            22 release-engine-self-shipping
                          (DoU + Sentry + analytics + SEO +
                           install smoke + Drew demo + v2.0 tag)
```

**Critical paths:**

- Polarize gate (01) blocks everything — must land first.
- 02-05 (foundation) blocks 22 (install smoke).
- 06-09 (orchestration) blocks 22 (release-engine relies on AICX sync + model parity).
- 10-12 (stack runtime) blocks Drew demo in 22.
- 13-19 (public surface) blocks 22 (launch needs site).
- 20-21 (commercial) blocks 22 (launch needs pricing + checkout).

**Independent (no upstream deps within roadmap):** 02, 03, 04, 06, 07, 13, 16, 17, 18, 19.

**Tightest dependency chain:** 01 → 13 → 15 → 16 → 22 (polarize → design → docs → showcase → launch).

---

## §6 — Wave schedule

Each wave's slowest plan gates the wave. Estimate 4-8h per plan with 1
agent at frontier SoTA discipline; with 3-4 agents in parallel + good
Living Tree etiquette, ~1-2 days calendar per wave.

| Wave | Plans          | Repos  | Est. wall-clock |
| ---- | -------------- | ------ | --------------- |
| W1   | 01             | both   | 0.5-1 day       |
| W2   | 02, 03, 04, 05 | `.`    | 3-4 days        |
| W3   | 06, 07, 08, 09 | `.`    | 4-5 days        |
| W4   | 10, 11, 12     | `.`    | 2-3 days        |
| W5   | 13, 14, 15, 16 | `(io)` | 4-5 days        |
| W6   | 17, 18, 19     | `(io)` | 2-3 days        |
| W7   | 20, 21, 22     | both   | 3-4 days        |

**Total optimistic:** ~3-4 weeks with 3-4 agents in parallel.
**Total realistic:** ~6-8 weeks with operator review cadence + drew-demo scheduling lead time.

---

## §7 — TRACKER (live status board)

Same convention as loctree-suite `docs/plans/lsp/TRACKER.md`. Edit inline
before/after each plan; bump `last_updated` in frontmatter; append §8 activity
log entry with ISO-8601 timestamp.

Legend: `queued` | `in-progress` | `blocked` | `review` | `done` | `failed`

| #   | Plan                         | Repo | Status | Owner | Wave | Branch | Started | Completed | Report                           |
| --- | ---------------------------- | ---- | ------ | ----- | ---- | ------ | ------- | --------- | -------------------------------- |
| 01  | polarize-identity-ICP        | both | queued | —     | W1   | —      | —       | —         | `docs/POLARIZE_v2.md`            |
| 02  | skill-loader-test-gate       | .    | queued | —     | W2   | —      | —       | —         | reports/02-skill-loader.md       |
| 03  | cross-platform-install       | .    | queued | —     | W2   | —      | —       | —         | reports/03-cross-platform.md     |
| 04  | vc-skill-new-kit             | .    | queued | —     | W2   | —      | —       | —         | reports/04-vc-skill-new.md       |
| 05  | installer-rollback           | .    | queued | —     | W2   | —      | —       | —         | reports/05-installer-rollback.md |
| 06  | model-parity-auto            | .    | queued | —     | W3   | —      | —       | —         | reports/06-model-parity.md       |
| 07  | living-tree-helpers          | .    | queued | —     | W3   | —      | —       | —         | reports/07-living-tree.md        |
| 08  | aicx-sync-v2                 | .    | queued | —     | W3   | —      | —       | —         | reports/08-aicx-sync-v2.md       |
| 09  | memex-retrieval              | .    | queued | —     | W3   | —      | —       | —         | reports/09-memex.md              |
| 10  | iterm2-GA                    | .    | queued | —     | W4   | —      | —       | —         | reports/10-iterm2-GA.md          |
| 11  | hammerspoon-extend           | .    | queued | —     | W4   | —      | —       | —         | reports/11-hammerspoon.md        |
| 12  | zellij-layouts               | .    | queued | —     | W4   | —      | —       | —         | reports/12-zellij.md             |
| 13  | landing-v2                   | io   | queued | —     | W5   | —      | —       | —         | reports/13-landing-v2.md         |
| 14  | manifesto-EN-PL              | io   | queued | —     | W5   | —      | —       | —         | reports/14-manifesto.md          |
| 15  | docs-site                    | io   | queued | —     | W5   | —      | —       | —         | reports/15-docs-site.md          |
| 16  | showcase                     | io   | queued | —     | W5   | —      | —       | —         | reports/16-showcase.md           |
| 17  | og-images                    | io   | queued | —     | W6   | —      | —       | —         | reports/17-og-images.md          |
| 18  | seo-llms-txt                 | io   | queued | —     | W6   | —      | —       | —         | reports/18-seo.md                |
| 19  | newsletter                   | io   | queued | —     | W6   | —      | —       | —         | reports/19-newsletter.md         |
| 20  | pricing-tiers                | io   | queued | —     | W7   | —      | —       | —         | reports/20-pricing.md            |
| 21  | polar-sh-checkout            | io   | queued | —     | W7   | —      | —       | —         | reports/21-checkout.md           |
| 22  | release-engine-self-shipping | both | queued | —     | W7   | —      | —       | —         | reports/22-release.md            |

---

## §8 — Activity log (append-only)

```
2026-05-10T23:55Z meta-22 claude scaffolded (22-plan meta-roadmap created post-loctree-suite-audit-22 close-out; 7 waves, 12+8+2 split between vibecrafted/vibecrafted-io/both; awaits operator polarize gate before W2 dispatch)
```

---

## §9 — Cross-repo coordination

| Concern          | Strategy                                                                                                                                                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Doc sync         | `vibecrafted-io/scripts/sync-docs.sh` pulls from `../vibecrafted/docs/` on every build. Source of truth = `vibecrafted/docs/`.                                                                                                                                                 |
| Version pinning  | `vibecrafted-io` pages render current `vibecrafted/VERSION` via build-time read. Bumping `vibecrafted/VERSION` triggers io site re-deploy.                                                                                                                                     |
| Brand tokens     | loctree-com is upstream brand source (kronika 2026-05-09 BRAND.md decision). vibecrafted-io vendors from loctree-com; vibecrafted operator-side themes consume same tokens via shared `~/.config/vetcoders/frontier/` symlink layer (already wired per `vibecrafted/config/`). |
| Showcase content | Public-source-only (kronika 2026-05-09 doctrine after `.github` leak incident). No PII, no internal topology, no operator names beyond public-knowable.                                                                                                                        |
| Release tag      | Both repos tag v2.0.0 simultaneously on Plan 22 close-out. CI gates ensure neither tags without the other.                                                                                                                                                                     |
| Polar.sh keys    | `~/.keys/polar-sh.env` operator-side, never committed. Both repos read via `.env` template + entrypoint check.                                                                                                                                                                 |

---

## §10 — Release gate (DoU) — what "done" means for v2.0

Adapt the loctree-suite audit-22 doctrine (PARTIAL master verdict with P1
wire breaks still tracked in meta-marbles) to vibecrafted v2.0 launch:

**v2.0 ships when:**

1. All 22 plans `[x]` in TRACKER §7 OR explicitly descoped per polarize verdict with operator-signed deferral note.
2. Doctor returns ≥113 ok (current baseline), 0 warnings, 0 failures on a fresh-machine install across macOS + Linux + WSL.
3. `vibecrafted-io` landing passes mobile + accessibility lint at AA contrast minimum.
4. Polar.sh test-mode checkout end-to-end clean for all 4 tiers.
5. Sentry receives first event from a v2.0 install within 24h post-launch.
6. Drew demo recorded with positive sign-off + at least one external "I'd buy this" signal.
7. No P0 in any audit run (LSP audit-22 inheritance: P1 acceptable if tracked; P0 blocks).
8. Public install path (`https://loct.io/install.sh`) signed (`install.sh.sig` exists in `vibecrafted-io/`) + verified end-to-end.
9. Manifesto + showcase + pricing + docs all reachable from landing in ≤2 clicks.
10. CHANGELOG entry + release tag + GitHub release notes + newsletter blast all sent within 1h of public availability.

**What is NOT a release blocker:**

- Light theme (deferred to v3.0).
- Native Windows binaries (WSL acceptable for v2.0).
- Custom domain for newsletter / analytics (subdomain OK).
- Enterprise self-host bundle (deferred to v2.1 — Plan 20 tier is "Contact").
- Cloud Sync platform v1 (Plan 08-09 ship the substrate; full SaaS Cloud Sync UI is v2.1+).
- Loctree.com SaaS integration with vibecrafted artifacts (separate `loctree-com` repo roadmap).

---

## §11 — Frontier SoTA-grade definition for 𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍.

Per the audit-22 inheritance pattern, every plan in this roadmap closes at
**frontier SoTA grade** if:

1. **Code change addresses the root cause**, not a symptom.
2. **e2e round-trip test** asserts the exact contract being closed.
3. **Negative check** (grep / state inspection / unit assertion) proves the
   old behavior is provably gone.
4. **Cargo / pnpm / pytest gates green:** workspace clippy `-D warnings`,
   pytest `-q`, pnpm `run check`.
5. **Living Tree etiquette:** appended fields on shared structs; re-read
   before edit; commit per task with operator-honest message; no Co-Authored-By
   `noreply@anthropic.com`; default signature per CLAUDE.md.
6. **Non-goals respected.** The fix does not silently add other surface.
7. **Report** in `.vibecrafted/reports/<repo>/<plan-id>-<name>.md` with
   findings + verification log + recommended follow-ups.

If any gate flickers, **revert and re-think**. Frontier SoTA = a future
auditor reading the test cannot construct a falsifier inside the touched
module.

---

## §12 — Marbles + Polarize handoff

After v2.0 ships (Plan 22 closes), this roadmap retires. Next iterations
move to:

- `meta-marbles-vibecrafted-v2-stabilize.prompt` — post-launch P2/P3 gaps tracked in marbles iteration prompt (same shape as `loctree-suite/docs/plans/lsp/meta-marbles-22-completion.prompt`).
- `meta-roadmap-v2.1-saas-cloud-sync.prompt` — Cloud Sync platform v1 → v2 deepening.
- `loctree-com/docs/licensing/polar-sh/12-vibecrafted-tier-handoff.md` — cross-repo handoff for vibecrafted tier shape integration with loctree-com Polar.sh substrate.

---

## §13 — Cross-references

- **Inheritance doctrine (audit-22):** `~/.vibecrafted/artifacts/Loctree/loctree-suite/2026_0510/reports/audit-22/22_task_audit_report.md` + reconciliation file
- **Parent kronika:** `~/.claude/Klaudiusz/kronika_2026.md` (operator + agent continuity, partnership doctrine)
- **Skill suite source:** `vibecrafted/skills/`
- **loctree-suite LSP roadmap (template):** `~/vc-workspace/VetCoders/loctree-suite/docs/plans/lsp/00-roadmap-readme.md` + `TRACKER.md`
- **loctree-com brand source:** `~/vc-workspace/VetCoders/loctree-com/docs/BRAND.md` + `design-system.md`
- **loctree-com Polar.sh template:** `~/vc-workspace/VetCoders/loctree-com/docs/licensing/polar-sh/01-11`
- **vibecrafted-io roadmap mirror:** `vibecrafted-io/docs/roadmap/` (linked stub of this file post-polarize)

---

_𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. with AI Agents by VetCoders (c)2024-2026 LibraxisAI_
