#!/usr/bin/env bash
set -euo pipefail

MODE="--dry-run"
BACKUP=0
TEMPLATE_DIR="./templates"
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run|--diff|--apply-safe|--apply)
      MODE="$1"
      ;;
    --backup)
      BACKUP=1
      ;;
    --template-dir)
      TEMPLATE_DIR="$2"
      shift
      ;;
    --root-dir)
      ROOT_DIR="$2"
      shift
      ;;
    *)
      echo "[error] unknown argument: $1" >&2
      exit 2
      ;;
  esac
  shift
done

if [ "$MODE" = "--apply" ] && [ "$BACKUP" -ne 1 ]; then
  echo "[error] --apply requires --backup" >&2
  exit 2
fi

BACKUP_DIR="$ROOT_DIR/.ai/template-backup/$(date -u +"%Y%m%dT%H%M%SZ")"

mapping_file="$(mktemp)"
trap 'rm -f "$mapping_file"' EXIT
cat > "$mapping_file" <<MAP
CLAUDE.md|CLAUDE.md
AGENTS.md|AGENTS.md
testing.instructions.md|testing.instructions.md
stack.env|.ai/stack.env
STATE.md|docs/ai-workflow/STATE.md
CONTEXT.md|docs/ai-workflow/CONTEXT.md
PRD.md|docs/ai-workflow/PRD.md
SLICE.md|docs/ai-workflow/SLICE.md
claude/workflow.md|.claude/commands/workflow.md
claude/init-workflow.md|.claude/commands/init-workflow.md
claude/create-slice.md|.claude/commands/create-slice.md
claude/pre-commit-check.sh|.claude/hooks/pre-commit-check.sh
codex/WORKFLOW.md|.ai/codex/WORKFLOW.md
codex/PROMPTS.md|.ai/codex/PROMPTS.md
cursor-rules/shared.mdc|.cursor/rules/shared.mdc
cursor-rules/frontend.mdc|.cursor/rules/frontend.mdc
cursor-rules/backend-api.mdc|.cursor/rules/backend-api.mdc
cursor-rules/database.mdc|.cursor/rules/database.mdc
cursor-rules/deployment.mdc|.cursor/rules/deployment.mdc
MAP

while IFS='|' read -r src_rel dst_rel; do
  src="$TEMPLATE_DIR/$src_rel"
  dst="$ROOT_DIR/$dst_rel"

  if [ ! -f "$src" ]; then
    echo -e "MISSING_SOURCE\t$src"
    continue
  fi

  if [ ! -e "$dst" ]; then
    echo -e "TARGET_MISSING\t$dst"
    if [ "$MODE" = "--apply-safe" ] || [ "$MODE" = "--apply" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo -e "CREATE\t$dst"
    fi
    continue
  fi

  if cmp -s "$src" "$dst"; then
    echo -e "TARGET_CURRENT\t$dst"
    continue
  fi

  echo -e "TEMPLATE_UPDATED\t$dst"
  if [ "$MODE" = "--diff" ]; then
    git diff --no-index -- "$dst" "$src" || [ "$?" -eq 1 ]
  fi

  if [ "$MODE" = "--apply" ]; then
    backup_path="$BACKUP_DIR/$dst_rel"
    mkdir -p "$(dirname "$backup_path")"
    cp "$dst" "$backup_path"
    cp "$src" "$dst"
    echo -e "OVERWRITE\t$dst\tBACKUP\t$backup_path"
  fi
done < "$mapping_file"

if [ "$MODE" = "--apply-safe" ] || [ "$MODE" = "--apply" ]; then
  mkdir -p "$ROOT_DIR/.ai"
  {
    echo "fullstack-ai-workflow=$(cat "$ROOT_DIR/VERSION" 2>/dev/null || echo unknown)"
    echo "applied_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$ROOT_DIR/.ai/template-version"
fi
