#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TEMPLATE_DIR="${1:-./templates}"
FORCE_INIT="${FORCE_INIT:-}"

is_template_source_repo() {
  [ -f "$ROOT_DIR/templates/CLAUDE.md" ] || return 1
  [ -f "$ROOT_DIR/docs/ai-workflow/PRD.md" ] && return 1
  local remote_url
  remote_url="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)"
  echo "$remote_url" | grep -q "fullstack-ai-workflow"
}

if is_template_source_repo && [ "$FORCE_INIT" != "1" ]; then
  echo "[warn] This looks like the template source repository."
  echo "[warn] Running init here creates duplicate workflow files alongside templates/."
  echo "[warn] See REPOSITORY_ROLE.md. Set FORCE_INIT=1 to override."
  exit 1
fi

if is_template_source_repo && [ "$FORCE_INIT" = "1" ]; then
  echo "[warn] Proceeding with FORCE_INIT=1 on template source repository."
fi

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

mkdir -p "$ROOT_DIR/.ai"
VERSION="$(cat "$ROOT_DIR/VERSION" 2>/dev/null || echo unknown)"
APPLIED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
{
  echo "fullstack-ai-workflow=$VERSION"
  echo "applied_at=$APPLIED_AT"
} > "$ROOT_DIR/.ai/template-version"
echo "[stamp] $ROOT_DIR/.ai/template-version"

echo "[done] workflow templates applied"
