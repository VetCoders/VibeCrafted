# Vibecraftsmanship — Empirical Evidence (Case Study)

The canonical case study is the 2026-05-24 session that distilled this
skill. The session is empirical proof that the trinity is operational,
not aspirational.

---

## Timeline

| Time (UTC) | Event                                                                                                                               | Axis exercised                |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| ~07:00     | Session start, operator framing: spine selection for terminal stack                                                                 | gust                          |
| 07:35      | Wave A dispatched: A-1 (vibecrafted supervisor) + A-2 (vc-console events bridge), 2 codex parallel, different repos                 | siła                          |
| 08:07      | A-1 completed, commit `0fc9206`, 999 LOC, ruff+mypy+pytest 148+ green                                                               | rzeczywistość                 |
| 08:08      | A-2 completed, commit `4a9c5e5`, 1089 LOC, IPC smoke green, 2 orthogonal cleanups flagged honestly                                  | rzeczywistość                 |
| 08:51      | Operator corrections: "rescheduled not retired" + "3 labs in workspace" + "stop writing more briefs than commits land"              | gust (framing reset)          |
| 09:30      | Operator additions: microsandbox + Zentty as Lab #4 with GPL boundary + "equal intensity" framing                                   | gust                          |
| 09:39      | Wave B dispatched: 4 parallel labs (wezterm + vc-apprt + locterm + microsandbox), each cwd in own lab                               | siła                          |
| 10:06      | Wave B 3/4 reports in: B-1 + B-3 committed, B-4 substrate-failure on krunvm                                                         | rzeczywistość                 |
| 10:11      | B-2 marbles archived in terminal state: 3 Phase commits landed, worker honestly marked FAILED on inherited substrate (not B-2 lane) | rzeczywistość                 |
| 10:34      | Wave C close-out: CLOSE_OUT.md written, 4 operator decisions surfaced for operator's button                                         | trinity aligned               |
| ~17:30     | Pensieve clone + vc-init: separate evidence point — Bear-class markdown editor delivered in 28 hours of prior VetCoders work        | rzeczywistość (cross-session) |

Total wall-clock: **2h 59m** session start → close-out.

---

## What was delivered in those ~3 hours

| Artifact                | Commit                                  | LOC              | Surface                                                                               | Survived?                                                                            |
| ----------------------- | --------------------------------------- | ---------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| vibecrafted supervisor  | `0fc9206`                               | 999 / 25 files   | Python supervisor + bin/vc-\* wrappers + session_id capture + last-finisher synthesis | ✅ ruff+mypy+pytest 148+ green                                                       |
| vc-console spawn events | `4a9c5e5`                               | 1089 / 17 files  | IpcEvent::SpawnUpdate + jsonl bridge + tray rendering                                 | ✅ core IPC smoke green; 2 orthog cleanups flagged                                   |
| wezterm Lua hooks       | `02645e75c`                             | (multiple)       | Tab title + status bar + toast + events.jsonl tail                                    | ✅ 8/8 busted + 17823-line integration smoke                                         |
| vc\_ apprt runtime      | `acd99c746` + `83e9acb80` + `4d0e72e4b` | (multiple)       | Zig 0.16 fix + session_id DiskPayload + terminal lifecycle emitter                    | ✅ apprt 74/74 + smoke; ⚠ repo-wide test fails on inherited substrate (not B-2 lane) |
| iTerm2 Python plugin    | `eb6beb8`                               | 1382 / 11 files  | AutoLaunch + StatusBar + Triggers + GPL-separate-install                              | ✅ pytest 173/173, GPL boundary smoke clean                                          |
| Sandbox adapter         | (uncommitted, dirty worktree)           | (multiple files) | SandboxAdapter + msbserver lifecycle + policy + tests + docs                          | ⚠ SUBSTRATE-FAILURE: krunvm missing on host                                          |

**5 of 6 work units survived contact with reality.** 1 hit honest
substrate-failure (information, not delivery).

---

## What conventional estimates predicted

From 9-report cross-swarm research (claude+codex+gemini × 3 spine
swarms), conventional engineer-day estimates were:

| Phase                                  | Conventional ED | Conventional weeks |
| -------------------------------------- | --------------- | ------------------ |
| Phase 1 vibecrafted supervisor         | 12-18 ED        | 4-6 weeks          |
| Phase 2 vc-console events bridge       | 5-8 ED          | 3-5 weeks          |
| Phase 3a wezterm Lua hooks             | 3-5 ED          | ~1 week            |
| Phase 3c vc\_ Zig fix + apprt          | 26-37 ED        | 6-9 weeks          |
| Phase 3d locterm Python plugin         | 11.5 ED         | 4-6 weeks          |
| **Sum (Phase 1 + 2 + 3 all branches)** | **~58-86 ED**   | **~18-32 weeks**   |

Reality: **3 hours**.

