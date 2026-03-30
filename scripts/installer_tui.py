#!/usr/bin/env python3
from __future__ import annotations

import contextlib
import os
import queue
import select
import shutil
import subprocess
import sys
import termios
import threading
import tty
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable

STEP_MIN = 0
STEP_MAX = 5
STEP_COUNT = STEP_MAX + 1
DIAGNOSTICS_STEP = 3
CHECKLIST_STEP = 4
INSTALL_STEP = 5

STEP_LABELS = {
    0: "welcome",
    1: "explain",
    2: "listing",
    3: "diagnostics",
    4: "checklist",
    5: "installation",
}

CATEGORY_LABELS = {
    "frameworks": "Frameworks",
    "foundations": "Foundations",
    "toolchains": "Toolchains",
    "agents": "Agents",
    "additional_tools": "Additional tools",
}

CATEGORY_ORDER = tuple(CATEGORY_LABELS)
FOUNDATION_COMMANDS = ("loctree-mcp", "aicx-mcp", "prview", "screenscribe")
TOOLCHAIN_COMMANDS = ("python3", "node", "git", "rsync")
AGENT_COMMANDS = ("claude", "codex", "gemini")
ADDITIONAL_TOOL_COMMANDS = ("zellij", "mise", "starship", "atuin", "zoxide")
INSTALL_OUTPUT_TAIL = 18
READ_KEY_TIMEOUT = 0.1


def default_source_dir() -> str:
    return str(Path(__file__).resolve().parent.parent)


def read_framework_version(source_dir: str) -> str:
    version_file = Path(source_dir) / "VERSION"
    if version_file.exists():
        return version_file.read_text(encoding="utf-8").strip()
    return "unknown"


def xdg_config_home() -> Path:
    raw = os.environ.get("XDG_CONFIG_HOME")
    if raw:
        return Path(raw).expanduser()
    return Path.home() / ".config"


def framework_store_dir() -> Path:
    return Path.home() / ".vibecrafted" / "skills"


def helper_layer_path() -> Path:
    return xdg_config_home() / "vetcoders" / "vc-skills.sh"


def runtime_skill_views() -> dict[str, Path]:
    home = Path.home()
    return {
        "agents": home / ".agents" / "skills",
        "claude": home / ".claude" / "skills",
        "codex": home / ".codex" / "skills",
        "gemini": home / ".gemini" / "skills",
    }


def installer_script_path(source_dir: str) -> Path:
    return Path(source_dir).resolve() / "scripts" / "vetcoders_install.py"


def build_install_command(source_dir: str) -> list[str]:
    installer_path = installer_script_path(source_dir)
    if not installer_path.exists():
        raise FileNotFoundError(f"Installer not found at {installer_path}")
    return [
        sys.executable,
        str(installer_path),
        "install",
        "--source",
        str(Path(source_dir).resolve()),
        "--with-shell",
        "--compact",
        "--non-interactive",
    ]


def _command_check(name: str) -> dict[str, Any]:
    path = shutil.which(name)
    return {
        "label": name,
        "found": bool(path),
        "detail": path or f"{name} not found on PATH",
        "kind": "command",
    }


def _path_check(
    label: str, path: Path, *, found: bool | None = None, detail: str | None = None
) -> dict[str, Any]:
    is_found = path.exists() if found is None else found
    return {
        "label": label,
        "found": is_found,
        "detail": detail or str(path),
        "kind": "path",
    }


def _framework_checks() -> dict[str, dict[str, Any]]:
    store_dir = framework_store_dir()
    helper_file = helper_layer_path()
    skills = []
    if store_dir.is_dir():
        skills = sorted(
            child.name
            for child in store_dir.iterdir()
            if child.is_dir() and child.name.startswith("vc-")
        )

    binary_path = shutil.which("vibecraft") or shutil.which("vibecrafted")

    active_views = []
    for runtime, path in runtime_skill_views().items():
        if not path.is_dir():
            continue
        entries = [entry.name for entry in path.iterdir()]
        if entries:
            active_views.append(f"{runtime} ({len(entries)})")

    return {
        "workflows": _path_check(
            "workflows",
            store_dir,
            found=bool(skills),
            detail=f"{len(skills)} installed skill directories in {store_dir}"
            if skills
            else f"No installed skill directories in {store_dir}",
        ),
        "helpers": _path_check(
            "helpers",
            helper_file,
            detail=str(helper_file)
            if helper_file.exists()
            else f"Missing helper file at {helper_file}",
        ),
        "binaries": {
            "label": "binaries",
            "found": bool(binary_path),
            "detail": binary_path or "vibecraft/vibecrafted not found on PATH",
            "kind": "command",
        },
        "symlinks": {
            "label": "symlinks",
            "found": bool(active_views),
            "detail": ", ".join(active_views)
            if active_views
            else "No runtime skill views detected in ~/.agents, ~/.claude, ~/.codex, or ~/.gemini",
            "kind": "path",
        },
    }


