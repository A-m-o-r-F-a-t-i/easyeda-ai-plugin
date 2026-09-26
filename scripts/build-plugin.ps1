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

$dirty = @(& git -C $repoRoot status --porcelain --untracked-files=normal)
if ($LASTEXITCODE -ne 0 -or $dirty.Count -gt 0) {
    throw 'Commit the reviewed parent and component changes before packaging.'
}
$pins = @(& git -C $repoRoot submodule status --recursive)
if ($LASTEXITCODE -ne 0 -or $pins.Count -ne 6 -or @($pins | Where-Object { $_[0] -in @('-', '+', 'U') }).Count -gt 0) {
    throw 'Submodule checkouts must match the six committed parent pins; packaging never changes them.'
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

function Install-NodeProductionDependencies {
    param(
        [Parameter(Mandatory)] [string]$RelativePath,
        [Parameter(Mandatory)] [string]$Label,
        [Parameter(Mandatory)] [string[]]$RequiredPaths,
        [Parameter(Mandatory)] [string]$Probe
    )

    $componentPath = Join-Path $stagePath $RelativePath
    foreach ($file in @('package.json', 'package-lock.json')) {
        if (-not (Test-Path (Join-Path $componentPath $file))) {
            throw "$Label is missing $file in the committed export."
        }
    }

    Push-Location $componentPath
    try {
        & npm ci --omit=dev --ignore-scripts --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install $Label production dependencies."
        }
        & node --input-type=module -e $Probe
        if ($LASTEXITCODE -ne 0) {
            throw "$Label production dependency probe failed."
        }
    }
    finally {
        Pop-Location
    }

    foreach ($requiredPath in $RequiredPaths) {
        if (-not (Test-Path (Join-Path $componentPath $requiredPath))) {
            throw "$Label package is missing required runtime file: $requiredPath"
        }
    }
}

Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $stagePath 'plugin.json')
Copy-Item -LiteralPath (Join-Path $repoRoot 'mcp.json') -Destination (Join-Path $stagePath 'mcp.json')
foreach ($file in @('components.json', 'README.md', 'README.en.md')) {
    Copy-Item -LiteralPath (Join-Path $repoRoot $file) -Destination (Join-Path $stagePath $file)
}

$componentManifest = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'components.json') | ConvertFrom-Json
foreach ($component in $componentManifest.components) {
    $source = Join-Path $repoRoot $component.path
    $destination = Join-Path $stagePath $component.path
    if (-not (Test-Path (Join-Path $source '.git'))) {
        throw "Submodule is not initialized: $($component.path)"
    }
    Export-GitTree -Source $source -Destination $destination
}

Install-NodeProductionDependencies `
    -RelativePath 'skills/easyeda-api' `
    -Label 'EasyEDA API Skill' `
    -RequiredPaths @('node_modules/ws/package.json') `
    -Probe "await import('ws');"

Install-NodeProductionDependencies `
    -RelativePath 'mcp/easyeda-pcb' `
    -Label 'PCB MCP' `
    -RequiredPaths @(
        'node_modules/@modelcontextprotocol/sdk/package.json',
        'node_modules/polygon-clipping/package.json',
        'node_modules/zod/package.json'
    ) `
    -Probe "await import('@modelcontextprotocol/sdk/server/mcp.js'); await import('polygon-clipping'); await import('zod');"

Compress-Archive -Path (Join-Path $stagePath '*') -DestinationPath $zipPath -CompressionLevel Optimal

$zip = Get-Item -LiteralPath $zipPath
[PSCustomObject]@{
    Plugin = $manifest.name
    Version = $manifest.version
    Directory = $stagePath
    Archive = $zipPath
    ArchiveBytes = $zip.Length
}
