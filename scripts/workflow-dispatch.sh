#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-help}"
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT_DIR"

ensure_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "[error] missing file: $path"
    exit 1
  fi
}

show_help() {
  cat <<'HELP'
Usage:
  scripts/workflow-dispatch.sh install
  scripts/workflow-dispatch.sh init
  scripts/workflow-dispatch.sh status
  scripts/workflow-dispatch.sh next
  scripts/workflow-dispatch.sh review
  scripts/workflow-dispatch.sh ship
HELP
}

case "$ACTION" in
  install)
    ensure_file workflow-repos.manifest.json
    bash scripts/bootstrap-workflow.sh workflow-repos.manifest.json
    ;;
  init)
    ensure_file scripts/apply-workflow-templates.sh
    bash scripts/apply-workflow-templates.sh
    ;;
  status)
    if [ -f docs/ai-workflow/SLICE.md ]; then
      echo "Current stage: Execute or Verify"
    elif [ -f docs/ai-workflow/PRD.md ]; then
      echo "Current stage: Plan or Slice"
    else
      echo "Current stage: Discuss"
    fi
    ;;
  next)
    if [ ! -f docs/ai-workflow/PRD.md ]; then
      echo "Next: create PRD"
    elif [ ! -d docs/ai-workflow/slices ] || [ -z "$(find docs/ai-workflow/slices -type f 2>/dev/null)" ]; then
      echo "Next: create 1~3 vertical slices"
    else
      echo "Next: choose one active slice and run Red -> Green -> Refactor"
    fi
    ;;
  review)
    echo "Review focus: correctness, safety, tests, maintainability, rollback"
    ;;
  ship)
    echo "Ship focus: evidence, migration, observability, rollback, ownership"
    ;;
  help|*)
    show_help
    ;;
esac