def run_diagnostics() -> dict[str, dict[str, dict[str, Any]]]:
    """Check: frameworks, foundations, toolchains, agents, tools."""
    diagnostics: dict[str, dict[str, dict[str, Any]]] = {}
    diagnostics["frameworks"] = _framework_checks()
    diagnostics["foundations"] = {
        name: _command_check(name) for name in FOUNDATION_COMMANDS
    }
    diagnostics["toolchains"] = {
        name: _command_check(name) for name in TOOLCHAIN_COMMANDS
    }
    diagnostics["agents"] = {name: _command_check(name) for name in AGENT_COMMANDS}
    diagnostics["additional_tools"] = {
        name: _command_check(name) for name in ADDITIONAL_TOOL_COMMANDS
    }
    return diagnostics


def summarize_diagnostics(
    diagnostics: dict[str, dict[str, dict[str, Any]]],
) -> tuple[list[str], list[str], dict[str, list[str]]]:
    found_items: list[str] = []
    missing_items: list[str] = []
    needs_install: dict[str, list[str]] = {}

    for category in CATEGORY_ORDER:
        missing_in_category: list[str] = []
        for name, entry in diagnostics.get(category, {}).items():
            label = entry.get("label", name)
            flat_label = f"{CATEGORY_LABELS[category]}: {label}"
            if entry.get("found"):
                found_items.append(flat_label)
            else:
                missing_items.append(flat_label)
                missing_in_category.append(label)
        if missing_in_category:
            needs_install[category] = missing_in_category

    return found_items, missing_items, needs_install


@dataclass
class InstallerState:
    step: int = 0
    diagnostics: dict[str, dict[str, dict[str, Any]]] = field(default_factory=dict)
    consent_given: bool = False
    install_running: bool = False
    install_output: list[str] = field(default_factory=list)
    needs_install: dict[str, list[str]] = field(default_factory=dict)
    found_items: list[str] = field(default_factory=list)
    missing_items: list[str] = field(default_factory=list)
    diagnostics_ran: bool = False
    diagnostics_running: bool = False
    diagnostics_output: list[str] = field(default_factory=list)
    details_view: bool = False
    should_quit: bool = False
    status_message: str = ""
    source_dir: str = field(default_factory=default_source_dir)
    version: str = ""
    install_command: list[str] = field(default_factory=list)
    install_exit_code: int | None = None
    install_completed: bool = False
    install_result: subprocess.CompletedProcess[str] | None = field(
        default=None, repr=False
    )
    install_error: str | None = None
    _install_queue: queue.Queue[tuple[str, str]] = field(
        default_factory=queue.Queue, init=False, repr=False
    )
    _install_thread: threading.Thread | None = field(
        default=None, init=False, repr=False
    )
    _install_process: subprocess.Popen[str] | None = field(
        default=None, init=False, repr=False
    )

    def __post_init__(self) -> None:
        self.step = clamp_step(self.step)
        if not self.version:
            self.version = read_framework_version(self.source_dir)

    @property
    def step_label(self) -> str:
        return STEP_LABELS.get(self.step, f"step-{self.step}")

    @property
    def can_go_back(self) -> bool:
        return self.step > STEP_MIN and not self.install_running

    @property
    def can_go_forward(self) -> bool:
        if self.install_running:
            return False
        if self.step == CHECKLIST_STEP:
            return True
        if self.step >= INSTALL_STEP:
            return False
        return True

    @property
    def current_install_tail(self) -> list[str]:
        if not self.install_output:
            return []
        return self.install_output[-INSTALL_OUTPUT_TAIL:]


def clamp_step(step: int) -> int:
    return max(STEP_MIN, min(STEP_MAX, step))


