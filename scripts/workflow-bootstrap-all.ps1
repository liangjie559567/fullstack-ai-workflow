$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dispatch = Join-Path $ScriptDir "workflow-dispatch.ps1"

& $dispatch install
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $dispatch init
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $dispatch status
& $dispatch next
