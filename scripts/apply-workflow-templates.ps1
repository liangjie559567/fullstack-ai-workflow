param(
  [string]$TemplateDir = "./templates",
  [string]$RootDir = "",
  [switch]$ForceInit
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

function Test-TemplateSourceRepo {
  param([string]$Root)
  $templateClaude = Join-Path $Root "templates/CLAUDE.md"
  if (-not (Test-Path $templateClaude)) { return $false }

  $prdPath = Join-Path $Root "docs/ai-workflow/PRD.md"
  if (Test-Path $prdPath) { return $false }

  try {
    $remoteUrl = git -C $Root remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and $remoteUrl -match "fullstack-ai-workflow") {
      return $true
    }
  }
  catch { }

  return $false
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

function Copy-IfMissing {
  param([string]$Src, [string]$Dst)
  if (-not (Test-Path $Src)) {
    Write-Host "[warn] missing source: $Src"
    return
  }
  $dstParent = Split-Path $Dst -Parent
  if ($dstParent) { New-Item -ItemType Directory -Force -Path $dstParent | Out-Null }
  if (Test-Path $Dst) {
    Write-Host "[skip] exists: $Dst"
  }
  else {
    Copy-Item -Path $Src -Destination $Dst -Force
    Write-Host "[create] $Dst"
  }
}

function Write-TemplateVersionStamp {
  param([string]$RootDir)
  $versionFile = Join-Path $RootDir "VERSION"
  $version = if (Test-Path $versionFile) {
    (Get-Content $versionFile -Raw).Trim()
  }
  else {
    "unknown"
  }
  $stampDir = Join-Path $RootDir ".ai"
  New-Item -ItemType Directory -Force -Path $stampDir | Out-Null
  $stampPath = Join-Path $stampDir "template-version"
  $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  @(
    "fullstack-ai-workflow=$version",
    "applied_at=$timestamp"
  ) | Set-Content -Path $stampPath -Encoding utf8
  Write-Host "[stamp] $stampPath"
}

$resolvedRoot = if ($RootDir) { $RootDir } else { Get-RepoRoot "" }
$resolvedTemplate = if ([System.IO.Path]::IsPathRooted($TemplateDir)) {
  $TemplateDir
}
else {
  Join-Path $resolvedRoot $TemplateDir
}

if (Test-TemplateSourceRepo -Root $resolvedRoot) {
  if (-not $ForceInit) {
    Write-Host "[warn] This looks like the template source repository."
    Write-Host "[warn] Running init here creates duplicate workflow files alongside templates/."
    Write-Host "[warn] See REPOSITORY_ROLE.md. Use -ForceInit to override."
    exit 1
  }
  Write-Host "[warn] Proceeding with -ForceInit on template source repository."
}

$mappings = Get-TemplateMappings -TemplateDir $resolvedTemplate -RootDir $resolvedRoot
foreach ($map in $mappings) {
  Copy-IfMissing -Src $map.Src -Dst $map.Dst
}

Write-TemplateVersionStamp -RootDir $resolvedRoot
Write-Host "[done] workflow templates applied"
