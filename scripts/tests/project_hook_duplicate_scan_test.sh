#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/project_hook_duplicate_scan.sh"

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/project_hook_scan.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

PASS_COUNT=0

expect_clean() {
  local root=$1
  local output
  output="$(project_hook_duplicate_findings "$root" fixture)"
  if [[ -n "$output" ]]; then
    printf 'FAIL: expected no findings, got: %s\n' "$output" >&2
    exit 1
  fi
  PASS_COUNT=$((PASS_COUNT + 1))
}

expect_finding() {
  local root=$1
  local expected=$2
  local output
  output="$(project_hook_duplicate_findings "$root" fixture)"
  if [[ "$output" != *"$expected"* ]]; then
    printf 'FAIL: expected finding containing %s, got: %s\n' "$expected" "$output" >&2
    exit 1
  fi
  PASS_COUNT=$((PASS_COUNT + 1))
}

CLEAN=$TEMP_ROOT/clean
mkdir -p "$CLEAN/.claude" "$CLEAN/.codex/hooks"
printf '{"permissions": {"allow": []}}\n' > "$CLEAN/.claude/settings.json"
printf '{"model": "default"}\n' > "$CLEAN/.claude/settings.local.json"
expect_clean "$CLEAN"

LOCAL_SETTINGS=$TEMP_ROOT/settings-local
mkdir -p "$LOCAL_SETTINGS/.claude"
printf '{\n  "hooks"\n  :\n  {"PreToolUse": []}\n}\n' > "$LOCAL_SETTINGS/.claude/settings.local.json"
expect_finding "$LOCAL_SETTINGS" '.claude/settings.local.json still declares Hooks'

STRING_ONLY=$TEMP_ROOT/string-only
mkdir -p "$STRING_ONLY/.claude"
printf '{"note": "literal text: \\"hooks\\": {}"}\n' > "$STRING_ONLY/.claude/settings.local.json"
expect_clean "$STRING_ONLY"

INVALID_SETTINGS=$TEMP_ROOT/invalid-settings
mkdir -p "$INVALID_SETTINGS/.claude"
printf '{"hooks":\n' > "$INVALID_SETTINGS/.claude/settings.json"
expect_finding "$INVALID_SETTINGS" 'invalid project-local settings JSON'

BROKEN_SETTINGS=$TEMP_ROOT/broken-settings
mkdir -p "$BROKEN_SETTINGS/.claude"
ln -s "$BROKEN_SETTINGS/missing.json" "$BROKEN_SETTINGS/.claude/settings.json"
expect_finding "$BROKEN_SETTINGS" 'broken project-local settings symlink'

CODEX_LINK=$TEMP_ROOT/codex-link
mkdir -p "$CODEX_LINK/.codex" "$TEMP_ROOT/shared-hooks"
ln -s "$TEMP_ROOT/shared-hooks" "$CODEX_LINK/.codex/hooks"
expect_finding "$CODEX_LINK" '.codex/hooks must not be a file or symlink'

CLAUDE_ENTRY=$TEMP_ROOT/claude-entry
mkdir -p "$CLAUDE_ENTRY/.claude/hooks"
ln -s "$TEMP_ROOT/missing-hook.sh" "$CLAUDE_ENTRY/.claude/hooks/pre-tool-use.sh"
expect_finding "$CLAUDE_ENTRY" '.claude/hooks contains Hook files or symlinks'

CODEX_CONFIG=$TEMP_ROOT/codex-config
mkdir -p "$CODEX_CONFIG/.codex"
ln -s "$TEMP_ROOT/missing-hooks.json" "$CODEX_CONFIG/.codex/hooks.json"
expect_finding "$CODEX_CONFIG" '.codex/hooks.json must be removed'

printf 'PASS: %s project-local Hook duplicate scan cases.\n' "$PASS_COUNT"
