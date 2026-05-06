//! Key handling for the 5-step wizard flow.

use std::path::PathBuf;

use anyhow::Result;
use crossterm::event::{KeyCode, KeyEvent};

use super::services::{build_services_from_scans, check_health, enrich_running_state};
use super::types::{
    AppState, PendingAction, SourceEntry, SourceStatus, Strategy, SummaryAction, TrayChoice,
    WizardStep,
};

/// Top-level key dispatcher. Returns `Ok(true)` to break the TUI loop.
pub fn handle_key(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    match app.wizard_step {
        WizardStep::DiscoverySources => handle_step1(app, key),
        WizardStep::ServerReview => handle_step2(app, key),
        WizardStep::StrategyChoice => handle_step3(app, key),
        WizardStep::SummaryConfirm => handle_step4(app, key),
        WizardStep::ResultAndTray => handle_step5(app, key),
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: Discovery sources
// ─────────────────────────────────────────────────────────────────────────────

fn handle_step1(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    // While editing the custom path, every keystroke goes into the buffer.
    if app.custom_path.editing {
        match key.code {
            KeyCode::Esc => {
                app.custom_path.editing = false;
                update_step1_message(app);
            }
            KeyCode::Enter => {
                let path = std::mem::take(&mut app.custom_path.buffer);
                app.custom_path.editing = false;
                if path.trim().is_empty() {
                    app.custom_path.status = Some("Path was empty.".into());
                } else {
                    add_custom_source(app, &path);
                }
                update_step1_message(app);
            }
            KeyCode::Backspace => {
                app.custom_path.buffer.pop();
            }
            KeyCode::Char(c) => {
                app.custom_path.buffer.push(c);
            }
            _ => {}
        }
        return Ok(false);
    }

    match key.code {
        KeyCode::Char('q') => return Ok(true),
        KeyCode::Char('i') => {
            app.custom_path.editing = true;
            app.message = "Editing custom path… type a path, Enter to add, Esc to cancel.".into();
        }
        KeyCode::Up if app.selected_source > 0 => {
            app.selected_source -= 1;
        }
        KeyCode::Down if app.selected_source + 1 < app.sources.len() => {
            app.selected_source += 1;
        }
        KeyCode::Char(' ') if !app.sources.is_empty() => {
            let idx = app.selected_source.min(app.sources.len() - 1);
            app.sources[idx].selected = !app.sources[idx].selected;
            update_step1_message(app);
        }
        KeyCode::Char('n') | KeyCode::Enter | KeyCode::Right => {
            advance_to_step2(app);
        }
        _ => {}
    }
    Ok(false)
}

fn add_custom_source(app: &mut AppState, raw_path: &str) {
    let expanded = crate::config::expand_path(raw_path);
    let path = PathBuf::from(&expanded);
    let host_file = crate::scan::host_file_from_custom_path(&path);
    let status = if !path.exists() {
        SourceStatus::Missing
    } else {
        match crate::scan::scan_host_file(&host_file) {
            Ok(scan) if scan.services.is_empty() => SourceStatus::Empty,
            Ok(scan) => SourceStatus::Ok {
                servers_found: scan.services.len(),
            },
            Err(err) => SourceStatus::InvalidFormat {
                details: err.to_string(),
            },
        }
    };
    app.custom_path.status = Some(format!(
        "Added {}: {}",
        host_file.path.display(),
        status.short_label()
    ));
    app.sources.push(SourceEntry {
        host_file,
        status,
        selected: true,
    });
    app.selected_source = app.sources.len() - 1;
}

fn update_step1_message(app: &mut AppState) {
    if app.custom_path.editing {
        app.message = "Editing custom path… type a path, Enter to add, Esc to cancel.".into();
        return;
    }
    let selected = app.sources.iter().filter(|s| s.selected).count();
    let total = app.sources.len();
    app.message = format!(
        "STEP 1: {selected}/{total} sources selected | Space toggle | i custom path | n next | q quit"
    );
}

fn advance_to_step2(app: &mut AppState) {
    let scans: Vec<_> = app
        .sources
        .iter()
        .filter(|s| s.selected && matches!(s.status, SourceStatus::Ok { .. }))
        .filter_map(|s| crate::scan::scan_host_file(&s.host_file).ok())
        .collect();

    let mut services = build_services_from_scans(&scans);
    enrich_running_state(&mut services);

    // Cheap health checks on entries with sockets, so STEP 2 has badge data
    // available if a future view turns the column on.
    for svc in &mut services {
        svc.health = check_health(&svc.config);
    }

    app.services = services;
    app.selected_service = 0;
    app.wizard_step = WizardStep::ServerReview;
    update_step2_message(app);
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: Server review
// ─────────────────────────────────────────────────────────────────────────────

fn handle_step2(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    match key.code {
        KeyCode::Char('q') => return Ok(true),
        KeyCode::Up if app.selected_service > 0 => {
            app.selected_service -= 1;
        }
        KeyCode::Down if app.selected_service + 1 < app.services.len() => {
            app.selected_service += 1;
        }
        KeyCode::Char(' ') if !app.services.is_empty() => {
            let idx = app.selected_service.min(app.services.len() - 1);
            app.services[idx].selected = !app.services[idx].selected;
            update_step2_message(app);
        }
        KeyCode::Char('n') | KeyCode::Right | KeyCode::Enter => {
            if app.services.iter().filter(|s| s.selected).count() == 0 {
                app.message = "Select at least one server (Space) before continuing.".into();
            } else {
                app.wizard_step = WizardStep::StrategyChoice;
                update_step3_message(app);
            }
        }
        KeyCode::Char('p') | KeyCode::Left => {
            app.wizard_step = WizardStep::DiscoverySources;
            update_step1_message(app);
        }
        _ => {}
    }
    Ok(false)
}

fn update_step2_message(app: &mut AppState) {
    let selected = app.services.iter().filter(|s| s.selected).count();
    app.message = format!(
        "STEP 2: {selected}/{} servers selected | Space toggle | n next | p prev | q quit",
        app.services.len()
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: Strategy
// ─────────────────────────────────────────────────────────────────────────────

fn handle_step3(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    let order = [Strategy::Unified, Strategy::PerClient, Strategy::AutoRewire];
    let idx = order.iter().position(|s| *s == app.strategy).unwrap_or(0);
    match key.code {
        KeyCode::Char('q') => return Ok(true),
        KeyCode::Up => {
            if idx > 0 {
                app.strategy = order[idx - 1];
            }
        }
        KeyCode::Down => {
            if idx + 1 < order.len() {
                app.strategy = order[idx + 1];
            }
        }
        KeyCode::Char('1') => app.strategy = Strategy::Unified,
        KeyCode::Char('2') => app.strategy = Strategy::PerClient,
        KeyCode::Char('3') => app.strategy = Strategy::AutoRewire,
        KeyCode::Char('n') | KeyCode::Right | KeyCode::Enter => {
            app.wizard_step = WizardStep::SummaryConfirm;
            app.summary_action = SummaryAction::Confirm;
            update_step4_message(app);
        }
        KeyCode::Char('p') | KeyCode::Left => {
            app.wizard_step = WizardStep::ServerReview;
            update_step2_message(app);
        }
        _ => {}
    }
    Ok(false)
}

fn update_step3_message(app: &mut AppState) {
    app.message = "STEP 3: Up/Down to choose strategy | 1/2/3 quick pick | n next | p prev".into();
    let _ = app;
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: Summary + confirm
// ─────────────────────────────────────────────────────────────────────────────

fn handle_step4(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    let order = [
        SummaryAction::Confirm,
        SummaryAction::Back,
        SummaryAction::Cancel,
    ];
    let idx = order
        .iter()
        .position(|a| *a == app.summary_action)
        .unwrap_or(0);
    match key.code {
        KeyCode::Char('q') => return Ok(true),
        KeyCode::Up => {
            if idx > 0 {
                app.summary_action = order[idx - 1];
            }
        }
        KeyCode::Down => {
            if idx + 1 < order.len() {
                app.summary_action = order[idx + 1];
            }
        }
        KeyCode::Char('p') | KeyCode::Left => {
            app.wizard_step = WizardStep::StrategyChoice;
            update_step3_message(app);
        }
        KeyCode::Enter => match app.summary_action {
            SummaryAction::Confirm => {
                queue_pending_for_strategy(app);
                return Ok(true);
            }
            SummaryAction::Back => {
                app.wizard_step = WizardStep::StrategyChoice;
                update_step3_message(app);
            }
            SummaryAction::Cancel => return Ok(true),
        },
        _ => {}
    }
    Ok(false)
}

fn update_step4_message(app: &mut AppState) {
    app.message = "STEP 4: Up/Down to pick action | Enter to do it | p back | q quit".into();
    let _ = app;
}

fn queue_pending_for_strategy(app: &mut AppState) {
    app.pending_action = Some(match app.strategy {
        Strategy::Unified => PendingAction::GenerateUnified,
        Strategy::PerClient => PendingAction::GeneratePerClient,
        Strategy::AutoRewire => PendingAction::AutoRewire,
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5: Result + tray prompt
// ─────────────────────────────────────────────────────────────────────────────

fn handle_step5(app: &mut AppState, key: KeyEvent) -> Result<bool> {
    let order = [TrayChoice::StartNow, TrayChoice::No];
    let idx = order
        .iter()
        .position(|t| *t == app.tray_choice)
        .unwrap_or(0);
    match key.code {
        KeyCode::Char('q') => return Ok(true),
        KeyCode::Up => {
            if idx > 0 {
                app.tray_choice = order[idx - 1];
            }
        }
        KeyCode::Down => {
            if idx + 1 < order.len() {
                app.tray_choice = order[idx + 1];
            }
        }
        KeyCode::Enter => match app.tray_choice {
            TrayChoice::StartNow => {
                app.pending_action = Some(PendingAction::StartTrayDaemon);
                return Ok(true);
            }
            TrayChoice::No => return Ok(true),
        },
        _ => {}
    }
    Ok(false)
}
