#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
source "$SCRIPT_DIR/lib/project_hook_duplicate_scan.sh"

WORKSPACE_ROOT="$HOME/Doc/ai-company"
COMPANY_ROOT=""

usage() {
  printf 'Usage: %s [--workspace-root PATH] [--company-root PATH]\n' "$(basename -- "$0")"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace-root)
      [[ $# -ge 2 ]] || {
        printf 'FAIL: --workspace-root requires a path\n' >&2
        exit 2
      }
      WORKSPACE_ROOT=$2
      shift 2
      ;;
    --workspace-root=*)
      WORKSPACE_ROOT=${1#*=}
      shift
      ;;
    --company-root)
      [[ $# -ge 2 ]] || {
        printf 'FAIL: --company-root requires a path\n' >&2
        exit 2
      }
      COMPANY_ROOT=$2
      shift 2
      ;;
    --company-root=*)
      COMPANY_ROOT=${1#*=}
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'FAIL: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -d "$WORKSPACE_ROOT" ]] || {
  printf 'FAIL: workspace root does not exist: %s\n' "$WORKSPACE_ROOT" >&2
  exit 2
}

WORKSPACE_ROOT="$(CDPATH= cd -- "$WORKSPACE_ROOT" && pwd)"
[[ -n "$COMPANY_ROOT" ]] || COMPANY_ROOT=$WORKSPACE_ROOT
[[ -d "$COMPANY_ROOT" ]] || {
  printf 'FAIL: company root does not exist: %s\n' "$COMPANY_ROOT" >&2
  exit 2
}
COMPANY_ROOT="$(CDPATH= cd -- "$COMPANY_ROOT" && pwd)"

ROOT_TEMPLATE=$'# Claude Code 相容入口\n\n@AGENTS.md\n'
GENERIC_TEMPLATE=$'# Claude Code 相容入口\n\n- `AGENTS.md` 是本目錄的規則真相\n- 動工前完整讀取 `AGENTS.md`\n- 父層 `AGENTS.md` 仍持續適用\n- 本檔不得重複產品規則\n'
SUSUGIGI_TEMPLATE=$'# Claude 相容入口\n\n- 此檔只供跨工具相容。\n- 同目錄 `AGENTS.md` 是規則真相。\n- 執行任務前完整讀取該檔。\n- 不在此檔複製規則。\n'

EXPECTED_DIRS=(
  "."
  "product/hatsuon"
  "product/hatsuon/no3_product_specs/no1_pronunciation_app"
  "product/hatsuon/no5_product_development/no1_pronunciation_app"
  "product/i-got-this"
  "product/i-got-this/no3_product_specs/no1_issue_system"
  "product/i-got-this/no4_product_designs/no1_issue_system"
  "product/i-got-this/no5_product_development/no1_issue_system"
  "product/i-got-this/no5_product_development/no2_official_website"
  "product/liquid-glass-header-template"
  "product/liquid-glass-header-template/no3_product_specs/no1_liquid_glass_header"
  "product/liquid-glass-header-template/no5_product_development/no1_liquid_glass_header"
  "product/social-radar"
  "product/social-radar/no3_product_specs/no1_content_monitor"
  "product/social-radar/no5_product_development/no1_content_monitor"
  "product/susugigi"
  "product/susugigi/no2_product_planning/no2_product_map"
  "product/susugigi/no3_product_specs/no1_user_management"
  "product/susugigi/no3_product_specs/no2_accounting_app"
  "product/susugigi/no3_product_specs/no3_cloud_functions"
  "product/susugigi/no4_product_designs/no2_accounting_app"
  "product/susugigi/no4_product_designs/no2_accounting_app/project/10_foundations"
  "product/susugigi/no4_product_designs/no2_accounting_app/project/10_foundations/component_tokens"
  "product/susugigi/no4_product_designs/no2_accounting_app/project/10_foundations/visualizers"
  "product/susugigi/no4_product_designs/no2_accounting_app/project/15_fixtures"
  "product/susugigi/no4_product_designs/no2_accounting_app/project/30_screens"
  "product/susugigi/no5_product_development/no2_accounting_app"
  "product/susugigi/no5_product_development/no3_cloud_functions"
  "product/susugigi/no5_product_development/no4_support_site"
  "product/susugigi/no6_product_quality/no2_accounting_app"
  "product/susugigi/no7_product_release/no2_accounting_app"
  "product/underground-remake"
  "product/underground-remake/no3_product_specs/no1_concept"
)

