from __future__ import annotations

from pathlib import Path

from vibecrafted_core import workflow
from vibecrafted_core.agent_dispatch import sandbox_supported
from vibecrafted_core.spawn import _default_command


def test_workflow_launch_spec_accepts_agy_junie_and_grok(tmp_path: Path) -> None:
    for agent in ("agy", "junie", "grok"):
        spec = workflow.normalize_launch_spec(
            {"skill": "workflow", "agent": agent, "prompt": "go"},
            tmp_path,
        )
        assert spec.agent == agent


def test_build_launch_command_passes_new_agent_to_command_deck(tmp_path: Path) -> None:
    source = tmp_path / "src"
    scripts = source / "scripts"
    scripts.mkdir(parents=True)
    launcher = scripts / "vibecrafted"
    launcher.write_text("#!/usr/bin/env bash\nexit 0\n", encoding="utf-8")

    spec = workflow.WorkflowLaunchSpec(
        agent="junie",
        mode="workflow",
        skill="workflow",
        prompt="go",
        file="",
        runtime="headless",
        root=str(tmp_path),
    )

    assert workflow.build_launch_command(spec, source)[:4] == [
        "bash",
        str(launcher),
        "workflow",
        "junie",
    ]


def test_supervisor_defaults_and_sandbox_support_cover_agy_junie_grok() -> None:
    assert sandbox_supported("agy") is True
    assert sandbox_supported("junie") is True
    assert sandbox_supported("grok") is True
    agy_command = _default_command("agy", "go")
    assert agy_command[:3] == [
        "bash",
        "-lc",
        "agy --print --dangerously-skip-permissions --add-dir . --print-timeout 30m '' <<< \"$1\"",
    ]
    assert agy_command[3:] == ["agy", "go"]
    assert _default_command("junie", "go")[:2] == ["junie", "--task"]
    assert _default_command("grok", "go")[:2] == ["grok", "--cwd"]
    assert "--single" in _default_command("grok", "go")
