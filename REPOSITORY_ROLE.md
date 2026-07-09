# Repository Role: TEMPLATE_SOURCE

This repository is a **publishable AI workflow template source**. It is not intended to be initialized like a business application project.

## What this means

- `templates/` is the single authoritative source for distributable workflow files.
- Do **not** run `init` on this repository root under normal maintenance.
- Business projects consume this repo via `workflow-repos.manifest.json` + bootstrap scripts.
- `.ai/vendor/` is a local runtime cache (gitignored), not part of the published source.

## For template maintainers

1. Edit files under `templates/` and `scripts/`.
2. Bump `VERSION` and `CHANGELOG.md`.
3. Tag a release (for example `v0.1.0`).
4. Validate with CI (`validate-template.yml`).

## For business projects

1. Copy `workflow-repos.manifest.example.json` to `workflow-repos.manifest.json`.
2. Run install:

```bash
bash scripts/workflow-dispatch.sh install
# or on Windows:
pwsh scripts/workflow-dispatch.ps1 install
```

3. Run init (in the **business project**, not here):

```bash
bash scripts/workflow-dispatch.sh init
# or on Windows:
pwsh scripts/workflow-dispatch.ps1 init
```

## Dogfooding

If you need to test the full workflow end-to-end, use a separate business project or an `examples/` directory. Do not init this template source repository unless you explicitly intend to override with `-ForceInit` / `FORCE_INIT=1`.

## Escape hatch

Template source detection can be overridden when you truly need local init:

- PowerShell: `pwsh scripts/workflow-dispatch.ps1 init -ForceInit`
- Bash: `FORCE_INIT=1 bash scripts/apply-workflow-templates.sh`
