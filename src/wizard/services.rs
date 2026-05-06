//! Service loading, detection, and health check logic.
//!
//! v0.4.0 source-of-truth model:
//!
//! 1. **Discovery comes from client configs.** [`load_all_services`] runs
//!    [`crate::scan::scan_hosts`] across every well-known MCP client config
//!    (Claude / ClaudeDesktop / Codex / Junie / Gemini / Cursor / VSCode /
//!    JetBrains) and adds every server it finds, tagged with the originating
//!    [`ServiceSource::Client`].
//! 2. **The mux daemon config is loaded next** as `ServiceSource::MuxConfig`.
//!    Entries that are name-equivalent to ones already discovered from a
//!    client config are skipped — the client-config copy wins because it is
//!    what the user is actually running.
//! 3. **ps-scan enrichment is optional and last** ([`enrich_running_state`]).
//!    It only sets the `pid` field on entries whose `(cmd, args)` match a
//!    running process; orphans (running but not in any config) are surfaced
//!    as `ServiceSource::DetectedRunning` so the operator can see them.
//!
//! The legacy ps-scan-as-source-of-truth path is gone. The hardcoded
//! `MCP_PATTERNS` whitelist below is used **only** by the enrichment helper
//! to bound the process scan; misses there mean a missed PID badge, never a
//! missing server entry.

use std::collections::HashMap;
use std::io::{BufRead, BufReader};
use std::os::unix::net::UnixStream;
use std::path::Path;
use std::process::Command;

use anyhow::Result;

use crate::config::{ServerConfig, expand_path, load_config};
use crate::scan::{
    HostKind, HostService, MergeOutcome, ScanResult, merge_services, scan_host_file, scan_hosts,
};

use super::types::{FormState, HealthStatus, ServiceEntry, ServiceSource};

// ─────────────────────────────────────────────────────────────────────────────
// Service loading
// ─────────────────────────────────────────────────────────────────────────────

/// Default per-service socket directory used when synthesising a `ServerConfig`
/// for a service we discovered in a client config (clients usually only
/// specify command/args, not a socket — the mux assigns one).
fn default_socket_path(name: &str) -> String {
    format!("~/.rmcp-servers/rust-mux/sockets/{}.sock", name)
}

/// Load every service the wizard should consider, in priority order:
///
/// 1. Client-config services (Claude/Codex/Junie/Gemini/...).
/// 2. Mux daemon config services (the file at `mux_config_path`).
/// 3. Running-process orphans surfaced via ps-scan.
///
/// Selection defaults to `true` for every entry; the operator can untick
/// in the wizard.
pub fn load_all_services(mux_config_path: &Path) -> Result<Vec<ServiceEntry>> {
    let scans = scan_hosts();
    let merged = merge_services(&scans);
    let mut services = services_from_merge(&scans, &merged);

    // Mux daemon config (legacy path). Skip entries already present from a
    // client-config scan to avoid double-listing the same logical server.
    if let Some(cfg) = load_config(mux_config_path)? {
        for (name, server_cfg) in cfg.servers {
            let already = services
                .iter()
                .any(|s| s.name == name || configs_equivalent(&s.config, &server_cfg));
            if already {
                continue;
            }
            services.push(ServiceEntry {
                name,
                config: server_cfg,
                health: HealthStatus::Unknown,
                dirty: false,
                source: ServiceSource::MuxConfig,
                pid: None,
                selected: true,
            });
        }
    }

    // ps-scan enrichment: stamp PIDs on matching entries; surface orphans as
    // `DetectedRunning`.
    enrich_running_state(&mut services);

    services.sort_by(client_first_then_name);

    Ok(services)
}

