param(
  [string]$TemplateDir = "./templates",
  [string]$RootDir = "",
  [switch]$DryRun,
  [switch]$Diff,
  [switch]$ApplySafe,
  [switch]$Apply,
  [switch]$Backup
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  param([string]$StartDir)
  $dir = if ($StartDir) { $StartDir } else { (Get-Location).Path }
  try {
    $gitRoot = git -C $dir rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitRoot) { return $gitRoot.Trim() }
  }
  catch { }
  return $dir
}

function Get-TemplateMappings {
  param([string]$TemplateDir, [string]$RootDir)
  @(
    @{ Src = "$TemplateDir/CLAUDE.md"; Dst = "$RootDir/CLAUDE.md" },
    @{ Src = "$TemplateDir/AGENTS.md"; Dst = "$RootDir/AGENTS.md" },
    @{ Src = "$TemplateDir/testing.instructions.md"; Dst = "$RootDir/testing.instructions.md" },
    @{ Src = "$TemplateDir/stack.env"; Dst = "$RootDir/.ai/stack.env" },
    @{ Src = "$TemplateDir/STATE.md"; Dst = "$RootDir/docs/ai-workflow/STATE.md" },
    @{ Src = "$TemplateDir/CONTEXT.md"; Dst = "$RootDir/docs/ai-workflow/CONTEXT.md" },
    @{ Src = "$TemplateDir/PRD.md"; Dst = "$RootDir/docs/ai-workflow/PRD.md" },
    @{ Src = "$TemplateDir/SLICE.md"; Dst = "$RootDir/docs/ai-workflow/SLICE.md" },
    @{ Src = "$TemplateDir/claude/workflow.md"; Dst = "$RootDir/.claude/commands/workflow.md" },
    @{ Src = "$TemplateDir/claude/init-workflow.md"; Dst = "$RootDir/.claude/commands/init-workflow.md" },
    @{ Src = "$TemplateDir/claude/create-slice.md"; Dst = "$RootDir/.claude/commands/create-slice.md" },
    @{ Src = "$TemplateDir/claude/pre-commit-check.sh"; Dst = "$RootDir/.claude/hooks/pre-commit-check.sh" },
    @{ Src = "$TemplateDir/codex/WORKFLOW.md"; Dst = "$RootDir/.ai/codex/WORKFLOW.md" },
    @{ Src = "$TemplateDir/codex/PROMPTS.md"; Dst = "$RootDir/.ai/codex/PROMPTS.md" },
    @{ Src = "$TemplateDir/cursor-rules/shared.mdc"; Dst = "$RootDir/.cursor/rules/shared.mdc" },
    @{ Src = "$TemplateDir/cursor-rules/frontend.mdc"; Dst = "$RootDir/.cursor/rules/frontend.mdc" },
    @{ Src = "$TemplateDir/cursor-rules/backend-api.mdc"; Dst = "$RootDir/.cursor/rules/backend-api.mdc" },
    @{ Src = "$TemplateDir/cursor-rules/database.mdc"; Dst = "$RootDir/.cursor/rules/database.mdc" },
    @{ Src = "$TemplateDir/cursor-rules/deployment.mdc"; Dst = "$RootDir/.cursor/rules/deployment.mdc" }
  )
}

function Write-TemplateVersionStamp {
  param([string]$RootDir)
  $versionFile = Join-Path $RootDir "VERSION"
  $version = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { "unknown" }
  $stampDir = Join-Path $RootDir ".ai"
  New-Item -ItemType Directory -Force -Path $stampDir | Out-Null
  @(
    "fullstack-ai-workflow=$version",
    "applied_at=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))"
  ) | Set-Content -Path (Join-Path $stampDir "template-version") -Encoding utf8
}

if (-not $DryRun -and -not $Diff -and -not $ApplySafe -and -not $Apply) {
  $DryRun = $true
}

if ($Apply -and -not $Backup) {
  throw "--apply requires --backup"
}

$resolvedRoot = if ($RootDir) { $RootDir } else { Get-RepoRoot "" }
$resolvedTemplate = if ([System.IO.Path]::IsPathRooted($TemplateDir)) { $TemplateDir } else { Join-Path $resolvedRoot $TemplateDir }
$backupDir = Join-Path $resolvedRoot ".ai/template-backup/$((Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ"))"

foreach ($map in Get-TemplateMappings -TemplateDir $resolvedTemplate -RootDir $resolvedRoot) {
  if (-not (Test-Path $map.Src)) {
    Write-Host "MISSING_SOURCE`t$($map.Src)"
    continue
  }

  if (-not (Test-Path $map.Dst)) {
    Write-Host "TARGET_MISSING`t$($map.Dst)"
    if ($ApplySafe -or $Apply) {
      New-Item -ItemType Directory -Force -Path (Split-Path $map.Dst -Parent) | Out-Null
      Copy-Item -LiteralPath $map.Src -Destination $map.Dst -Force
      Write-Host "CREATE`t$($map.Dst)"
    }
    continue
  }

  $srcHash = (Get-FileHash -Algorithm SHA256 $map.Src).Hash
  $dstHash = (Get-FileHash -Algorithm SHA256 $map.Dst).Hash
  if ($srcHash -eq $dstHash) {
    Write-Host "TARGET_CURRENT`t$($map.Dst)"
    continue
  }

  Write-Host "TEMPLATE_UPDATED`t$($map.Dst)"
  if ($Diff) {
    git diff --no-index -- $map.Dst $map.Src
    if ($LASTEXITCODE -gt 1) { exit $LASTEXITCODE }
  }

  if ($Apply) {
    $relative = [System.IO.Path]::GetRelativePath($resolvedRoot, $map.Dst)
    $backupPath = Join-Path $backupDir $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $backupPath -Parent) | Out-Null
    Copy-Item -LiteralPath $map.Dst -Destination $backupPath -Force
    Copy-Item -LiteralPath $map.Src -Destination $map.Dst -Force
    Write-Host "OVERWRITE`t$($map.Dst)`tBACKUP`t$backupPath"
  }
}

if ($ApplySafe -or $Apply) {
  Write-TemplateVersionStamp -RootDir $resolvedRoot
}