EXPECTED_COUNT=${#EXPECTED_DIRS[@]}

ERROR_COUNT=0

record_failure() {
  printf 'FAIL: %s\n' "$*" >&2
  ERROR_COUNT=$((ERROR_COUNT + 1))
}

is_expected_dir() {
  local candidate=$1
  local expected
  for expected in "${EXPECTED_DIRS[@]}"; do
    [[ "$candidate" == "$expected" ]] && return 0
  done
  return 1
}

file_matches_template() {
  local file=$1
  local relative_dir=$2
  local expected
  local actual_with_sentinel
  local expected_with_sentinel

  if [[ "$relative_dir" == "." ]]; then
    expected=$ROOT_TEMPLATE
  elif [[ "$relative_dir" == product/susugigi* ]]; then
    expected=$SUSUGIGI_TEMPLATE
  else
    expected=$GENERIC_TEMPLATE
  fi

  actual_with_sentinel="$(command cat -- "$file"; printf '\037')"
  expected_with_sentinel="$(printf '%s' "$expected"; printf '\037')"
  [[ "$actual_with_sentinel" == "$expected_with_sentinel" ]]
}

discover_instruction_files() {
  find "$WORKSPACE_ROOT" \
    \( -type d \( \
      -name .git -o \
      -name node_modules -o \
      -name Pods -o \
      -name vendor -o \
      -name .build -o \
      -name build -o \
      -name dist -o \
      -name coverage -o \
      -name .next -o \
      -name .expo -o \
      -name .gradle -o \
      -name .yarn -o \
      -name .pnpm-store -o \
      -name .venv -o \
      -name venv -o \
      -name target -o \
      -name DerivedData -o \
      -name ai-company-worktrees -o \
      -name worktrees -o \
      -name .worktrees -o \
      -name _worktrees \
    \) -prune \) -o \
    \( -type f \( -name AGENTS.md -o -name CLAUDE.md \) -print \)
}

discover_repository_roots() {
  find "$WORKSPACE_ROOT" \
    \( -type d \( \
      -name node_modules -o \
      -name Pods -o \
      -name vendor -o \
      -name .build -o \
      -name build -o \
      -name dist -o \
      -name coverage -o \
      -name .next -o \
      -name .expo -o \
      -name .gradle -o \
      -name .yarn -o \
      -name .pnpm-store -o \
      -name .venv -o \
      -name venv -o \
      -name target -o \
      -name DerivedData -o \
      -name ai-company-worktrees -o \
      -name worktrees -o \
      -name .worktrees -o \
      -name _worktrees \
    \) -prune \) -o \
    \( -name .git \( -type d -o -type f -o -type l \) -print -prune \)
}

FOUND_DIRS=()
while IFS= read -r relative_dir; do
  FOUND_DIRS+=("$relative_dir")
done < <(
  discover_instruction_files |
    while IFS= read -r file; do
      relative_path=${file#"$WORKSPACE_ROOT"/}
      relative_dir=${relative_path%/*}
      [[ "$relative_dir" == "$relative_path" ]] && relative_dir=.
      printf '%s\n' "$relative_dir"
    done |
    LC_ALL=C sort -u
)

for found_dir in "${FOUND_DIRS[@]}"; do
  if ! is_expected_dir "$found_dir"; then
    record_failure "unexpected instruction directory: $found_dir"
  fi
done

for expected_dir in "${EXPECTED_DIRS[@]}"; do
  if [[ "$expected_dir" == "." ]]; then
    absolute_dir=$COMPANY_ROOT
  else
    absolute_dir=$WORKSPACE_ROOT/$expected_dir
  fi

  agents_file=$absolute_dir/AGENTS.md
  claude_file=$absolute_dir/CLAUDE.md

  if [[ ! -f "$agents_file" ]]; then
    record_failure "missing AGENTS.md: $expected_dir"
  elif [[ ! -s "$agents_file" ]]; then
    record_failure "empty AGENTS.md: $expected_dir"
  fi

  if [[ ! -f "$claude_file" ]]; then
    record_failure "missing CLAUDE.md: $expected_dir"
    continue
  fi

  if ! file_matches_template "$claude_file" "$expected_dir"; then
    record_failure "CLAUDE.md template drift: $expected_dir"
  fi
done

if [[ ${#FOUND_DIRS[@]} -ne $EXPECTED_COUNT ]]; then
  record_failure "found ${#FOUND_DIRS[@]} instruction directories, expected $EXPECTED_COUNT"
fi

SCAN_ROOTS=()
SCAN_LABELS=()
SCAN_KEYS=("__scan_sentinel__")

add_hook_scan_root() {
  local root=$1
  local label=$2
  local key
  local existing
  [[ -d "$root" ]] || return 0
  key="$(CDPATH= cd -- "$root" && pwd -P)"
  for existing in "${SCAN_KEYS[@]}"; do
    [[ "$existing" == "$key" ]] && return 0
  done
  SCAN_KEYS+=("$key")
  SCAN_ROOTS+=("$root")
  SCAN_LABELS+=("$label")
}

add_hook_scan_root "$COMPANY_ROOT" company-root
for expected_dir in "${EXPECTED_DIRS[@]}"; do
  [[ "$expected_dir" == "." ]] && continue
  add_hook_scan_root "$WORKSPACE_ROOT/$expected_dir" "$expected_dir"
done
while IFS= read -r git_marker; do
  repo_root=${git_marker%/.git}
  [[ "$repo_root" == "$WORKSPACE_ROOT" ]] && continue
  relative_root=${repo_root#"$WORKSPACE_ROOT"/}
  [[ "$relative_root" == "$repo_root" ]] && relative_root=$repo_root
  add_hook_scan_root "$repo_root" "git:$relative_root"
done < <(discover_repository_roots)

for index in "${!SCAN_ROOTS[@]}"; do
  while IFS= read -r finding; do
    [[ -n "$finding" ]] && record_failure "$finding"
  done < <(project_hook_duplicate_findings "${SCAN_ROOTS[$index]}" "${SCAN_LABELS[$index]}")
done

if [[ ! -f "$SCRIPT_DIR/tests/project_hook_duplicate_scan_test.sh" ]]; then
  record_failure "project-local Hook duplicate scanner regression test is missing"
elif ! bash "$SCRIPT_DIR/tests/project_hook_duplicate_scan_test.sh" >/dev/null; then
  record_failure "project-local Hook duplicate scanner regression test failed"
fi

if [[ $ERROR_COUNT -ne 0 ]]; then
  printf 'Instruction drift check failed with %s error(s).\n' "$ERROR_COUNT" >&2
  exit 1
fi

printf 'PASS: %s instruction pairs match the canonical templates.\n' "$EXPECTED_COUNT"
printf 'PASS: project-local Hook duplicates are absent from %s declared instruction and discovered Git roots.\n' "${#SCAN_ROOTS[@]}"
printf 'PASS: project-local Hook duplicate scanner regression cases passed.\n'
