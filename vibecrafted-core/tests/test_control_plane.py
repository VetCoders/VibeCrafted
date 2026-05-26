from __future__ import annotations

import json
from pathlib import Path

import pytest

from vibecrafted_core import control_plane


def _write_meta(home: Path, payload: dict[str, object]) -> Path:
    reports = home / "artifacts" / "VetCoders" / "vibecrafted" / "2026_0519" / "reports"
    reports.mkdir(parents=True)
    path = reports / f"{payload['run_id']}.meta.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    return path


def test_sync_state_preserves_runtime_observe_fields(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    home = tmp_path / ".vibecrafted"
    monkeypatch.setenv("VIBECRAFTED_HOME", str(home))
    completed_at = "2026-05-19T00:01:00+00:00"
    _write_meta(
        home,
        {
            "run_id": "impl-010101-42",
            "status": "completed",
            "agent": "codex",
            "mode": "implement",
            "root": str(tmp_path),
            "report": "/tmp/report.md",
            "transcript": "/tmp/transcript.log",
            "updated_at": completed_at,
            "started_at": "2026-05-19T00:00:00+00:00",
            "skill_code": "impl",
            "exit_code": 0,
            "liveness": "terminal",
            "launcher_pid": 12345,
            "completed_at": completed_at,
            "session_id": "session-abc",
        },
    )

    snapshot = control_plane.sync_state()

    run = snapshot["recent_runs"][0]
    assert run["run_id"] == "impl-010101-42"
    assert run["exit_code"] == 0
    assert run["liveness"] == "terminal"
    assert run["launcher_pid"] == 12345
    assert run["completed_at"] == completed_at
    assert run["session_id"] == "session-abc"


def test_lookup_run_uses_synced_snapshot(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    home = tmp_path / ".vibecrafted"
    monkeypatch.setenv("VIBECRAFTED_HOME", str(home))
    _write_meta(
        home,
        {
            "run_id": "rvew-020202-42",
            "status": "running",
            "agent": "claude",
            "mode": "review",
            "root": str(tmp_path),
            "updated_at": "2026-05-19T00:00:00+00:00",
            "skill_code": "rvew",
            "launcher_pid": "333",
            "liveness": "pid_alive",
        },
    )

    run = control_plane.lookup_run("rvew-020202-42")

    assert run is not None
    assert run["agent"] == "claude"
    assert run["launcher_pid"] == 333
    assert run["liveness"] == "pid_alive"


def test_await_run_completes_from_metadata_without_transcript(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    home = tmp_path / ".vibecrafted"
    monkeypatch.setenv("VIBECRAFTED_HOME", str(home))
    _write_meta(
        home,
        {
            "run_id": "wflw-030303-42",
            "status": "running",
            "agent": "codex",
            "mode": "workflow",
            "root": str(tmp_path),
            "updated_at": "2026-05-19T00:00:00+00:00",
            "skill_code": "wflw",
            "exit_code": "0",
            "liveness": "terminal",
        },
    )

    payload = control_plane.await_run(
        "wflw-030303-42", timeout_seconds=0, interval_seconds=0.1
    )

    assert payload["completed"] is True
    assert payload["timed_out"] is False
    assert payload["run"]["exit_code"] == 0


def test_await_run_times_out_when_metadata_missing(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.setenv("VIBECRAFTED_HOME", str(tmp_path / ".vibecrafted"))

    payload = control_plane.await_run(
        "missing-040404-42", timeout_seconds=0, interval_seconds=0.1
    )

    assert payload["found"] is False
    assert payload["completed"] is False
    assert payload["timed_out"] is True