fn services_from_merge(scans: &[ScanResult], merged: &MergeOutcome) -> Vec<ServiceEntry> {
    // Index from (cmd, args, env) -> (HostKind, path) so we can attribute
    // the merged service to its originating client. We keep the first source
    // encountered (sources are ordered by `default_sources` priority).
    let mut origin_index: HashMap<String, (HostKind, std::path::PathBuf)> = HashMap::new();
    for scan in scans {
        for svc in &scan.services {
            let key = svc_key(svc);
            origin_index
                .entry(key)
                .or_insert_with(|| (scan.host.kind, scan.host.path.clone()));
        }
    }

    let mut out = Vec::with_capacity(merged.services.len());
    for svc in &merged.services {
        let origin = origin_index
            .get(&svc_key(svc))
            .cloned()
            .map(|(kind, path)| ServiceSource::Client { kind, path })
            .unwrap_or(ServiceSource::DetectedRunning);

        let socket = svc
            .socket
            .clone()
            .unwrap_or_else(|| default_socket_path(&svc.name));

        let config = ServerConfig {
            socket: Some(socket),
            cmd: Some(svc.command.clone()),
            args: Some(svc.args.clone()),
            env: svc.env.clone(),
            max_active_clients: Some(5),
            tray: Some(false),
            service_name: Some(svc.name.clone()),
            log_level: Some("info".into()),
            lazy_start: Some(false),
            max_request_bytes: Some(1_048_576),
            request_timeout_ms: Some(30_000),
            restart_backoff_ms: Some(1_000),
            restart_backoff_max_ms: Some(30_000),
            max_restarts: Some(5),
            status_file: None,
            heartbeat_interval_ms: Some(30_000),
            heartbeat_timeout_ms: Some(30_000),
            heartbeat_max_failures: Some(3),
            heartbeat_enabled: Some(true),
        };

        out.push(ServiceEntry {
            name: svc.name.clone(),
            config,
            health: HealthStatus::Unknown,
            dirty: false,
            source: origin,
            pid: None,
            selected: true,
        });
    }
    out
}

fn svc_key(svc: &HostService) -> String {
    format!(
        "{}|{}|{}",
        svc.command,
        svc.args.join(" "),
        env_signature(svc.env.as_ref())
    )
}

fn env_signature(env: Option<&HashMap<String, String>>) -> String {
    let Some(env) = env else {
        return String::new();
    };
    let mut entries: Vec<(&String, &String)> = env.iter().collect();
    entries.sort_by(|a, b| a.0.cmp(b.0));
    entries
        .into_iter()
        .map(|(k, v)| format!("{k}={v}"))
        .collect::<Vec<_>>()
        .join(",")
}

fn configs_equivalent(a: &ServerConfig, b: &ServerConfig) -> bool {
    a.cmd == b.cmd && a.args == b.args && a.env == b.env
}

