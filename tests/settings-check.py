#!/usr/bin/env python3
"""Structural check of a Claude Code settings file: strict JSON, known top-level keys, permission
rule shapes, hook wiring shape, sandbox keys. Dependency-free stand-in for the published JSON schema."""
import json, re, sys
path = sys.argv[1]
try:
    d = json.load(open(path))
except Exception as e:
    sys.exit(f"invalid JSON: {e}")
errors = []
RULE = re.compile(r"^[A-Za-z_]+(\(.*\))?$")
for key in ("allow", "ask", "deny"):
    rules = d.get("permissions", {}).get(key, [])
    if not isinstance(rules, list): errors.append(f"permissions.{key} is not a list")
    for r in rules:
        if not isinstance(r, str) or not RULE.match(r): errors.append(f"permissions.{key}: bad rule {r!r}")
deny = d.get("permissions", {}).get("deny", [])
if not any(r.startswith("Read(") and ".env" in r for r in deny): errors.append("no Read deny rule for .env files")
if "Bash" in d.get("permissions", {}).get("allow", []): errors.append("bare Bash allow present")
events = {"SessionStart","Setup","UserPromptSubmit","PreToolUse","PermissionRequest","PostToolUse","PostToolUseFailure",
          "Stop","StopFailure","SubagentStart","SubagentStop","PreCompact","PostCompact","SessionEnd","Notification",
          "InstructionsLoaded","ConfigChange","FileChanged","CwdChanged","TaskCreated","TaskCompleted","PostToolBatch"}
for ev, groups in d.get("hooks", {}).items():
    if ev not in events: errors.append(f"unknown hook event {ev}")
    for g in groups:
        for h in g.get("hooks", []):
            if h.get("type") != "command" or not h.get("command"): errors.append(f"hook under {ev} lacks a command")
sb = d.get("sandbox", {})
if sb and not sb.get("enabled"): errors.append("sandbox block present but disabled")
known = {"enabled","autoAllowBashIfSandboxed","allowUnsandboxedCommands","failIfUnavailable","excludedCommands",
         "filesystem","network","credentials","enableWeakerNestedSandbox","allowAppleEvents","ignoreViolations",
         "bwrapPath","socatPath","ripgrep","enableWeakerNetworkIsolation"}
for k in sb:
    if k not in known: errors.append(f"unknown sandbox key {k}")
if errors:
    print("\n".join("  " + e for e in errors)); sys.exit(1)
