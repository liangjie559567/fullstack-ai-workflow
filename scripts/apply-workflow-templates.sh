#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TEMPLATE_DIR="${1:-./templates}"

copy_if_missing() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    echo "[skip] exists: $dst"
  else
    cp "$src" "$dst"
    echo "[create] $dst"
  fi
}

copy_if_missing "$TEMPLATE_DIR/CLAUDE.md" "$ROOT_DIR/CLAUDE.md"
copy_if_missing "$TEMPLATE_DIR/AGENTS.md" "$ROOT_DIR/AGENTS.md"
copy_if_missing "$TEMPLATE_DIR/testing.instructions.md" "$ROOT_DIR/testing.instructions.md"
copy_if_missing "$TEMPLATE_DIR/stack.env" "$ROOT_DIR/.ai/stack.env"
copy_if_missing "$TEMPLATE_DIR/STATE.md" "$ROOT_DIR/docs/ai-workflow/STATE.md"
copy_if_missing "$TEMPLATE_DIR/CONTEXT.md" "$ROOT_DIR/docs/ai-workflow/CONTEXT.md"
copy_if_missing "$TEMPLATE_DIR/PRD.md" "$ROOT_DIR/docs/ai-workflow/PRD.md"
copy_if_missing "$TEMPLATE_DIR/SLICE.md" "$ROOT_DIR/docs/ai-workflow/SLICE.md"
copy_if_missing "$TEMPLATE_DIR/claude/workflow.md" "$ROOT_DIR/.claude/commands/workflow.md"
copy_if_missing "$TEMPLATE_DIR/claude/init-workflow.md" "$ROOT_DIR/.claude/commands/init-workflow.md"
copy_if_missing "$TEMPLATE_DIR/claude/create-slice.md" "$ROOT_DIR/.claude/commands/create-slice.md"
copy_if_missing "$TEMPLATE_DIR/claude/pre-commit-check.sh" "$ROOT_DIR/.claude/hooks/pre-commit-check.sh"
copy_if_missing "$TEMPLATE_DIR/codex/WORKFLOW.md" "$ROOT_DIR/.ai/codex/WORKFLOW.md"
copy_if_missing "$TEMPLATE_DIR/codex/PROMPTS.md" "$ROOT_DIR/.ai/codex/PROMPTS.md"
copy_if_missing "$TEMPLATE_DIR/cursor-rules/shared.mdc" "$ROOT_DIR/.cursor/rules/shared.mdc"
copy_if_missing "$TEMPLATE_DIR/cursor-rules/frontend.mdc" "$ROOT_DIR/.cursor/rules/frontend.mdc"
copy_if_missing "$TEMPLATE_DIR/cursor-rules/backend-api.mdc" "$ROOT_DIR/.cursor/rules/backend-api.mdc"
copy_if_missing "$TEMPLATE_DIR/cursor-rules/database.mdc" "$ROOT_DIR/.cursor/rules/database.mdc"
copy_if_missing "$TEMPLATE_DIR/cursor-rules/deployment.mdc" "$ROOT_DIR/.cursor/rules/deployment.mdc"

echo "[done] workflow templates applied"
