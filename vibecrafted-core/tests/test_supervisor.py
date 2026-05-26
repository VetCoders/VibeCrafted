from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

from vibecrafted_core import control_plane
from vibecrafted_core.agent_dispatch import extract_session_id
from vibecrafted_core.events import append_event
from vibecrafted_core.spawn import Supervisor


def test_supervisor_spawn_lifecycle_extracts_session_id(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    home = tmp_path / ".vibecrafted"
    monkeypatch.setenv("VIBECRAFTED_HOME", str(home))
    transcript = tmp_path / "agent.transcript.log"
    meta = tmp_path / "agent.meta.json"
    meta.write_text(json.dumps({"transcript": str(transcript)}), encoding="utf-8")

    command = [
        sys.executable,
        "-c",
        (
            "from pathlib import Path; "
            f"Path({str(transcript)!r}).write_text('[12:00:00] session: codex-test-123\\n', encoding='utf-8')"
        ),
    ]

    handle = Supervisor().spawn(
        "codex",
        "fixture",
        skill="test",
        mode="unit",
        root=tmp_path,
        command=command,
        run_id="test-001",
        meta_path=meta,
        transcript_path=transcript,
    )

    assert handle.wait(timeout=5) == 0
    assert handle.exit_code == 0
    assert handle.session_id == "codex-test-123"
    assert (
        json.loads(meta.read_text(encoding="utf-8"))["session_id"] == "codex-test-123"
    )
    kinds = [event["kind"] for event in control_plane.read_event_tail(10)]
    assert "spawn-completed" in kinds
    assert "spawn-started" in kinds


def test_supervisor_propagates_exit_code(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.setenv("VIBECRAFTED_HOME", str(tmp_path / ".vibecrafted"))

    handle = Supervisor().spawn(
        "codex",
        "fixture",
        skill="test",
        mode="unit",
        root=tmp_path,
        command=[sys.executable, "-c", "raise SystemExit(7)"],
        run_id="test-002",
    )

    assert handle.wait(timeout=5) == 7
    assert handle.exit_code == 7
    kinds = [event["kind"] for event in control_plane.read_event_tail(10)]
    assert "spawn-failed" in kinds


def test_session_id_extractors_use_shared_pattern() -> None:
    repo = Path(__file__).resolve().parents[2]
    fixtures = repo / "tests" / "fixtures" / "transcripts"

    assert (
        extract_session_id("claude", (fixtures / "claude_session.log").read_text())
        == "claude-session-123"
    )
    assert (
        extract_session_id("codex", (fixtures / "codex_session.log").read_text())
        == "codex-session-456"
    )
    assert (
        extract_session_id("gemini", (fixtures / "gemini_session.log").read_text())
        == "gemini-session-789"
    )


def test_subscribe_events_reads_appended_events(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.setenv("VIBECRAFTED_HOME", str(tmp_path / ".vibecrafted"))

    append_event("unit", "run-1", "hello", {"ok": True})
    events = list(control_plane.subscribe_events(kinds={"unit"}))

    assert len(events) == 1
    assert events[0].kind == "unit"
    assert events[0].payload == {"ok": True}
