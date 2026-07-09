#!/usr/bin/env bash
set -euo pipefail

MANIFEST="${1:-workflow-repos.manifest.json}"

if ! command -v jq >/dev/null 2>&1; then
  echo "[error] jq is required"
  exit 1
fi

ROOT="$(jq -r '.install_root' "$MANIFEST")"
mkdir -p "$ROOT"

jq -c '.repos[] | select(.enabled == true)' "$MANIFEST" | while read -r repo; do
  name="$(echo "$repo" | jq -r '.name')"
  url="$(echo "$repo" | jq -r '.url')"
  ref="$(echo "$repo" | jq -r '.ref')"
  dir="$ROOT/$name"

  if [ -d "$dir/.git" ]; then
    echo "[update] $name"
    git -C "$dir" fetch --all --tags
    git -C "$dir" checkout "$ref"
    git -C "$dir" pull --ff-only || true
  else
    echo "[clone] $name"
    git clone "$url" "$dir"
    git -C "$dir" checkout "$ref"
  fi

  echo "$repo" | jq -r '.post_install[]?' | while read -r cmd; do
    [ -n "$cmd" ] && (cd "$dir" && eval "$cmd")
  done
done

echo "[done] workflow repos ready in $ROOT"
