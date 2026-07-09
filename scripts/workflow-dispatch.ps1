param(
  [Parameter(Position = 0)]
  [string]$Action = "help",
  [switch]$ForceInit
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = try {
  $gitRoot = git -C $ScriptDir rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -eq 0 -and $gitRoot) { $gitRoot.Trim() } else { Split-Path $ScriptDir -Parent }
}
catch {
  Split-Path $ScriptDir -Parent
}

Set-Location $RootDir

function Show-Help {
  Write-Host @"
Usage:
  scripts/workflow-dispatch.ps1 install
  scripts/workflow-dispatch.ps1 init [-ForceInit]
  scripts/workflow-dispatch.ps1 status
  scripts/workflow-dispatch.ps1 next
  scripts/workflow-dispatch.ps1 review
  scripts/workflow-dispatch.ps1 ship
"@
}

function Ensure-File {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    Write-Host "[error] missing file: $Path"
    exit 1
  }
}

switch ($Action.ToLower()) {
  "install" {
    Ensure-File "workflow-repos.manifest.json"
    & (Join-Path $ScriptDir "bootstrap-workflow.ps1") -Manifest "workflow-repos.manifest.json"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  "init" {
    Ensure-File (Join-Path $ScriptDir "apply-workflow-templates.ps1")
    $initArgs = @{ TemplateDir = "./templates" }
    if ($ForceInit) { $initArgs.ForceInit = $true }
    & (Join-Path $ScriptDir "apply-workflow-templates.ps1") @initArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  "status" {
    if (Test-Path "docs/ai-workflow/SLICE.md") {
      Write-Host "Current stage: Execute or Verify"
    }
    elseif (Test-Path "docs/ai-workflow/PRD.md") {
      Write-Host "Current stage: Plan or Slice"
    }
    else {
      Write-Host "Current stage: Discuss"
    }
  }
  "next" {
    if (-not (Test-Path "docs/ai-workflow/PRD.md")) {
      Write-Host "Next: create PRD"
    }
    elseif (-not (Test-Path "docs/ai-workflow/slices") -or -not (Get-ChildItem "docs/ai-workflow/slices" -File -ErrorAction SilentlyContinue)) {
      Write-Host "Next: create 1~3 vertical slices"
    }
    else {
      Write-Host "Next: choose one active slice and run Red -> Green -> Refactor"
    }
  }
  "review" {
    Write-Host "Review focus: correctness, safety, tests, maintainability, rollback"
  }
  "ship" {
    Write-Host "Ship focus: evidence, migration, observability, rollback, ownership"
  }
  default {
    Show-Help
  }
}
