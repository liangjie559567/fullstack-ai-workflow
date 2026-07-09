param(
  [string]$Manifest = "workflow-repos.manifest.json"
)

$manifestObj = Get-Content $Manifest -Raw | ConvertFrom-Json
$root = $manifestObj.install_root
New-Item -ItemType Directory -Force -Path $root | Out-Null

foreach ($repo in $manifestObj.repos) {
  if (-not $repo.enabled) { continue }

  $dir = Join-Path $root $repo.name
  if (Test-Path (Join-Path $dir ".git")) {
    Write-Host "[update] $($repo.name)"
    git -C $dir fetch --all --tags
    git -C $dir checkout $repo.ref
    git -C $dir pull --ff-only
  }
  else {
    Write-Host "[clone] $($repo.name)"
    git clone $repo.url $dir
    git -C $dir checkout $repo.ref
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
