param(
  [string]$Manifest = "workflow-repos.manifest.json"
)

$manifestObj = Get-Content $Manifest -Raw | ConvertFrom-Json
$root = $manifestObj.install_root
New-Item -ItemType Directory -Force -Path $root | Out-Null

function Invoke-Git {
  & git @args
  if ($LASTEXITCODE -ne 0) {
    throw "git $($args -join ' ') failed with exit code $LASTEXITCODE"
  }
}

function Get-GitHubRepoPath {
  param([string]$Url)

  if ($Url -match '^https://github\.com/([^/]+)/([^/]+?)(?:\.git)?/?$') {
    return "$($Matches[1])/$($Matches[2])"
  }

  return $null
}

function Install-GitHubArchive {
  param(
    [object]$Repo,
    [string]$Dir
  )

  $repoPath = Get-GitHubRepoPath $Repo.url
  if (-not $repoPath) {
    throw "archive fallback only supports GitHub HTTPS URLs: $($Repo.url)"
  }

  $archive = Join-Path $root "$($Repo.name)-$($Repo.ref).tar.gz"
  $archiveUrl = "https://codeload.github.com/$repoPath/tar.gz/refs/tags/$($Repo.ref)"

  Write-Host "[archive] $($Repo.name)"
  if (-not (Test-Path $archive)) {
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archive
  }

  if (Test-Path $Dir) {
    $rootPath = (Resolve-Path $root).Path
    $dirPath = (Resolve-Path $Dir).Path
    if (-not $dirPath.StartsWith($rootPath)) {
      throw "refusing to remove outside install root: $dirPath"
    }
    Remove-Item -LiteralPath $Dir -Recurse -Force
  }

  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  & tar -xzf $archive -C $Dir --strip-components=1 --exclude "*/AGENTS.md"
  if ($LASTEXITCODE -ne 0) {
    throw "tar extraction failed for $archive"
  }

  $claudeMd = Join-Path $Dir "CLAUDE.md"
  $agentsMd = Join-Path $Dir "AGENTS.md"
  if ((Test-Path $claudeMd) -and -not (Test-Path $agentsMd)) {
    Copy-Item -LiteralPath $claudeMd -Destination $agentsMd
  }

  $metadata = Join-Path $Dir ".vendor-version"
  @(
    "name=$($Repo.name)",
    "url=$($Repo.url)",
    "ref=$($Repo.ref)",
    "installed_via=archive",
    "installed_at=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))"
  ) | Set-Content -Path $metadata -Encoding utf8
}

foreach ($repo in $manifestObj.repos) {
  if (-not $repo.enabled) { continue }

  $dir = Join-Path $root $repo.name
  if (Test-Path (Join-Path $dir ".git")) {
    Write-Host "[update] $($repo.name)"
    Invoke-Git -C $dir fetch --all --tags
    Invoke-Git -C $dir checkout $repo.ref
  }
  else {
    if (Test-Path $dir) {
      Write-Host "[archive-update] $($repo.name)"
      Install-GitHubArchive -Repo $repo -Dir $dir
      continue
    }

    Write-Host "[clone] $($repo.name)"
    try {
      Invoke-Git clone --depth 1 --branch $repo.ref $repo.url $dir
    }
    catch {
      Write-Warning $_
      Install-GitHubArchive -Repo $repo -Dir $dir
    }
  }

  foreach ($cmd in $repo.post_install) {
    if ($cmd) {
      Push-Location $dir
      Invoke-Expression $cmd
      Pop-Location
    }
  }
}

Write-Host "[done] workflow repos ready in $root"
