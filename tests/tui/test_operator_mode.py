from __future__ import annotations

import os
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
HELPER_SCRIPT = REPO_ROOT / "skills" / "vc-agents" / "shell" / "vetcoders.sh"


def _write_capture_command(bin_dir: Path, name: str, capture_file: Path) -> None:
    script = bin_dir / name
    script.write_text(
        "\n".join(
            [
                "#!/usr/bin/env bash",
                "set -euo pipefail",
                'printf "%s\\n" "$@" > "$CAPTURE_FILE"',
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    script.chmod(0o755)


def test_vc_start_launches_operator_entrypoint_layout(tmp_path: Path) -> None:
    home = tmp_path / "home"
    fake_bin = tmp_path / "bin"
    capture_file = tmp_path / "zellij-args.txt"

    home.mkdir()
    fake_bin.mkdir()
    _write_capture_command(fake_bin, "zellij", capture_file)

    env = os.environ.copy()
    env["HOME"] = str(home)
    env["PATH"] = f"{fake_bin}:{env.get('PATH', '')}"
    env["XDG_CONFIG_HOME"] = str(tmp_path / "xdg")
    env["VIBECRAFT_ROOT"] = str(REPO_ROOT)
    env["CAPTURE_FILE"] = str(capture_file)
    env.pop("ZELLIJ_CONFIG_DIR", None)

    subprocess.run(
        ["bash", "-lc", f'source "{HELPER_SCRIPT}"; vc-start'],
        check=True,
        cwd=REPO_ROOT,
        env=env,
    )

    payload = capture_file.read_text(encoding="utf-8").splitlines()
    assert "--session" in payload
    assert "vibecrafted" in payload
    assert "--new-session-with-layout" in payload
    assert (
        str(REPO_ROOT / "config" / "zellij" / "layouts" / "vibecrafted.kdl") in payload
    )


def test_marbles_from_operator_mode_spawns_launcher_below_and_loops_right(
    tmp_path: Path,
) -> None:
    home = tmp_path / "home"
    fake_bin = tmp_path / "bin"
    capture_file = tmp_path / "zellij-args.txt"

    home.mkdir()
    fake_bin.mkdir()
    _write_capture_command(fake_bin, "zellij", capture_file)

    env = os.environ.copy()
    env["HOME"] = str(home)
    env["PATH"] = f"{fake_bin}:{env.get('PATH', '')}"
    env["VIBECRAFT_ROOT"] = str(REPO_ROOT)
    env["CAPTURE_FILE"] = str(capture_file)
    env["ZELLIJ"] = "operator"

    subprocess.run(
        [
            "bash",
            "-lc",
            f'source "{HELPER_SCRIPT}"; codex-marbles --prompt "Check runtime" --count 2',
        ],
        check=True,
        cwd=REPO_ROOT,
        env=env,
    )

    payload = capture_file.read_text(encoding="utf-8").splitlines()
    assert "--direction" in payload
    assert "down" in payload
    command_line = next(line for line in payload if "marbles_spawn.sh" in line)
    assert "VIBECRAFT_ZELLIJ_SPAWN_DIRECTION=right" in command_line