fn client_first_then_name(a: &ServiceEntry, b: &ServiceEntry) -> std::cmp::Ordering {
    use std::cmp::Ordering;
    let rank = |s: &ServiceSource| match s {
        ServiceSource::Client { .. } => 0,
        ServiceSource::MuxConfig => 1,
        ServiceSource::Custom { .. } => 2,
        ServiceSource::DetectedRunning => 3,
    };
    match rank(&a.source).cmp(&rank(&b.source)) {
        Ordering::Equal => a.name.cmp(&b.name),
        other => other,
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ps-scan enrichment (running-process awareness, *not* discovery)
// ─────────────────────────────────────────────────────────────────────────────

/// Patterns used to bound the ps-scan to plausible MCP processes. Misses
/// here only mean a missed PID badge — discovery itself is driven by
/// [`scan_hosts`] regardless of what is currently running.
const MCP_PATTERNS: &[&str] = &[
    "@modelcontextprotocol/",
    "mcp-server-",
    "-mcp-server",
    "mcp_server",
    "/mcp-",
    "-mcp/",
    "/loctree-mcp",
    "/aicx-mcp",
    "claude-mcp",
];

/// Stamp `pid` on every entry whose `(cmd, args)` matches a running process,
/// and append entries for processes that match an MCP heuristic but do not
/// match anything already in the list (`ServiceSource::DetectedRunning`).
pub fn enrich_running_state(services: &mut Vec<ServiceEntry>) {
    let running = list_running_mcp_processes();
    if running.is_empty() {
        return;
    }

    for proc in &running {
        // Try to match an existing entry by command+first-arg.
        let mut matched = false;
        for svc in services.iter_mut() {
            if proc_matches_entry(proc, svc) {
                svc.pid = Some(proc.pid);
                matched = true;
                break;
            }
        }
        if !matched {
            // Orphan: visible as a running MCP-shaped process but not in any
            // discovered config. Surface it so the operator can decide.
            services.push(ServiceEntry {
                name: proc.synthetic_name.clone(),
                config: ServerConfig {
                    socket: Some(default_socket_path(&proc.synthetic_name)),
                    cmd: Some(proc.cmd.clone()),
                    args: Some(proc.args.clone()),
                    env: None,
                    max_active_clients: Some(5),
                    tray: Some(false),
                    service_name: Some(proc.synthetic_name.clone()),
                    log_level: Some("info".into()),
                    lazy_start: Some(false),
                    max_request_bytes: Some(1_048_576),
                    request_timeout_ms: Some(30_000),
                    restart_backoff_ms: Some(1_000),
                    restart_backoff_max_ms: Some(30_000),
                    max_restarts: Some(5),
                    status_file: None,
                    heartbeat_interval_ms: Some(30_000),
                    heartbeat_timeout_ms: Some(30_000),
                    heartbeat_max_failures: Some(3),
                    heartbeat_enabled: Some(true),
                },
                health: HealthStatus::Healthy,
                dirty: false,
                source: ServiceSource::DetectedRunning,
                pid: Some(proc.pid),
                selected: false,
            });
        }
    }
}

#[derive(Debug, Clone)]
struct RunningMcpProcess {
    pid: u32,
    cmd: String,
    args: Vec<String>,
    synthetic_name: String,
}

fn list_running_mcp_processes() -> Vec<RunningMcpProcess> {
    let output = match Command::new("ps").args(["-eo", "pid,args"]).output() {
        Ok(o) if o.status.success() => o,
        _ => return Vec::new(),
    };

    let reader = BufReader::new(&output.stdout[..]);
    let mut seen_names: std::collections::HashSet<String> = std::collections::HashSet::new();
    let mut out = Vec::new();

    for line in reader.lines().map_while(Result::ok) {
        let line = line.trim();
        if line.starts_with("PID") {
            continue;
        }
        let parts: Vec<&str> = line.splitn(2, char::is_whitespace).collect();
        if parts.len() < 2 {
            continue;
        }
        let pid: u32 = match parts[0].trim().parse() {
            Ok(p) => p,
            Err(_) => continue,
        };
        let args = parts[1].trim();

        if !MCP_PATTERNS.iter().any(|p| args.contains(p)) {
            continue;
        }
        // Skip rust-mux itself, its proxy, and the legacy rmcp_mux binary names.
        if args.contains("rust-mux") || args.contains("rmcp_mux") {
            continue;
        }

        let name = extract_service_name(args);
        let unique = ensure_unique_name(&seen_names, name);
        seen_names.insert(unique.clone());

        let (cmd, cmd_args) = extract_cmd_and_args(args);
        out.push(RunningMcpProcess {
            pid,
            cmd,
            args: cmd_args,
            synthetic_name: unique,
        });
    }
    out
}

fn proc_matches_entry(proc: &RunningMcpProcess, svc: &ServiceEntry) -> bool {
    let svc_cmd = svc.config.cmd.as_deref().unwrap_or("");
    let svc_args = svc.config.args.as_deref().unwrap_or(&[]);
    if !cmds_equivalent(&proc.cmd, svc_cmd) {
        return false;
    }
    // Match if the running process args contain the first non-empty service arg
    // (heuristic — covers `npx -y @x/y` vs `npx @x/y`).
    if let Some(probe) = svc_args.iter().find(|a| !a.is_empty()) {
        return proc.args.iter().any(|a| a.contains(probe.as_str()));
    }
    true
}

fn cmds_equivalent(a: &str, b: &str) -> bool {
    if a == b {
        return true;
    }
    let a_tail = a.rsplit('/').next().unwrap_or(a);
    let b_tail = b.rsplit('/').next().unwrap_or(b);
    a_tail == b_tail
}

fn ensure_unique_name(used: &std::collections::HashSet<String>, candidate: String) -> String {
    if !used.contains(&candidate) {
        return candidate;
    }
    let mut counter = 2usize;
    loop {
        let next = format!("{candidate}-{counter}");
        if !used.contains(&next) {
            return next;
        }
        counter += 1;
    }
}

fn extract_service_name(args: &str) -> String {
    if let Some(idx) = args.find("@modelcontextprotocol/") {
        let rest = &args[idx + "@modelcontextprotocol/".len()..];
        let name: String = rest
            .chars()
            .take_while(|c| c.is_alphanumeric() || *c == '-' || *c == '_')
            .collect();
        if !name.is_empty() {
            return name;
        }
    }
    if let Some(idx) = args.find("mcp-server-") {
        let rest = &args[idx + "mcp-server-".len()..];
        let name: String = rest
            .chars()
            .take_while(|c| c.is_alphanumeric() || *c == '-' || *c == '_')
            .collect();
        if !name.is_empty() {
            return format!("mcp-{}", name);
        }
    }
    if let Some(idx) = args.find("server-") {
        let rest = &args[idx + "server-".len()..];
        let name: String = rest
            .chars()
            .take_while(|c| c.is_alphanumeric() || *c == '-' || *c == '_')
            .collect();
        if !name.is_empty() {
            return name;
        }
    }
    "detected-mcp".into()
}

fn extract_cmd_and_args(args: &str) -> (String, Vec<String>) {
    let parts: Vec<&str> = args.split_whitespace().collect();
    if parts.is_empty() {
        return ("unknown".into(), vec![]);
    }
    let cmd = if parts[0].contains('/') {
        parts[0].rsplit('/').next().unwrap_or(parts[0]).to_string()
    } else {
        parts[0].to_string()
    };
    let cmd_args: Vec<String> = parts[1..].iter().map(|s| s.to_string()).collect();
    (cmd, cmd_args)
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom-path import (used by --import-config and the wizard custom-path field)
// ─────────────────────────────────────────────────────────────────────────────

/// Parse a single user-provided config file and return the contained services
/// tagged with `ServiceSource::Custom`. Mirrors the well-known-client path
/// but does not affect [`load_all_services`] — callers append the result.
// Why: caller (the wizard custom-path input field on STEP 1) is added in
// the next commit (5-step flow rebuild). Tests in this module already
// exercise this fn so the helper itself is verified in isolation.
#[allow(dead_code)]
pub fn load_services_from_custom_path(path: &Path) -> Result<Vec<ServiceEntry>> {
    let host = crate::scan::host_file_from_custom_path(path);
    if !host.path.exists() {
        return Ok(Vec::new());
    }
    let scan = scan_host_file(&host)?;
    let mut out = Vec::with_capacity(scan.services.len());
    for svc in scan.services {
        let socket = svc
            .socket
            .clone()
            .unwrap_or_else(|| default_socket_path(&svc.name));
        out.push(ServiceEntry {
            name: svc.name.clone(),
            config: ServerConfig {
                socket: Some(socket),
                cmd: Some(svc.command.clone()),
                args: Some(svc.args.clone()),
                env: svc.env.clone(),
                max_active_clients: Some(5),
                tray: Some(false),
                service_name: Some(svc.name.clone()),
                log_level: Some("info".into()),
                lazy_start: Some(false),
                max_request_bytes: Some(1_048_576),
                request_timeout_ms: Some(30_000),
                restart_backoff_ms: Some(1_000),
                restart_backoff_max_ms: Some(30_000),
                max_restarts: Some(5),
                status_file: None,
                heartbeat_interval_ms: Some(30_000),
                heartbeat_timeout_ms: Some(30_000),
                heartbeat_max_failures: Some(3),
                heartbeat_enabled: Some(true),
            },
            health: HealthStatus::Unknown,
            dirty: false,
            source: ServiceSource::Custom {
                path: host.path.clone(),
            },
            pid: None,
            selected: true,
        });
    }
    Ok(out)
}

// ─────────────────────────────────────────────────────────────────────────────
// Health check
// ─────────────────────────────────────────────────────────────────────────────

pub fn check_health(config: &ServerConfig) -> HealthStatus {
    let socket_path = match &config.socket {
        Some(s) => expand_path(s),
        None => return HealthStatus::Unknown,
    };

    match UnixStream::connect(&socket_path) {
        Ok(_) => HealthStatus::Healthy,
        Err(_) => HealthStatus::Unhealthy,
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default config and form conversions
// ─────────────────────────────────────────────────────────────────────────────

pub fn default_server_config() -> ServerConfig {
    ServerConfig {
        socket: Some(default_socket_path("general-memory")),
        cmd: Some("npx".into()),
        args: Some(vec!["@modelcontextprotocol/server-memory".into()]),
        env: None,
        max_active_clients: Some(5),
        tray: Some(false),
        service_name: None,
        log_level: Some("info".into()),
        lazy_start: Some(false),
        max_request_bytes: Some(1_048_576),
        request_timeout_ms: Some(30_000),
        restart_backoff_ms: Some(1_000),
        restart_backoff_max_ms: Some(30_000),
        max_restarts: Some(5),
        status_file: None,
        heartbeat_interval_ms: Some(30_000),
        heartbeat_timeout_ms: Some(30_000),
        heartbeat_max_failures: Some(3),
        heartbeat_enabled: Some(true),
    }
}

pub fn form_from_service(svc: &ServiceEntry) -> FormState {
    let env_str = svc
        .config
        .env
        .as_ref()
        .map(|m| {
            m.iter()
                .map(|(k, v)| format!("{}={}", k, v))
                .collect::<Vec<_>>()
                .join(" ")
        })
        .unwrap_or_default();

    FormState {
        service_name: svc.name.clone(),
        socket: svc.config.socket.clone().unwrap_or_default(),
        cmd: svc.config.cmd.clone().unwrap_or_else(|| "npx".into()),
        args: svc.config.args.clone().unwrap_or_default().join(" "),
        env: env_str,
        max_clients: svc.config.max_active_clients.unwrap_or(5).to_string(),
        log_level: svc
            .config
            .log_level
            .clone()
            .unwrap_or_else(|| "info".into()),
        tray: svc.config.tray.unwrap_or(false),
        dirty: false,
    }
}

pub fn service_from_form(form: &FormState) -> ServerConfig {
    let args_vec: Vec<String> = form
        .args
        .split_whitespace()
        .map(|s| s.to_string())
        .collect();

    let env_map: HashMap<String, String> = form
        .env
        .split_whitespace()
        .filter_map(|pair| {
            let mut parts = pair.splitn(2, '=');
            match (parts.next(), parts.next()) {
                (Some(k), Some(v)) if !k.is_empty() => Some((k.to_string(), v.to_string())),
                _ => None,
            }
        })
        .collect();

    let env = if env_map.is_empty() {
        None
    } else {
        Some(env_map)
    };

    ServerConfig {
        socket: Some(form.socket.clone()),
        cmd: Some(form.cmd.clone()),
        args: Some(args_vec),
        env,
        max_active_clients: form.max_clients.trim().parse().ok(),
        tray: Some(form.tray),
        service_name: Some(form.service_name.clone()),
        log_level: Some(form.log_level.clone()),
        lazy_start: Some(false),
        max_request_bytes: Some(1_048_576),
        request_timeout_ms: Some(30_000),
        restart_backoff_ms: Some(1_000),
        restart_backoff_max_ms: Some(30_000),
        max_restarts: Some(5),
        status_file: None,
        heartbeat_interval_ms: Some(30_000),
        heartbeat_timeout_ms: Some(30_000),
        heartbeat_max_failures: Some(3),
        heartbeat_enabled: Some(true),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    #[test]
    fn custom_path_imports_services_with_custom_origin() {
        let dir = tempdir().expect("tempdir");
        let path = dir.path().join("workspace-mcp.json");
        fs::write(
            &path,
            r#"{"mcpServers": {"memory": {"command": "npx", "args": ["@modelcontextprotocol/server-memory"]}}}"#,
        )
        .expect("write");
        let entries = load_services_from_custom_path(&path).expect("custom load");
        assert_eq!(entries.len(), 1);
        match &entries[0].source {
            ServiceSource::Custom { path: p } => assert_eq!(p, &path),
            other => panic!("expected Custom origin, got {other:?}"),
        }
        assert_eq!(entries[0].name, "memory");
    }

    #[test]
    fn custom_path_for_missing_file_yields_empty() {
        let entries = load_services_from_custom_path(Path::new(
            "/tmp/this-file-does-not-exist-rust-mux-services-test.json",
        ))
        .expect("missing-ok");
        assert!(entries.is_empty());
    }

    #[test]
    fn services_from_merge_attribute_first_source_kind() {
        use crate::scan::{Confidence, ConfigSchema, HostFile, HostFormat};
        let host = HostFile {
            kind: HostKind::Claude,
            path: std::path::PathBuf::from("/tmp/test-claude.json"),
            format: HostFormat::Json,
            schema: ConfigSchema::McpServersJson,
            confidence: Confidence::High,
            writable: true,
            eligible_for_danger: true,
        };
        let scan = ScanResult {
            host: host.clone(),
            services: vec![HostService {
                name: "memory".into(),
                command: "npx".into(),
                args: vec!["@modelcontextprotocol/server-memory".into()],
                socket: None,
                env: None,
                enabled: None,
            }],
        };
        let merged = merge_services(std::slice::from_ref(&scan));
        let entries = services_from_merge(std::slice::from_ref(&scan), &merged);
        assert_eq!(entries.len(), 1);
        match &entries[0].source {
            ServiceSource::Client { kind, path } => {
                assert_eq!(*kind, HostKind::Claude);
                assert_eq!(path, &host.path);
            }
            other => panic!("expected Client origin, got {other:?}"),
        }
    }

    #[test]
    fn cmds_equivalent_matches_basename() {
        assert!(cmds_equivalent("/usr/local/bin/npx", "npx"));
        assert!(cmds_equivalent("npx", "npx"));
        assert!(!cmds_equivalent("npx", "node"));
    }
}
