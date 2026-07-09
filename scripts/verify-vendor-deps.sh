#!/usr/bin/env bash
set -euo pipefail

REMOTE_ONLY=0
MANIFEST="workflow-repos.manifest.json"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --remote-only)
      REMOTE_ONLY=1
      ;;
    *)
      MANIFEST="$1"
      ;;
  esac
  shift
done

PYTHON_BIN=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" --version >/dev/null 2>&1; then
    PYTHON_BIN="$candidate"
    break
  fi
done

if [ -z "$PYTHON_BIN" ] && command -v py >/dev/null 2>&1 && py -3 --version >/dev/null 2>&1; then
  PYTHON_BIN="py -3"
fi

if [ -z "$PYTHON_BIN" ]; then
  echo "[error] python3 or python is required" >&2
  exit 2
fi

$PYTHON_BIN - "$MANIFEST" "$REMOTE_ONLY" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
remote_only = sys.argv[2] == "1"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
root = Path(manifest["install_root"])
failed = False

def remote_tag_exists(url, ref):
    result = subprocess.run(
        ["git", "ls-remote", url, f"refs/tags/{ref}"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.returncode == 0 and bool(result.stdout.strip())

def metadata_ref(path):
    metadata = path / ".vendor-version"
    if not metadata.exists():
        return None
    for line in metadata.read_text(encoding="utf-8").splitlines():
        if line.startswith("ref="):
            return line.split("=", 1)[1]
    return None

def local_ref(path):
    if (path / ".git").exists():
        result = subprocess.run(
            ["git", "-C", str(path), "describe", "--tags", "--exact-match"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return None
    return metadata_ref(path)

print("NAME\tSTATUS\tREF\tDETAIL")
for repo in manifest["repos"]:
    if not repo.get("enabled", False):
        continue

    path = root / repo["name"]
    optional = repo.get("optional", False)
    status = "OK"
    detail = "remote tag and local vendor match"

    if not remote_tag_exists(repo["url"], repo["ref"]):
        status = "MISSING_TAG"
        detail = f"refs/tags/{repo['ref']} not found at {repo['url']}"
    elif remote_only:
        detail = "remote tag exists"
    elif not path.exists():
        status = "CLONE_FAILED"
        detail = f"local vendor directory missing: {path}"
    else:
        ref = local_ref(path)
        if ref != repo["ref"]:
            status = "VERSION_MISMATCH"
            detail = f"local ref {ref!r} does not match manifest ref {repo['ref']!r}"

    print(f"{repo['name']}\t{status}\t{repo['ref']}\t{detail}")
    if status != "OK" and not optional:
        failed = True

sys.exit(1 if failed else 0)
PY
