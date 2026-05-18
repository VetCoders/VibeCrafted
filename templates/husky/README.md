# vibecrafted-husky-template

> One git-hook stack for every VetCoders / LibraxisAI repository.

Modular husky hooks unified from the four legacy snowflakes we accumulated
(`vista`, `vista-portal`, `vetcoders-tools`, `unicode-puzzles-portal`).
Single source of truth for pre-commit / pre-push gates with opt-in steps
per-repo via `.husky/config.env`.

## What it gives you

- **Six hooks** with shared utility lib — `pre-commit`, `pre-push`,
  `pre-merge-commit`, `prepare-commit-msg`, `post-commit`, `commit-msg`.
- **Opt-in steps** — each gate (secrets, lint-staged, tsc, semgrep, loctree,
  cargo, vitest, ...) is a flag in `.husky/config.env`. Repos turn on what
  they have; the rest are no-ops.
- **WARN mode** (vista pattern) — feature branches default to non-blocking
  with `warns/` retention. Protected branches (main / develop / release/\*)
  stay strict.
- **Secret-redaction in hook logs** — anything matching the secret regex is
  replaced with `<REDACTED>` before being written to `.husky/warns/`.
- **Conventional commits** with `[<agent>/<workflow>]` prefix support — same
  regex contract across every repo so commit history stays groupable.
- **Living Tree etiquette** — vendored / generated paths excluded by the
  `is_excluded` predicate (extensible per-repo in config).

## Install into a target repo

From the target repo root:

```bash
bash /path/to/vibecrafted/templates/husky/install.sh
```

or, if you have vibecrafted-current installed:

```bash
bash "$VIBECRAFTED_ROOT/templates/husky/install.sh"
```

The installer:

1. Copies `hooks/*` → `.husky/`
2. Copies `lib/*` → `.husky/lib/` (sourced by each hook)
3. Copies `scripts/*` → `.husky/scripts/` (node helpers)
4. Drops `config/template.husky.env` → `.husky/config.env` if not present
5. Runs `chmod +x .husky/{pre-commit,pre-push,pre-merge-commit,prepare-commit-msg,post-commit,commit-msg}`
6. Adds `.husky/warns/` to `.gitignore` if missing

Re-run is idempotent — existing `.husky/config.env` is preserved, only the
shipped pieces under `lib/`, `scripts/`, and the hook entries are refreshed.

## Configuration — `.husky/config.env`

Single file controls every step. Defaults are conservative (most steps off);
turn on what your repo actually has. Full reference: see
`config/template.husky.env`.

Key knobs:

```bash
# WARN mode — non-blocking on feature branches, strict on protected.
HUSKY_WARN_MODE_ON_FEATURE=1
HUSKY_WARN_PROTECTED_BRANCHES='^(main|develop|release/.*|hotfix/.*)$'
HUSKY_WARN_RETENTION=5

# Pre-commit steps
HUSKY_PRECOMMIT_SECRETS=1
HUSKY_PRECOMMIT_ENV_FILES=1
HUSKY_PRECOMMIT_LINT_STAGED=1
HUSKY_PRECOMMIT_PRETTIER_STAGED=1
HUSKY_PRECOMMIT_ESLINT_STAGED=1
HUSKY_PRECOMMIT_STYLELINT_STAGED=0
HUSKY_PRECOMMIT_TSC=0
HUSKY_PRECOMMIT_SEMGREP_STAGED=1
HUSKY_PRECOMMIT_LOCT_HEALTH=0
HUSKY_PRECOMMIT_LOCT_SUPPRESSIONS=0
HUSKY_PRECOMMIT_RUST_CARGO_CHECK=0
HUSKY_PRECOMMIT_RUSTFMT_STAGED=0
HUSKY_PRECOMMIT_PY_RUFF=0
HUSKY_PRECOMMIT_SH_SHELLCHECK=0

# Pre-push gates
HUSKY_PREPUSH_PRETTIER_FULL=1
HUSKY_PREPUSH_SEMGREP_FULL=1
HUSKY_PREPUSH_TSC=1
HUSKY_PREPUSH_LOCT_CYCLES=0
HUSKY_PREPUSH_LOCT_COMMANDS=0
HUSKY_PREPUSH_VITEST=0
HUSKY_PREPUSH_CARGO_CLIPPY=0
HUSKY_PREPUSH_CARGO_TEST=0

# Commit-msg
HUSKY_COMMIT_MSG_CONVENTIONAL=1
HUSKY_COMMIT_MSG_ALLOW_AGENT_PREFIX=1
HUSKY_COMMIT_MSG_SUBJECT_MAX=100

# Custom exclude paths (one per line)
HUSKY_EXCLUDE_PATHS='
node_modules/
dist/
.loctree/
target/
vendor/
'
```

