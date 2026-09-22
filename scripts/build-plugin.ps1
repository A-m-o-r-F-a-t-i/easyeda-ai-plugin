[CmdletBinding()]
param(
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot 'dist'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)

$manifestPath = Join-Path $repoRoot 'plugin.json'
$manifest = Get-Content -Raw -Encoding UTF8 $manifestPath | ConvertFrom-Json
$packageName = "easyeda-plugin-$($manifest.version)"
$stagePath = Join-Path $OutputDirectory $packageName
$zipPath = Join-Path $OutputDirectory "$packageName.zip"

& git -C $repoRoot submodule update --init --recursive
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to initialize plugin submodules.'
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
if (Test-Path $stagePath) {
    Remove-Item -LiteralPath $stagePath -Recurse -Force
}
if (Test-Path $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
New-Item -ItemType Directory -Path $stagePath -Force | Out-Null

function Export-GitTree {
    param(
        [Parameter(Mandatory)] [string]$Source,
        [Parameter(Mandatory)] [string]$Destination
    )

    $archive = Join-Path ([System.IO.Path]::GetTempPath()) ("easyeda-" + [guid]::NewGuid().ToString('N') + '.zip')
    try {
        & git -C $Source archive --format=zip --output=$archive HEAD
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to export committed tree: $Source"
        }
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Expand-Archive -LiteralPath $archive -DestinationPath $Destination -Force
    }
    finally {
        if (Test-Path $archive) {
            Remove-Item -LiteralPath $archive -Force
        }
    }
}

Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $stagePath 'plugin.json')
Copy-Item -LiteralPath (Join-Path $repoRoot 'mcp.json') -Destination (Join-Path $stagePath 'mcp.json')

$componentManifest = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'components.json') | ConvertFrom-Json
foreach ($component in $componentManifest.components) {
    $source = Join-Path $repoRoot $component.path
    $destination = Join-Path $stagePath $component.path
    if (-not (Test-Path (Join-Path $source '.git'))) {
        throw "Submodule is not initialized: $($component.path)"
    }
    Export-GitTree -Source $source -Destination $destination
}

$mcpPath = Join-Path $stagePath 'mcp/easyeda-pcb'
Push-Location $mcpPath
try {
    & npm ci --omit=dev
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to install PCB MCP production dependencies.'
    }
}
finally {
    Pop-Location
}

Compress-Archive -Path (Join-Path $stagePath '*') -DestinationPath $zipPath -CompressionLevel Optimal

$zip = Get-Item -LiteralPath $zipPath
[PSCustomObject]@{
    Plugin = $manifest.name
    Version = $manifest.version
    Directory = $stagePath
    Archive = $zipPath
    ArchiveBytes = $zip.Length
}
