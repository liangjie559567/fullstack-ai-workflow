param(
  [string]$Manifest = "workflow-repos.manifest.json",
  [switch]$RemoteOnly
)

$ErrorActionPreference = "Stop"
$manifestObj = Get-Content $Manifest -Raw | ConvertFrom-Json
$root = $manifestObj.install_root
$failed = $false

function Test-RemoteTag {
  param([string]$Url, [string]$Ref)

  $result = & git ls-remote $Url "refs/tags/$Ref" 2>$null
  return $LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($result -join ""))
}

function Get-VendorMetadataRef {
  param([string]$Path)

  $metadata = Join-Path $Path ".vendor-version"
  if (-not (Test-Path $metadata)) { return $null }

  foreach ($line in Get-Content $metadata) {
    if ($line -match '^ref=(.+)$') {
      return $Matches[1]
    }
  }

  return $null
}

function Get-LocalRef {
  param([string]$Path)

  if (Test-Path (Join-Path $Path ".git")) {
    $tag = git -C $Path describe --tags --exact-match 2>$null
    if ($LASTEXITCODE -eq 0 -and $tag) {
      return $tag.Trim()
    }
    return $null
  }

  return Get-VendorMetadataRef -Path $Path
}

Write-Host "NAME`tSTATUS`tREF`tDETAIL"

foreach ($repo in $manifestObj.repos) {
  if (-not $repo.enabled) { continue }

  $optional = $repo.PSObject.Properties.Name -contains "optional" -and $repo.optional
  $dir = Join-Path $root $repo.name
  $status = "OK"
  $detail = "remote tag and local vendor match"

  if (-not (Test-RemoteTag -Url $repo.url -Ref $repo.ref)) {
    $status = "MISSING_TAG"
    $detail = "refs/tags/$($repo.ref) not found at $($repo.url)"
  }
  elseif ($RemoteOnly) {
    $detail = "remote tag exists"
  }
  elseif (-not (Test-Path $dir)) {
    $status = "CLONE_FAILED"
    $detail = "local vendor directory missing: $dir"
  }
  else {
    $localRef = Get-LocalRef -Path $dir
    if ($localRef -ne $repo.ref) {
      $status = "VERSION_MISMATCH"
      $detail = "local ref '$localRef' does not match manifest ref '$($repo.ref)'"
    }
  }

  Write-Host "$($repo.name)`t$status`t$($repo.ref)`t$detail"

  if ($status -ne "OK" -and -not $optional) {
    $failed = $true
  }
}

if ($failed) {
  exit 1
}
