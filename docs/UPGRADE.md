# Upgrade Guide

This repository does not overwrite initialized project files by default. Business projects usually customize PRDs, rules, prompts, and stack files, so upgrades are explicit.

## Modes

```bash
# Report target files that are missing, current, or changed.
bash scripts/upgrade-workflow-templates.sh --dry-run

# Show unified diffs for files that differ.
bash scripts/upgrade-workflow-templates.sh --diff

# Create only missing files.
bash scripts/upgrade-workflow-templates.sh --apply-safe

# Overwrite existing files only with a backup.
bash scripts/upgrade-workflow-templates.sh --apply --backup
```

```powershell
.\scripts\upgrade-workflow-templates.ps1 -DryRun
.\scripts\upgrade-workflow-templates.ps1 -Diff
.\scripts\upgrade-workflow-templates.ps1 -ApplySafe
.\scripts\upgrade-workflow-templates.ps1 -Apply -Backup
```

## Version Stamp

`init` and upgrade apply modes write `.ai/template-version`:

```text
fullstack-ai-workflow=0.1.0
applied_at=2026-07-10T00:00:00Z
```

Use this stamp to compare the applied template version with `VERSION`.

## Semver Policy

- Patch: run `--apply-safe` to pick up missing files.
- Minor: run `--diff`, review changed templates, then merge manually or use `--apply --backup`.
- Major: run `--diff`, read `CHANGELOG.md`, update manifest refs, and merge manually.

## Backups

`--apply --backup` writes previous files to `.ai/template-backup/<timestamp>/` before overwriting. Do not use overwrite mode without reviewing the diff first.
