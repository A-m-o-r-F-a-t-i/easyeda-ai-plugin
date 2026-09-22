[CmdletBinding()]
param(
    [switch]$Remote
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

& git -C $repoRoot submodule sync --recursive
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to synchronize submodule URLs.'
}

if ($Remote) {
    & git -C $repoRoot submodule update --init --recursive --remote --merge
}
else {
    & git -C $repoRoot submodule update --init --recursive
}

if ($LASTEXITCODE -ne 0) {
    throw 'Failed to update submodules.'
}

& git -C $repoRoot submodule status --recursive
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to read submodule status.'
}