def refresh_diagnostics(state: InstallerState) -> InstallerState:
    state.diagnostics_running = True
    state.diagnostics_output = [
        "Checking frameworks...",
        "Checking foundations...",
        "Checking toolchains...",
        "Checking agent CLIs...",
        "Checking additional tools...",
    ]
    state.diagnostics = run_diagnostics()
    state.found_items, state.missing_items, state.needs_install = summarize_diagnostics(
        state.diagnostics
    )
    state.diagnostics_output.extend(
        f"{CATEGORY_LABELS[category]}: "
        f"{sum(1 for entry in state.diagnostics.get(category, {}).values() if entry.get('found'))}/"
        f"{len(state.diagnostics.get(category, {}))} present"
        for category in CATEGORY_ORDER
    )
    state.diagnostics_ran = True
    state.diagnostics_running = False
    state.status_message = f"Diagnostics complete: {len(state.found_items)} found, {len(state.missing_items)} missing."
    return state


def run_install(source_dir: str) -> subprocess.CompletedProcess[str]:
    """Call vetcoders_install.py install --compact."""
    command = build_install_command(source_dir)
    return subprocess.run(
        command,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )


def _install_worker(
    source_dir: str,
    event_queue: queue.Queue[tuple[str, str]],
    process_setter: Callable[[subprocess.Popen[str] | None], None],
) -> None:
    command = build_install_command(source_dir)
    stdout_lines: list[str] = []
    process: subprocess.Popen[str] | None = None
    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        process_setter(process)
        event_queue.put(("started", " ".join(command)))
        assert process.stdout is not None
        for line in process.stdout:
            clean = line.rstrip("\n")
            stdout_lines.append(clean)
            event_queue.put(("line", clean))
        return_code = process.wait()
        event_queue.put(("returncode", str(return_code)))
        event_queue.put(("stdout", "\n".join(stdout_lines)))
    except Exception as exc:  # pragma: no cover - defensive path
        event_queue.put(("error", str(exc)))
    finally:
        process_setter(None)


def start_install(state: InstallerState) -> InstallerState:
    if state.install_running or state.install_completed:
        return state
    state.install_output = []
    state.install_error = None
    state.install_exit_code = None
    state.install_completed = False
    try:
        state.install_command = build_install_command(state.source_dir)
    except FileNotFoundError as exc:
        state.install_error = str(exc)
        state.install_exit_code = -1
        state.install_completed = True
        state.install_running = False
        state.status_message = str(exc)
        return state
    state.install_running = True
    state.status_message = "Running compact installer..."
    state._install_queue = queue.Queue()

    def _set_process(process: subprocess.Popen[str] | None) -> None:
        state._install_process = process

    worker = threading.Thread(
        target=_install_worker,
        args=(state.source_dir, state._install_queue, _set_process),
        daemon=True,
        name="installer-tui-install",
    )
    state._install_thread = worker
    worker.start()
    return state


def pump_install_output(state: InstallerState) -> bool:
    changed = False
    while True:
        try:
            kind, payload = state._install_queue.get_nowait()
        except queue.Empty:
            break

        changed = True
        if kind == "started":
            state.status_message = "Installer subprocess started."
        elif kind == "line":
            state.install_output.append(payload)
        elif kind == "returncode":
            state.install_exit_code = int(payload)
            state.install_running = False
            state.install_completed = True
            if state.install_exit_code == 0:
                state.status_message = "Installation finished successfully."
            else:
                state.status_message = (
                    f"Installation exited with code {state.install_exit_code}."
                )
        elif kind == "stdout":
            state.install_result = subprocess.CompletedProcess(
                args=state.install_command,
                returncode=state.install_exit_code
                if state.install_exit_code is not None
                else -1,
                stdout=payload,
            )
        elif kind == "error":
            state.install_running = False
            state.install_completed = True
            state.install_error = payload
            state.install_exit_code = -1
            state.status_message = f"Installation failed to start: {payload}"
    return changed


def goto_step(state: InstallerState, step: int) -> InstallerState:
    state.step = clamp_step(step)
    if state.step >= DIAGNOSTICS_STEP and not state.diagnostics_ran:
        refresh_diagnostics(state)
    if (
        state.step == INSTALL_STEP
        and state.consent_given
        and not state.install_running
        and not state.install_completed
    ):
        start_install(state)
    return state


