#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT_DIR"

if [ -f ".ai/stack.env" ]; then
  # shellcheck disable=SC1091
  source .ai/stack.env
fi

[ -n "${LINT_CMD:-}" ] && eval "$LINT_CMD"
[ -n "${TYPECHECK_CMD:-}" ] && eval "$TYPECHECK_CMD"
[ -n "${TEST_CMD:-}" ] && eval "$TEST_CMD"

if [ "${RUN_E2E_ON_COMMIT:-false}" = "true" ] && [ -n "${E2E_CMD:-}" ]; then
  eval "$E2E_CMD"
fi

echo "[ok] checks passed"