Compression ratio: `(18 weeks × 168 hrs/week) / 3 hrs ≈ 1000×` low end,
`(32 weeks × 168 hrs/week) / 3 hrs ≈ 1800×` high end.

For pure Wave A+B implementation work (excluding research). Pensieve
case (Swift + AppKit + TextKit2 substrate friction, mostly sequential,
single repo) shows lower compression: gemini estimate 3-6 months,
reality 28 hours, compression ~80-150× — still 2 orders of magnitude.

---

## Pensieve cross-session evidence

The Pensieve repo was initialized at `2026-05-22 20:52:07` with
`[claude/vc-operator] feat(vcnotes): foundation skeleton for Swift/SwiftUI/TextKit2 rewrite`.
Most recent VetCoders commit: `2026-05-24 01:11:05`.

**Elapsed: 28 hours, 19 minutes.**

In those 28 hours, 27 commits landed across 4485 lines of Swift,
delivering:

- TextKit 2 source editor with syntax highlighting + line numbers (gemini)
- swift-markdown HTML preview with theme + debounce (claude)
- file-first storage with bookmark + watcher + autosave (codex)
- workspace import explorer + workspace search index
- preview pipeline (relative paths + appearance theming + dirty doc protection)
- MarkdownEditorSurface refactor (post-machete cut of "fragile editor bridge")
- command controller refactor (route app commands through controller)
- signed + notarized .app + .dmg release pipeline (operator)
- thin Makefile facade for daily ergonomics
- sidebar context menus + explorer selection feedback
- canonical Application Support directory + lint gate honest

This covers all 4 sections of gemini's "kompleksowy edytor Markdown w
Swift" decomposition — parser/AST, TextKit2 engine, UX
micro-interactions, file management — PLUS signed/notarized release
pipeline that gemini didn't even include in the estimate.

Gemini's premium tier estimate: **3-6 months** (90-180 days).
Reality: **~1.17 days**.
Compression: **77-154×** for Swift/AppKit (lower than Wave A/B due to
TextKit 2 substrate friction + Xcode compile cycle overhead + mostly
sequential single-repo flow).

---

## Operator corrections (gust axis in action)

The session demonstrated that operator real-time corrections are
load-bearing, not optional. Without them, agent would have drifted:

1. **"Rescheduled, not retired"** — vc-mux semantic re-framing. Agent
   had drift'd to "retirement" language; operator's correction
   preserved engineering dignity of post-poned-but-functional code.
2. **"3 (then 4) labs equal intensity"** — operator rejected agent's
   "primary spine vs parallel R&D vs premium" ranking. Equal intensity
   was the truth all along; agent's ranking was projection of
   conventional team-bandwidth thinking that doesn't apply at
   VetCoders pace.
3. **"Stop writing more briefs than commits land"** — agent had
   over-engineered Wave A briefs (~300 LOC each); operator flipped
   the ratio to "agents should win, dzięki tobie". Wave B briefs
   were shorter and agents shipped more.
4. **"Per-lab cwd dispatch"** — operator's hint to start each agent
   in its own lab dir, not generic vc-runtime root. Living Tree
   discipline + clean per-lab reports.
5. **"Fork-and-forget"** — for microsandbox: no upstream sync, no
   rebase, treat as VetCoders codebase from clone. Operator's taste
   call that agent could not have predicted (microsandbox is Apache
   2.0, technically syncable; operator chose not to).
6. **Time-rescale skepticism** — operator pushed back on
   "miesiące to tygodnie, tygodnie to dni, dni to..." sequence
   forcing agent to acknowledge "dni to godziny". Empirical evidence
   confirmed the operator was right.

Each correction reshaped trajectory mid-flight. Agent that doesn't
respond to operator corrections produces wrong work at high speed.

---

## Lessons distilled

1. **Trinity is constraint, not weighted vote.** All 3 must satisfy.
2. **Compression is real and stack-dependent.** 1000× for
   Python/Rust parallel; 80-150× for Swift/AppKit sequential.
   Apply empirically per project, not generically.
3. **Briefs ≠ commits.** Operator-agent's success is measured in
   commits landed by workers, not LOC of briefs written.
4. **Substrate failure ≠ delivery failure.** krunvm missing is
   information; honest report > false PASS.
5. **Equal intensity > ranking** when operator wants portfolio
   coverage across ICP segments.
6. **Operator corrections are gust signals.** Read them as
   trajectory adjustments, not nitpicks.
7. **Conventional estimates from cross-frontier reports are
   conservative.** Cross-validate with empirical VetCoders pace.
8. **Per-lab cwd + per-repo branches = Living Tree clean.**
9. **Marbles correctly stops on report-failed signal.** Don't burn
   iterations on irrelevant ground.
10. **Reality decides.** Demos don't count. Mocks don't count.
    Customer-installable, commit-landed, gate-green code counts.

---

_𝚅𝚒𝚋𝚎𝚌𝚛𝚊𝚏𝚝𝚎𝚍. with AI Agents by VetCoders (c)2024-2026 LibraxisAI_