def handle_key(state: InstallerState, key: str | None) -> InstallerState:
    """Arrow/Enter/q navigation."""
    if key is None:
        return state

    if key == "tab":
        state.details_view = not state.details_view
        return state

    if key in {"q", "escape"}:
        if state.install_running:
            state.status_message = "Install is still running; wait for it to finish."
            return state
        state.should_quit = True
        return state

    if key in {"left", "up", "backspace"}:
        if state.install_running:
            state.status_message = (
                "Back navigation is disabled while install is running."
            )
            return state
        return goto_step(state, state.step - 1)

    if key not in {"right", "down", "enter"}:
        return state

    if state.step < DIAGNOSTICS_STEP:
        return goto_step(state, state.step + 1)

    if state.step == DIAGNOSTICS_STEP:
        if not state.diagnostics_ran:
            refresh_diagnostics(state)
        return goto_step(state, CHECKLIST_STEP)

    if state.step == CHECKLIST_STEP:
        state.consent_given = True
        state.status_message = "Install approved. Launching installer..."
        return goto_step(state, INSTALL_STEP)

    if state.step == INSTALL_STEP:
        if state.install_running:
            state.status_message = "Installer is already running."
            return state
        if state.install_completed:
            state.should_quit = True
            return state
        if not state.consent_given:
            state.status_message = "Review the checklist before starting install."
            return state
        return start_install(state)

    return state


@contextlib.contextmanager
def raw_terminal_mode(enabled: bool):
    if not enabled:
        yield
        return

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        yield
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def read_key(timeout: float = READ_KEY_TIMEOUT) -> str | None:
    if not sys.stdin.isatty():
        return None

    ready, _, _ = select.select([sys.stdin], [], [], timeout)
    if not ready:
        return None

    char = sys.stdin.read(1)
    if char in ("\n", "\r"):
        return "enter"
    if char == "\t":
        return "tab"
    if char in ("\x7f", "\b"):
        return "backspace"
    if char in {"q", "Q"}:
        return "q"
    if char == "\x03":
        raise KeyboardInterrupt
    if char != "\x1b":
        return char

    sequence = char
    while True:
        ready, _, _ = select.select([sys.stdin], [], [], 0.01)
        if not ready:
            break
        sequence += sys.stdin.read(1)
        if sequence in {"\x1b[A", "\x1b[B", "\x1b[C", "\x1b[D"}:
            break

    return {
        "\x1b[A": "up",
        "\x1b[B": "down",
        "\x1b[C": "right",
        "\x1b[D": "left",
    }.get(sequence, "escape")


class SimpleConsole:
    def clear(self) -> None:
        if sys.stdout.isatty():
            sys.stdout.write("\033[2J\033[H")
            sys.stdout.flush()

    def print(self, *parts: object) -> None:
        print(*parts)


def make_console() -> Any:
    try:
        from rich.console import Console
    except ImportError:
        return SimpleConsole()
    return Console()


# === RENDER SECTION (Gemini fills this) ===
def render(state: InstallerState, console: Any) -> None:
    """Placeholder renderer.

    Gemini owns the visual layer. This stub keeps the mechanics runnable and
    exposes the state shape for the richer render pass.
    """
    if hasattr(console, "clear"):
        console.clear()

    lines = [
        f"VibeCrafted installer v{state.version}",
        f"Step {state.step}/{STEP_MAX} [{state.step_label}]",
        f"Diagnostics: {'ready' if state.diagnostics_ran else 'pending'}",
        f"Consent: {'yes' if state.consent_given else 'no'}",
        f"Install: {'running' if state.install_running else 'idle'}",
    ]

    if state.status_message:
        lines.append(state.status_message)

    if state.step >= DIAGNOSTICS_STEP and state.needs_install:
        missing = ", ".join(state.missing_items[:5])
        lines.append(f"Missing: {missing}")

    if state.install_output:
        lines.append("Recent installer output:")
        lines.extend(f"  {line}" for line in state.current_install_tail)

    for line in lines:
        console.print(line)


def main_loop(
    state: InstallerState | None = None, console: Any | None = None
) -> InstallerState:
    """Read key -> update state -> render (Gemini's job)."""
    state = state or InstallerState()
    console = console or make_console()

    interactive = sys.stdin.isatty() and sys.stdout.isatty()
    if state.step >= DIAGNOSTICS_STEP and not state.diagnostics_ran:
        refresh_diagnostics(state)

    dirty = True
    with raw_terminal_mode(interactive):
        while not state.should_quit:
            if pump_install_output(state):
                dirty = True

            if dirty:
                render(state, console)
                dirty = False

            key = read_key(READ_KEY_TIMEOUT if interactive else 0.0)
            if key is None:
                if not interactive and not state.install_running:
                    break
                continue

            handle_key(state, key)
            dirty = True

    if not interactive:
        render(state, console)
    return state


def main() -> int:
    state = InstallerState()
    try:
        state = main_loop(state)
    except KeyboardInterrupt:
        return 130
    return state.install_exit_code or 0


if __name__ == "__main__":
    raise SystemExit(main())
