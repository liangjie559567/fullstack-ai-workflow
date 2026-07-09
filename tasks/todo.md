# Workflow Install Plan

## Goal
Run `$workflow install` for this repository using the local workflow dispatcher.

## Plan
- [x] Create `workflow-repos.manifest.json` from `workflow-repos.manifest.example.json` if it does not already exist.
- [x] Run workflow install through the Windows PowerShell dispatcher.
- [x] Fallback: run `scripts/bootstrap-workflow.ps1 workflow-repos.manifest.json` because WSL `bash` is unavailable.
- [x] Verify installed workflow repositories under `.ai/vendor`.
- [x] Check git status and summarize any generated changes.

## Notes
- `install` maps to `scripts/workflow-dispatch.sh install`.
- The dispatcher requires `workflow-repos.manifest.json`.
- The example manifest currently points at `https://github.com/liangjie559567/*.git` repositories.
- `scripts/workflow-dispatch.sh install` could not run because this machine's `bash` points to WSL without `/bin/bash`.
- PowerShell fallback initially installed `fullstack-ai-workflow`, but `gsd` and `superpowers` failed because the configured GitHub repositories did not exist.
- `gsd` was corrected to `https://github.com/open-gsd/gsd-core.git` at `v1.6.1`.
- `superpowers` was corrected to `https://github.com/obra/superpowers.git` at `v6.1.1`.
- Git clone transport to GitHub is unreliable in this environment, so PowerShell install now falls back to GitHub codeload tarballs.

## Review
- `workflow-repos.manifest.json` was created.
- `scripts/workflow-dispatch.sh install` could not run on this machine because WSL `bash` is unavailable.
- `scripts/bootstrap-workflow.ps1 workflow-repos.manifest.json` initially ran, but only installed `.ai/vendor/fullstack-ai-workflow`.
- GitHub confirmed `liangjie559567/gsd` and `liangjie559567/superpowers` do not exist.
- `workflow-repos.manifest.example.json` and local `workflow-repos.manifest.json` were updated to real upstreams.
- `scripts/workflow-dispatch.ps1 install` now completes successfully.
- Installed vendor directories: `.ai/vendor/gsd`, `.ai/vendor/superpowers`, `.ai/vendor/fullstack-ai-workflow`.
- Verified README files exist in all three vendor directories.
- Verified `.ai/vendor/fullstack-ai-workflow` is checked out at `v0.1.0`.

---

# Risk Governance Plan

## Goal
Address the four governance risks: Windows bash/jq dependency, manual upgrade friction, uncontrolled external vendors, and template-source self-init confusion.

## Plan
- [x] Keep PowerShell script chain for install/init/status/next and Windows one-shot bootstrap.
- [x] Add init guard and repository role documentation for template source repositories.
- [x] Add vendor dependency verification scripts for PowerShell and shell.
- [x] Add explicit upgrade tooling for dry-run, diff, safe apply, and backed-up overwrite.
- [x] Add upgrade and vendor compatibility documentation.
- [x] Update README and publishing guide with Windows, role, upgrade, and vendor guidance.
- [x] Extend CI validation to cover PowerShell scripts and optional vendor checks.
- [x] Run local syntax and smoke verification.

## Review
- PowerShell script syntax checks passed for bootstrap, apply, dispatch, bootstrap-all, verify-vendor, and upgrade scripts.
- `scripts/workflow-dispatch.ps1 status` returned `Current stage: Discuss`.
- `scripts/workflow-dispatch.ps1 next` returned `Next: create PRD`.
- `scripts/upgrade-workflow-templates.ps1 -DryRun` reported target files without writing them.
- `scripts/verify-vendor-deps.ps1 workflow-repos.manifest.json` returned `OK` for `gsd`, `superpowers`, and `fullstack-ai-workflow`.
- `scripts/verify-vendor-deps.ps1 workflow-repos.manifest.json -RemoteOnly` returned `OK` for all enabled upstream tags.
- Git Bash was found at `C:\Program Files\Git\bin\bash.exe`.
- Shell syntax checks passed for bootstrap, apply, dispatch, bootstrap-all, verify-vendor, upgrade, and Claude hook scripts.
- `scripts/workflow-dispatch.sh status` returned `Current stage: Discuss` under Git Bash.
- `scripts/workflow-dispatch.sh next` returned `Next: create PRD` under Git Bash.
- `scripts/verify-vendor-deps.sh --remote-only workflow-repos.manifest.json` returned `OK` for all enabled upstream tags.
- `scripts/workflow-dispatch.ps1 init` correctly blocked self-init in this template source repository.
- `git diff --check` passed; only Windows line-ending warnings were reported.
