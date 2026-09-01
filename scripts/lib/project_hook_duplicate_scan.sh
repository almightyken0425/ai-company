#!/usr/bin/env bash

# Print one finding per project-local Hook declaration or executable container.
# Callers own presentation and exit status.
project_hook_duplicate_findings() {
  local root=$1
  local label=$2
  local path

  [[ -d "$root" ]] || return 0

  path=$root/.codex/hooks.json
  if [[ -e "$path" || -L "$path" ]]; then
    printf '%s: project-local .codex/hooks.json must be removed\n' "$label"
  fi

  path=$root/.codex/hooks
  if [[ -L "$path" || -e "$path" && ! -d "$path" ]]; then
    printf '%s: project-local .codex/hooks must not be a file or symlink\n' "$label"
  elif [[ -d "$path" ]] && find "$path" -mindepth 1 \( -type f -o -type l \) -print -quit | grep -q .; then
    printf '%s: project-local .codex/hooks contains Hook files or symlinks\n' "$label"
  fi

  for path in "$root/.claude/settings.json" "$root/.claude/settings.local.json"; do
    if [[ -L "$path" && ! -e "$path" ]]; then
      printf '%s: broken project-local settings symlink: %s\n' "$label" "${path#"$root"/}"
    elif [[ -f "$path" ]]; then
      local settings_state
      if ! settings_state="$(python3 - "$path" <<'PY'
import json
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as stream:
        value = json.load(stream)
except (OSError, UnicodeError, json.JSONDecodeError):
    print("invalid")
else:
    if not isinstance(value, dict):
        print("invalid")
    elif "hooks" in value:
        print("hooks")
    else:
        print("clean")
PY
)"; then
        printf '%s: cannot parse project-local settings: %s\n' "$label" "${path#"$root"/}"
      elif [[ "$settings_state" == "hooks" ]]; then
        printf '%s: project-local %s still declares Hooks\n' "$label" "${path#"$root"/}"
      elif [[ "$settings_state" != "clean" ]]; then
        printf '%s: invalid project-local settings JSON: %s\n' "$label" "${path#"$root"/}"
      fi
    fi
  done

  path=$root/.claude/hooks
  if [[ -L "$path" || -e "$path" && ! -d "$path" ]]; then
    printf '%s: project-local .claude/hooks must not be a file or symlink\n' "$label"
  elif [[ -d "$path" ]] && find "$path" -mindepth 1 \( -type f -o -type l \) -print -quit | grep -q .; then
    printf '%s: project-local .claude/hooks contains Hook files or symlinks\n' "$label"
  fi
}