## Hook responsibilities

| Hook                 | Purpose                                                                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `pre-commit`         | Stage-scoped checks (only staged files): secret scan, env guard, lint-staged, tsc on staged, semgrep on staged, loctree health. WARN-mode aware. |
| `pre-push`           | Full-repo gates: prettier --check, semgrep --config auto, tsc --noEmit, loctree cycles, cargo clippy, vitest.                                    |
| `pre-merge-commit`   | Codex-agent / vendored-path cleanup before merge commit.                                                                                         |
| `prepare-commit-msg` | Appends `Vibecrafted-Warn-Signature` trailer if pre-commit ran in WARN mode.                                                                     |
| `post-commit`        | Warns if Claude-artifact filenames (`RAPORT_*`, `_SESSION_*`, etc.) landed in commit.                                                            |
| `commit-msg`         | Conventional commit regex with optional `[agent/workflow]` prefix.                                                                               |

## WARN mode — how it works

On feature/local branches, hook failures are demoted to warnings: the commit
proceeds but the log is archived to `.husky/warns/<hook>-<timestamp>.log`
(retention `$HUSKY_WARN_RETENTION` rolling). Two consecutive warnings with
the same signature (hash of failure output) escalate back to strict mode —
prevents the same regression sliding through unchecked.

Protected branches (default regex: `^(main|develop|release/.*|hotfix/.*)$`)
always run strict. Override with `HUSKY_STRICT=1` for one-off forced strict
on any branch, or `HUSKY_WARN_FORCE=1` to override into WARN mode.

## Authority labels (per finding)

Each blocking failure carries one of:

- `repo_verified` — file content / git state (top trust)
- `pre_commit_strict` — staged-content rule
- `pre_push_strict` — full-repo rule
- `warn_pending` — same signature seen before, escalates next time
- `silenced_by_config` — step disabled in `.husky/config.env` (informational)

Trailers in commit message:

- `Vibecrafted-Warn-Signature: <sha256>` — hash of the failure that was
  demoted to warn
- `Vibecrafted-Warn-Captured-At: <iso>` — when the demotion happened
- `Vibecrafted-Warn-Head: <sha>` — repo HEAD at the time

## Migration from snowflake hooks

To replace a legacy hook setup:

```bash
# 1. Backup current .husky
mv .husky .husky.bak.$(date +%s)

# 2. Install template
bash ~/Libraxis/vc-runtime/vibecrafted/templates/husky/install.sh

# 3. Port any repo-specific steps to .husky/config.env or to
#    .husky/local/{pre-commit,pre-push}.d/<step>.sh
#    Scripts in .husky/local/<hook>.d/ run in addition to template steps,
#    skipped automatically if the directory does not exist.

# 4. Verify
git commit --allow-empty -m "chore(husky): smoke test"
```

The repo-local extension hook (`.husky/local/<hook>.d/*.sh`) gives you a
clean place to keep one-off concerns (manifest:ensure, custom file guards)
without forking the template.

## License

BUSL — same as the parent vibecrafted project. Free for use inside any
VetCoders / LibraxisAI repository, third-party usage subject to the BUSL
conversion timeline.

---

_Vibecrafted with AI Agents by VetCoders (c)2024-2026 LibraxisAI_
