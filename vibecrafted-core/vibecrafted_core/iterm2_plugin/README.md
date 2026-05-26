# vibecrafted — iTerm2 / locterm plugin

This subpackage ships the vibecrafted cockpit for macOS users running
**iTerm2** or VetCoders' **locterm** fork. It surfaces live spawn
activity in the iTerm2 status bar, auto-tags panes per agent + skill via
iTerm2 Triggers, and posts native notifications on terminal spawn
lifecycle transitions. It reuses the 833 LOC production-grade
`iterm2_osc.py` (306 LOC) + `iterm2_profiles.py` (527 LOC) modules
already shipped with `vibecrafted-core`.

## Architecture — GPL separation by design

iTerm2 / locterm is GPL v2. vibecrafted is proprietary. The plugin is
deliberately structured to keep the licenses cleanly separated:

- The AutoLaunch script (`vc_launcher.py`) runs as a **separate
  process** under iTerm2's own vendored Python sandbox.
- The plugin talks to iTerm2 / locterm only via the **documented
  WebSocket Python API** (`iterm2.async_get_app`, `StatusBarComponent`,
  `Trigger`, `notifications`). No source mixing, no static linking.
- No vibecrafted file imports or links against any locterm Objective-C,
  Swift or Rust module.
- The installer drops a single symlink into
  `~/Library/Application Support/iTerm2/Scripts/AutoLaunch/`. The locterm
  app itself is never modified, repackaged, or redistributed.

That places vibecrafted and locterm into the FSF's "mere aggregation"
category (two separate programs that happen to talk over a stable IPC
boundary), which does not propagate GPL.

## Install

```bash
# 1. Install the optional dependency group (host venv, not iTerm2 sandbox):
pip install -e '.[iterm2]'

# 2. Symlink the AutoLaunch script:
python -m vibecrafted_core.iterm2_plugin.install_autolaunch

# 3. iTerm2 Preferences → General → Magic → Enable Python API.
#    Restart iTerm2 / locterm.
#
# 4. Preferences → Profiles → Session → Status Bar → Components →
#    drag "vibecrafted" onto the status bar.
```

`scripts/install-foundations.sh` will offer to run step 2 automatically
when it detects iTerm2 or locterm at `/Applications/iTerm.app` /
`/Applications/locterm.app`.

## Uninstall

```bash
python -m vibecrafted_core.iterm2_plugin.install_autolaunch --uninstall
# or
bash "$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch/uninstall_vc_launcher.sh"
```

## What the plugin does at runtime

1. iTerm2 / locterm boots and runs every script in `AutoLaunch/`.
2. `vc_launcher.py` connects to the iTerm2 daemon over the local
   WebSocket API.
3. It tails `$VIBECRAFTED_HOME/control_plane/events.jsonl` (default
   `~/.vibecrafted/control_plane/events.jsonl`).
4. On every `spawn-update` event, it updates the registered status bar
   component (`io.vetcoders.vibecrafted.status`) and, on `completed` /
   `failed` transitions, posts an iTerm2 native notification.
5. It installs six pre-baked Triggers on the user's default profile so
   panes auto-tag themselves with `vc_agent=<agent>/<skill>` when an
   agent CLI announces itself.
6. On lost connection (iTerm2 restart, sleep/wake) it reconnects with
   exponential backoff.

## Files

| File                    | Purpose                                          |
| ----------------------- | ------------------------------------------------ |
| `vc_launcher.py`        | AutoLaunch entrypoint, event tail, reconnect.    |
| `vc_status_bar.py`      | `StatusBarComponent` + click → open transcript.  |
| `vc_triggers.py`        | Pre-baked vibecrafted Triggers (regex + action). |
| `install_autolaunch.py` | Symlink installer + uninstaller.                 |

## Operator runbook

| Symptom                                                                             | Likely cause                                                                                |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Status bar component never appears                                                  | Python API not enabled in iTerm2 Preferences.                                               |
| Status bar always shows `vc: 0`                                                     | `$VIBECRAFTED_HOME/control_plane/events.jsonl` not being written. Run `vibecrafted status`. |
| `python -m vibecrafted_core.iterm2_plugin.install_autolaunch` fails with permission | Re-run from a shell that owns `~/Library/Application Support/iTerm2/`.                      |
| Triggers do not fire                                                                | Open Preferences → Profiles → Advanced → Triggers and verify the `vibecrafted:` rows exist. |

Logs land in iTerm2's Scripts Console (`Scripts → Manage → Console`).
Set `VIBECRAFTED_PLUGIN_LOGLEVEL=DEBUG` to widen the trace.
